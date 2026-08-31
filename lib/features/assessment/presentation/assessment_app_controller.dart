import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../application/assessment_monitor.dart';
import '../domain/models/assessment_incident.dart';
import '../domain/models/assessment_session.dart';
import '../domain/models/presence_event.dart';
import '../domain/repositories/assessment_repository.dart';
import '../infrastructure/system_presence_bridge.dart';

/// Root-owned application controller. It intentionally has no navigation
/// dependency, so route and responsive-layout changes cannot recreate or arm
/// the monitor.
final class AssessmentAppController extends ChangeNotifier {
  AssessmentAppController(this._repository, this._monitor);

  final AssessmentRepository _repository;
  final AssessmentMonitor _monitor;
  final Map<String, List<AssessmentIncident>> _incidents = {};
  List<AssessmentSession> _sessions = const [];
  Timer? _ticker;
  bool _knownLockActive = false;
  int _presenceSuppressionDepth = 0;
  bool _suppressedDepartureObserved = false;
  bool _suppressThroughNextResume = false;
  bool _busy = false;
  bool _disposed = false;
  String? _errorMessage;

  AssessmentMonitor get monitor => _monitor;
  AssessmentSession? get activeSession => _monitor.activeSession;
  List<AssessmentSession> get sessions => List.unmodifiable(_sessions);
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  bool get hasActiveSession => activeSession != null;

  /// Whether lifecycle observations are currently excluded because the app
  /// intentionally opened trusted system or browser UI.
  ///
  /// This is deliberately narrow: ordinary Flutter routes, menus, dialogs,
  /// and keyboard activity never need suppression because they do not enter
  /// the lifecycle monitoring pipeline in the first place.
  bool get isPresenceMonitoringSuppressed =>
      _presenceSuppressionDepth > 0 || _suppressThroughNextResume;

  List<AssessmentIncident> incidentsFor(String sessionId) =>
      List.unmodifiable(_incidents[sessionId] ?? const []);

  List<AssessmentIncident> get activeIncidents {
    final session = activeSession;
    return session == null ? const [] : incidentsFor(session.id);
  }

  Duration? get remainingTime {
    final session = activeSession;
    final duration = session?.plannedDuration;
    if (session == null || duration == null) {
      return null;
    }
    final remaining = session.startedAt
        .add(duration)
        .difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int get reviewCount => activeIncidents
      .where(
        (incident) =>
            incident.classification == AssessmentIncidentClassification.review,
      )
      .length;

  int get extendedCount => activeIncidents
      .where(
        (incident) =>
            incident.classification ==
            AssessmentIncidentClassification.extendedAbsence,
      )
      .length;

  int get unresolvedCount => activeIncidents
      .where(
        (incident) =>
            incident.classification ==
            AssessmentIncidentClassification.unresolved,
      )
      .length;

  Future<void> initialize() async {
    await _run(() async {
      await _monitor.initialize();
      await _reloadReports();
      _syncTicker();
    });
  }

  Future<void> startSession({
    required String studentName,
    required String assessmentName,
    required Duration plannedDuration,
  }) async {
    await _run(() async {
      final now = DateTime.now().toUtc();
      await _monitor.startSession(
        AssessmentSession(
          id: 'session-${now.microsecondsSinceEpoch}',
          studentName: studentName.trim(),
          assessmentName: assessmentName.trim(),
          startedAt: now,
          plannedDuration: plannedDuration,
        ),
      );
      await _reloadReports();
      _syncTicker();
    });
  }

  Future<void> endSession() async {
    await _run(() async {
      await _monitor.endSession();
      await _reloadReports();
      _syncTicker();
    });
  }

  Future<void> deleteHistory() async {
    if (hasActiveSession) {
      throw StateError('End the active assessment before deleting history.');
    }
    await _run(() async {
      await _repository.deleteAll();
      await _reloadReports();
    });
  }

  /// Runs [operation] without treating lifecycle changes caused by trusted
  /// system UI as an assessment absence.
  ///
  /// Browser installation prompts are the primary use case. Some browsers
  /// complete the prompt future before Flutter delivers the corresponding
  /// resumed callback, so a departure observed during this scope keeps the
  /// guard active through that next resume.
  Future<T> runWithPresenceMonitoringSuppressed<T>(
    Future<T> Function() operation,
  ) async {
    _presenceSuppressionDepth++;
    _safeNotify();
    try {
      return await operation();
    } finally {
      _presenceSuppressionDepth--;
      if (_presenceSuppressionDepth == 0 && !_suppressedDepartureObserved) {
        _suppressThroughNextResume = false;
      }
      _safeNotify();
    }
  }

  Future<void> handleLifecycleState(AppLifecycleState state) async {
    final presence = switch (state) {
      AppLifecycleState.resumed => AssessmentPresenceState.resumed,
      AppLifecycleState.inactive =>
        kIsWeb
            ? AssessmentPresenceState.hidden
            : AssessmentPresenceState.inactive,
      AppLifecycleState.hidden => AssessmentPresenceState.hidden,
      AppLifecycleState.paused => AssessmentPresenceState.paused,
      AppLifecycleState.detached => AssessmentPresenceState.paused,
    };

    if (isPresenceMonitoringSuppressed) {
      switch (presence) {
        case AssessmentPresenceState.hidden:
        case AssessmentPresenceState.paused:
          _suppressedDepartureObserved = true;
          _suppressThroughNextResume = true;
          break;
        case AssessmentPresenceState.resumed:
          _suppressedDepartureObserved = false;
          _suppressThroughNextResume = false;
          _knownLockActive = false;
          break;
        case AssessmentPresenceState.inactive:
          break;
      }
      _safeNotify();
      return;
    }

    try {
      final incident = await _monitor.handlePresenceState(presence);
      if (_knownLockActive &&
          presence != AssessmentPresenceState.resumed &&
          _monitor.pendingAbsence != null) {
        await _monitor.excludePendingAbsence(
          'Screen off or device lock was detected.',
        );
      }
      if (presence == AssessmentPresenceState.resumed) {
        _knownLockActive = false;
      }
      if (incident != null) {
        await _reloadReports();
      }
      _safeNotify();
    } on Object catch (error) {
      _errorMessage = 'Presence event could not be saved: $error';
      _safeNotify();
    }
  }

  Future<void> handleSystemPresenceSignal(SystemPresenceSignal signal) async {
    switch (signal) {
      case SystemPresenceSignal.screenOff:
      case SystemPresenceSignal.deviceLocked:
        _knownLockActive = true;
        if (_monitor.pendingAbsence != null) {
          await _monitor.excludePendingAbsence(
            'Screen off or device lock was detected.',
          );
        }
      case SystemPresenceSignal.screenOn:
      case SystemPresenceSignal.deviceUnlocked:
        // Keep the exclusion active until Flutter reports resumed. Screen-on
        // does not guarantee that the keyguard has been dismissed.
        break;
    }
    _safeNotify();
  }

  Future<void> refreshReports() => _run(_reloadReports);

  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  Future<void> _reloadReports() async {
    final sessions = await _repository.loadSessions();
    final loadedIncidents = <String, List<AssessmentIncident>>{};
    for (final session in sessions) {
      loadedIncidents[session.id] = await _repository.loadIncidents(session.id);
    }
    _sessions = List.unmodifiable(sessions);
    _incidents
      ..clear()
      ..addAll(loadedIncidents);
  }

  Future<void> _run(Future<void> Function() operation) async {
    _busy = true;
    _errorMessage = null;
    _safeNotify();
    try {
      await operation();
    } on Object catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (hasActiveSession) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _safeNotify(),
      );
    }
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
