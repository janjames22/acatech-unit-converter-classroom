import 'dart:async';

import '../domain/models/assessment_incident.dart';
import '../domain/models/assessment_session.dart';
import '../domain/models/pending_absence.dart';
import '../domain/models/presence_event.dart';
import '../domain/repositories/assessment_repository.dart';
import '../domain/services/assessment_clock.dart';
import '../domain/services/interruption_policy.dart';

enum AssessmentMonitorStatus { idle, active, absencePending }

typedef IncidentIdFactory = String Function(String sessionId, DateTime leftAt);

/// Pure-Dart assessment visibility state machine.
///
/// Navigation is intentionally absent from this API. Only lifecycle presence
/// observations can create an absence candidate, so internal routes, dialogs,
/// dropdowns, and keyboard activity cannot be counted by this component.
final class AssessmentMonitor {
  factory AssessmentMonitor({
    required AssessmentRepository repository,
    AssessmentClock clock = const SystemAssessmentClock(),
    InterruptionPolicy policy = const InterruptionPolicy(),
    IncidentIdFactory? incidentIdFactory,
  }) {
    return AssessmentMonitor._(
      repository,
      clock,
      policy,
      incidentIdFactory ?? _defaultIncidentId,
    );
  }

  AssessmentMonitor._(
    this._repository,
    this._clock,
    this._policy,
    this._incidentIdFactory,
  );

  static const String visibilityInterruptedReason =
      'Application visibility was interrupted.';
  static const String unresolvedReason =
      'Application visibility did not return before the session was closed.';

  final AssessmentRepository _repository;
  final AssessmentClock _clock;
  final InterruptionPolicy _policy;
  final IncidentIdFactory _incidentIdFactory;

  Future<void> _operationTail = Future<void>.value();
  bool _initialized = false;
  AssessmentSession? _activeSession;
  PendingAbsence? _pendingAbsence;
  AssessmentPresenceState? _lastPresenceState;
  DateTime? _lastObservationAt;

  bool get isInitialized => _initialized;

  AssessmentSession? get activeSession => _activeSession;

  PendingAbsence? get pendingAbsence => _pendingAbsence;

  AssessmentPresenceState? get lastPresenceState => _lastPresenceState;

  AssessmentMonitorStatus get status {
    if (_activeSession == null) {
      return AssessmentMonitorStatus.idle;
    }
    if (_pendingAbsence != null) {
      return AssessmentMonitorStatus.absencePending;
    }
    return AssessmentMonitorStatus.active;
  }

  /// Loads an active session and resolves any record left by a prior process.
  ///
  /// Calling this more than once is safe. If a finalized incident already
  /// exists for a surviving pending record, only the stale pending record is
  /// cleared; the incident timestamps are not changed. Otherwise the pending
  /// record is finalized as unresolved (or retains an explicit exclusion),
  /// because a new process cannot establish an exact return timestamp.
  Future<void> initialize() => _enqueue(_ensureInitialized);

  Future<AssessmentSession> startSession(AssessmentSession session) {
    return _enqueue(() async {
      await _ensureInitialized();
      if (!session.isActive) {
        throw ArgumentError.value(
          session,
          'session',
          'A new session must be active.',
        );
      }

      final current = _activeSession;
      if (current != null) {
        if (current.id == session.id) {
          return current;
        }
        throw StateError('Assessment session ${current.id} is already active.');
      }

      await _repository.saveSession(session);
      _activeSession = session;
      _pendingAbsence = null;
      _lastPresenceState = null;
      _lastObservationAt = null;
      return session;
    });
  }

  /// Ends the current session, preserving a pending candidate as unresolved.
  ///
  /// A teacher or platform adapter can mark a pending candidate as excluded
  /// before ending; in that case it remains classified as excluded.
  Future<AssessmentSession?> endSession({DateTime? endedAt}) {
    return _enqueue(() async {
      await _ensureInitialized();
      final session = _activeSession;
      if (session == null) {
        return null;
      }

      final at = endedAt ?? _clock.now();
      if (at.isBefore(session.startedAt)) {
        throw ArgumentError.value(
          at,
          'endedAt',
          'Must not be before the session start.',
        );
      }

      final pending = _pendingAbsence;
      if (pending != null) {
        await _finalizeUnreturnedPending(pending);
        _pendingAbsence = null;
      }

      final endedSession = session.end(at);
      await _repository.saveSession(endedSession);
      _activeSession = null;
      _lastPresenceState = null;
      _lastObservationAt = null;
      return endedSession;
    });
  }

  /// Creates an event at the injected clock's current time.
  Future<AssessmentIncident?> handlePresenceState(
    AssessmentPresenceState state, {
    DateTime? observedAt,
  }) {
    return handlePresence(
      PresenceEvent(observedAt: observedAt ?? _clock.now(), state: state),
    );
  }

  Future<AssessmentIncident?> handlePresence(PresenceEvent event) {
    return _enqueue(() async {
      await _ensureInitialized();
      final session = _activeSession;
      if (session == null || event.observedAt.isBefore(session.startedAt)) {
        return null;
      }

      final lastObservationAt = _lastObservationAt;
      if (lastObservationAt != null &&
          event.observedAt.isBefore(lastObservationAt)) {
        return null;
      }

      switch (event.state) {
        case AssessmentPresenceState.inactive:
          // Losing focus is too ambiguous to open a candidate. If hidden or
          // paused follows, that later signal supplies the departure time.
          _recordObservation(event);
          return null;
        case AssessmentPresenceState.hidden:
        case AssessmentPresenceState.paused:
          if (_pendingAbsence == null) {
            final pending = PendingAbsence(
              incidentId: _incidentIdFactory(session.id, event.observedAt),
              sessionId: session.id,
              leftAt: event.observedAt,
              trigger: event.state,
            );
            // Persist first. A process stop immediately after this await can
            // recover the original departure time and incident ID.
            await _repository.savePendingAbsence(pending);
            _pendingAbsence = pending;
          }
          _recordObservation(event);
          return null;
        case AssessmentPresenceState.resumed:
          final pending = _pendingAbsence;
          if (pending == null) {
            _recordObservation(event);
            return null;
          }
          if (event.observedAt.isBefore(pending.leftAt)) {
            return null;
          }

          final existing = await _repository.loadIncident(pending.incidentId);
          if (existing != null) {
            await _repository.clearPendingAbsence(pending.incidentId);
            _pendingAbsence = null;
            _recordObservation(event);
            return existing;
          }

          final duration = event.observedAt.difference(pending.leftAt);
          final classification = pending.exclusionReason == null
              ? _policy.classify(duration)
              : AssessmentIncidentClassification.excluded;

          if (classification == AssessmentIncidentClassification.ignored) {
            await _repository.clearPendingAbsence(pending.incidentId);
            _pendingAbsence = null;
            _recordObservation(event);
            return null;
          }

          final incident = AssessmentIncident(
            id: pending.incidentId,
            sessionId: pending.sessionId,
            leftAt: pending.leftAt,
            returnedAt: event.observedAt,
            duration: duration,
            classification: classification,
            reason: pending.exclusionReason ?? visibilityInterruptedReason,
          );

          // Upsert before clear. If clear is interrupted, the stable ID lets
          // recovery recognize the already finalized incident.
          await _repository.saveIncident(incident);
          await _repository.clearPendingAbsence(pending.incidentId);
          _pendingAbsence = null;
          _recordObservation(event);
          return incident;
      }
    });
  }

  /// Marks the current candidate as a known non-counting system event.
  ///
  /// The exclusion is durable and will remain excluded even if the session is
  /// closed before a resumed signal arrives.
  Future<bool> excludePendingAbsence(String reason) {
    return _enqueue(() async {
      await _ensureInitialized();
      final normalizedReason = reason.trim();
      if (normalizedReason.isEmpty) {
        throw ArgumentError.value(reason, 'reason', 'Must not be blank.');
      }

      final pending = _pendingAbsence;
      if (_activeSession == null || pending == null) {
        return false;
      }
      if (pending.exclusionReason == normalizedReason) {
        return true;
      }

      final excluded = pending.markExcluded(normalizedReason);
      await _repository.savePendingAbsence(excluded);
      _pendingAbsence = excluded;
      return true;
    });
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final activeSession = await _repository.loadActiveSession();
    final storedPending = await _repository.loadPendingAbsence();

    _activeSession = activeSession;
    if (storedPending != null) {
      final existing = await _repository.loadIncident(storedPending.incidentId);
      if (existing != null) {
        await _repository.clearPendingAbsence(storedPending.incidentId);
      } else {
        await _finalizeUnreturnedPending(storedPending);
      }
    }

    _initialized = true;
  }

  Future<void> _finalizeUnreturnedPending(PendingAbsence pending) async {
    final existing = await _repository.loadIncident(pending.incidentId);
    if (existing == null) {
      final incident = AssessmentIncident(
        id: pending.incidentId,
        sessionId: pending.sessionId,
        leftAt: pending.leftAt,
        returnedAt: null,
        duration: null,
        classification: pending.exclusionReason == null
            ? AssessmentIncidentClassification.unresolved
            : AssessmentIncidentClassification.excluded,
        reason: pending.exclusionReason ?? unresolvedReason,
      );
      await _repository.saveIncident(incident);
    }
    await _repository.clearPendingAbsence(pending.incidentId);
  }

  void _recordObservation(PresenceEvent event) {
    _lastPresenceState = event.state;
    _lastObservationAt = event.observedAt;
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _operationTail = _operationTail.then((_) async {
      try {
        result.complete(await operation());
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  static String _defaultIncidentId(String sessionId, DateTime leftAt) {
    return 'incident-$sessionId-${leftAt.toUtc().microsecondsSinceEpoch}';
  }
}
