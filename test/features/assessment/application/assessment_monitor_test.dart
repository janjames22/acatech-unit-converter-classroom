import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_incident.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/domain/models/pending_absence.dart';
import 'package:unit_converter/features/assessment/domain/models/presence_event.dart';
import 'package:unit_converter/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/services/assessment_clock.dart';

void main() {
  group('AssessmentMonitor lifecycle state machine', () {
    test('does nothing when no assessment session is active', () async {
      final repository = InMemoryAssessmentRepository();
      final clock = _FakeAssessmentClock(_epoch);
      final monitor = _monitor(repository, clock);

      await monitor.handlePresenceState(AssessmentPresenceState.hidden);
      clock.advance(const Duration(seconds: 20));
      await monitor.handlePresenceState(AssessmentPresenceState.resumed);

      expect(monitor.status, AssessmentMonitorStatus.idle);
      expect(await repository.loadPendingAbsence(), isNull);
      expect(await repository.loadIncidents('session-1'), isEmpty);
    });

    test('ignores an inactive-only focus loss', () async {
      final harness = await _Harness.active();

      await harness.monitor.handlePresenceState(
        AssessmentPresenceState.inactive,
      );
      harness.clock.advance(const Duration(seconds: 30));
      final incident = await harness.monitor.handlePresenceState(
        AssessmentPresenceState.resumed,
      );

      expect(incident, isNull);
      expect(harness.monitor.pendingAbsence, isNull);
      expect(
        await harness.repository.loadIncidents(harness.session.id),
        isEmpty,
      );
    });

    test(
      'persists hidden immediately and coalesces hidden/paused signals',
      () async {
        final harness = await _Harness.active();

        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.inactive,
        );
        harness.clock.advance(const Duration(seconds: 1));
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.hidden,
        );
        final original = harness.monitor.pendingAbsence;

        expect(original, isNotNull);
        expect(await harness.repository.loadPendingAbsence(), original);
        expect(original!.leftAt, harness.clock.now());

        harness.clock.advance(const Duration(seconds: 1));
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.paused,
        );
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.hidden,
        );

        expect(harness.monitor.pendingAbsence, original);
        expect(await harness.repository.loadPendingAbsence(), original);
      },
    );

    test('paused starts a candidate when hidden is skipped', () async {
      final harness = await _Harness.active();

      await harness.monitor.handlePresenceState(AssessmentPresenceState.paused);

      expect(
        harness.monitor.pendingAbsence?.trigger,
        AssessmentPresenceState.paused,
      );
      expect(
        await harness.repository.loadPendingAbsence(),
        harness.monitor.pendingAbsence,
      );
    });

    final thresholdCases =
        <
          ({
            String name,
            Duration duration,
            AssessmentIncidentClassification? expected,
          })
        >[
          (
            name: 'below two seconds is ignored',
            duration: const Duration(microseconds: 1999999),
            expected: null,
          ),
          (
            name: 'exactly two seconds is review',
            duration: const Duration(seconds: 2),
            expected: AssessmentIncidentClassification.review,
          ),
          (
            name: 'below ten seconds is review',
            duration: const Duration(microseconds: 9999999),
            expected: AssessmentIncidentClassification.review,
          ),
          (
            name: 'exactly ten seconds is extended absence',
            duration: const Duration(seconds: 10),
            expected: AssessmentIncidentClassification.extendedAbsence,
          ),
        ];

    for (final thresholdCase in thresholdCases) {
      test(thresholdCase.name, () async {
        final harness = await _Harness.active();
        final leftAt = harness.clock.now();

        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.hidden,
        );
        harness.clock.advance(thresholdCase.duration);
        final incident = await harness.monitor.handlePresenceState(
          AssessmentPresenceState.resumed,
        );

        if (thresholdCase.expected == null) {
          expect(incident, isNull);
          expect(
            await harness.repository.loadIncidents(harness.session.id),
            isEmpty,
          );
        } else {
          expect(incident?.classification, thresholdCase.expected);
          expect(incident?.leftAt, leftAt);
          expect(incident?.returnedAt, harness.clock.now());
          expect(incident?.duration, thresholdCase.duration);
          expect(
            await harness.repository.loadIncidents(harness.session.id),
            <AssessmentIncident>[incident!],
          );
        }
        expect(harness.monitor.pendingAbsence, isNull);
        expect(await harness.repository.loadPendingAbsence(), isNull);
      });
    }

    test('inactive while hidden does not reset the departure time', () async {
      final harness = await _Harness.active();
      final leftAt = harness.clock.now();

      await harness.monitor.handlePresenceState(AssessmentPresenceState.hidden);
      harness.clock.advance(const Duration(seconds: 4));
      await harness.monitor.handlePresenceState(
        AssessmentPresenceState.inactive,
      );
      harness.clock.advance(const Duration(seconds: 7));
      final incident = await harness.monitor.handlePresenceState(
        AssessmentPresenceState.resumed,
      );

      expect(incident?.leftAt, leftAt);
      expect(incident?.duration, const Duration(seconds: 11));
      expect(
        incident?.classification,
        AssessmentIncidentClassification.extendedAbsence,
      );
    });

    test('stale observations cannot close or replace a candidate', () async {
      final harness = await _Harness.active();
      harness.clock.advance(const Duration(seconds: 5));
      final leftAt = harness.clock.now();
      await harness.monitor.handlePresenceState(AssessmentPresenceState.hidden);

      final staleResult = await harness.monitor.handlePresence(
        PresenceEvent(
          state: AssessmentPresenceState.resumed,
          observedAt: leftAt.subtract(const Duration(seconds: 1)),
        ),
      );

      expect(staleResult, isNull);
      expect(harness.monitor.pendingAbsence?.leftAt, leftAt);

      harness.clock.advance(const Duration(seconds: 2));
      final incident = await harness.monitor.handlePresenceState(
        AssessmentPresenceState.resumed,
      );
      expect(incident?.classification, AssessmentIncidentClassification.review);
    });

    test('serializes rapid lifecycle callbacks in call order', () async {
      final harness = await _Harness.active();
      final start = harness.clock.now();

      await Future.wait(<Future<AssessmentIncident?>>[
        harness.monitor.handlePresence(
          PresenceEvent(
            state: AssessmentPresenceState.inactive,
            observedAt: start,
          ),
        ),
        harness.monitor.handlePresence(
          PresenceEvent(
            state: AssessmentPresenceState.hidden,
            observedAt: start.add(const Duration(seconds: 1)),
          ),
        ),
        harness.monitor.handlePresence(
          PresenceEvent(
            state: AssessmentPresenceState.paused,
            observedAt: start.add(const Duration(seconds: 2)),
          ),
        ),
        harness.monitor.handlePresence(
          PresenceEvent(
            state: AssessmentPresenceState.resumed,
            observedAt: start.add(const Duration(seconds: 12)),
          ),
        ),
      ]);

      final incidents = await harness.repository.loadIncidents(
        harness.session.id,
      );
      expect(incidents, hasLength(1));
      expect(incidents.single.leftAt, start.add(const Duration(seconds: 1)));
      expect(incidents.single.duration, const Duration(seconds: 11));
    });
  });

  group('AssessmentMonitor recovery and idempotency', () {
    test(
      'finalizes a restarted candidate as unresolved and keeps session active',
      () async {
        final session = _session(startedAt: _epoch);
        final pending = PendingAbsence(
          incidentId: 'persisted-incident-id',
          sessionId: session.id,
          leftAt: _epoch.add(const Duration(seconds: 1)),
          trigger: AssessmentPresenceState.hidden,
        );
        final repository = InMemoryAssessmentRepository(
          sessions: <AssessmentSession>[session],
          pendingAbsence: pending,
        );
        final clock = _FakeAssessmentClock(
          _epoch.add(const Duration(seconds: 12)),
        );
        final monitor = _monitor(repository, clock);

        await monitor.initialize();
        expect(monitor.status, AssessmentMonitorStatus.active);
        expect(monitor.pendingAbsence, isNull);
        expect(await repository.loadPendingAbsence(), isNull);

        final incidents = await repository.loadIncidents(session.id);
        expect(incidents, hasLength(1));
        expect(incidents.single.id, pending.incidentId);
        expect(incidents.single.leftAt, pending.leftAt);
        expect(
          incidents.single.classification,
          AssessmentIncidentClassification.unresolved,
        );
        expect(incidents.single.returnedAt, isNull);

        final resumed = await monitor.handlePresenceState(
          AssessmentPresenceState.resumed,
        );
        expect(resumed, isNull);
        expect(await repository.loadIncidents(session.id), hasLength(1));
      },
    );

    test(
      'clears stale pending state when its incident was already saved',
      () async {
        final session = _session(startedAt: _epoch);
        final returnedAt = _epoch.add(const Duration(seconds: 5));
        final incident = AssessmentIncident(
          id: 'incident-1',
          sessionId: session.id,
          leftAt: _epoch,
          returnedAt: returnedAt,
          duration: const Duration(seconds: 5),
          classification: AssessmentIncidentClassification.review,
          reason: AssessmentMonitor.visibilityInterruptedReason,
        );
        final pending = PendingAbsence(
          incidentId: incident.id,
          sessionId: session.id,
          leftAt: incident.leftAt,
          trigger: AssessmentPresenceState.hidden,
        );
        final repository = InMemoryAssessmentRepository(
          sessions: <AssessmentSession>[session],
          incidents: <AssessmentIncident>[incident],
          pendingAbsence: pending,
        );
        final monitor = _monitor(
          repository,
          _FakeAssessmentClock(_epoch.add(const Duration(seconds: 20))),
        );

        await monitor.initialize();

        expect(monitor.status, AssessmentMonitorStatus.active);
        expect(await repository.loadPendingAbsence(), isNull);
        expect(await repository.loadIncident(incident.id), incident);
      },
    );

    test('orphaned pending state becomes one unresolved incident', () async {
      final pending = PendingAbsence(
        incidentId: 'incident-1',
        sessionId: 'ended-session',
        leftAt: _epoch,
        trigger: AssessmentPresenceState.paused,
      );
      final repository = InMemoryAssessmentRepository(pendingAbsence: pending);
      final monitor = _monitor(repository, _FakeAssessmentClock(_epoch));

      await monitor.initialize();
      await monitor.initialize();

      final incidents = await repository.loadIncidents(pending.sessionId);
      expect(incidents, hasLength(1));
      expect(
        incidents.single.classification,
        AssessmentIncidentClassification.unresolved,
      );
      expect(incidents.single.returnedAt, isNull);
      expect(await repository.loadPendingAbsence(), isNull);
    });

    test(
      'ending a session finalizes a pending candidate as unresolved',
      () async {
        final harness = await _Harness.active();
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.hidden,
        );
        harness.clock.advance(const Duration(seconds: 20));

        final ended = await harness.monitor.endSession();

        expect(ended?.isActive, isFalse);
        expect(harness.monitor.status, AssessmentMonitorStatus.idle);
        expect(await harness.repository.loadActiveSession(), isNull);
        final incidents = await harness.repository.loadIncidents(
          harness.session.id,
        );
        expect(incidents, hasLength(1));
        expect(
          incidents.single.classification,
          AssessmentIncidentClassification.unresolved,
        );
        expect(incidents.single.returnedAt, isNull);
      },
    );

    test('repeated start and end commands are idempotent', () async {
      final harness = await _Harness.active();

      expect(
        await harness.monitor.startSession(harness.session),
        harness.session,
      );
      await expectLater(
        harness.monitor.startSession(
          _session(id: 'another-session', startedAt: _epoch),
        ),
        throwsStateError,
      );

      final firstEnd = await harness.monitor.endSession();
      final secondEnd = await harness.monitor.endSession();
      expect(firstEnd, isNotNull);
      expect(secondEnd, isNull);
      expect(await harness.repository.loadSessions(), hasLength(1));
    });

    test('a failed clear retries without changing a saved incident', () async {
      final backingRepository = InMemoryAssessmentRepository();
      final repository = _FailOnceClearRepository(backingRepository);
      final clock = _FakeAssessmentClock(_epoch);
      final monitor = _monitor(repository, clock);
      final session = _session(startedAt: clock.now());
      await monitor.startSession(session);
      await monitor.handlePresenceState(AssessmentPresenceState.hidden);
      clock.advance(const Duration(seconds: 10));
      final originalReturnTime = clock.now();
      repository.failNextClear = true;

      await expectLater(
        monitor.handlePresenceState(AssessmentPresenceState.resumed),
        throwsStateError,
      );
      expect(await backingRepository.loadIncidents(session.id), hasLength(1));
      expect(await backingRepository.loadPendingAbsence(), isNotNull);

      clock.advance(const Duration(seconds: 30));
      final recovered = await monitor.handlePresenceState(
        AssessmentPresenceState.resumed,
      );

      expect(recovered?.returnedAt, originalReturnTime);
      expect(await backingRepository.loadIncidents(session.id), hasLength(1));
      expect(await backingRepository.loadPendingAbsence(), isNull);
    });
  });

  group('AssessmentMonitor exclusions', () {
    test(
      'persists and returns an excluded candidate with neutral reason',
      () async {
        final harness = await _Harness.active();
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.hidden,
        );

        expect(
          await harness.monitor.excludePendingAbsence('Device screen was off.'),
          isTrue,
        );
        expect(
          (await harness.repository.loadPendingAbsence())?.exclusionReason,
          'Device screen was off.',
        );

        harness.clock.advance(const Duration(seconds: 30));
        final incident = await harness.monitor.handlePresenceState(
          AssessmentPresenceState.resumed,
        );
        expect(
          incident?.classification,
          AssessmentIncidentClassification.excluded,
        );
        expect(incident?.reason, 'Device screen was off.');
        expect(incident?.duration, const Duration(seconds: 30));
      },
    );

    test(
      'excluded pending state remains excluded if the session ends',
      () async {
        final harness = await _Harness.active();
        await harness.monitor.handlePresenceState(
          AssessmentPresenceState.paused,
        );
        await harness.monitor.excludePendingAbsence('Device was locked.');

        await harness.monitor.endSession();

        final incident = (await harness.repository.loadIncidents(
          harness.session.id,
        )).single;
        expect(
          incident.classification,
          AssessmentIncidentClassification.excluded,
        );
        expect(incident.reason, 'Device was locked.');
        expect(incident.returnedAt, isNull);
        expect(incident.duration, isNull);
      },
    );

    test(
      'exclusion is rejected when blank and ignored without a candidate',
      () async {
        final harness = await _Harness.active();

        expect(
          await harness.monitor.excludePendingAbsence('System dialog.'),
          isFalse,
        );
        await expectLater(
          harness.monitor.excludePendingAbsence('   '),
          throwsArgumentError,
        );
      },
    );
  });
}

final DateTime _epoch = DateTime.utc(2026, 8, 28, 13);

AssessmentSession _session({
  String id = 'session-1',
  required DateTime startedAt,
}) {
  return AssessmentSession(
    id: id,
    studentName: 'Juan Dela Cruz',
    assessmentName: 'Physics Quiz',
    startedAt: startedAt,
    plannedDuration: const Duration(minutes: 60),
  );
}

AssessmentMonitor _monitor(
  AssessmentRepository repository,
  AssessmentClock clock,
) {
  return AssessmentMonitor(
    repository: repository,
    clock: clock,
    incidentIdFactory: (sessionId, leftAt) =>
        'incident-$sessionId-${leftAt.microsecondsSinceEpoch}',
  );
}

final class _Harness {
  const _Harness({
    required this.repository,
    required this.clock,
    required this.monitor,
    required this.session,
  });

  final InMemoryAssessmentRepository repository;
  final _FakeAssessmentClock clock;
  final AssessmentMonitor monitor;
  final AssessmentSession session;

  static Future<_Harness> active() async {
    final repository = InMemoryAssessmentRepository();
    final clock = _FakeAssessmentClock(_epoch);
    final monitor = _monitor(repository, clock);
    final session = _session(startedAt: clock.now());
    await monitor.startSession(session);
    return _Harness(
      repository: repository,
      clock: clock,
      monitor: monitor,
      session: session,
    );
  }
}

final class _FakeAssessmentClock implements AssessmentClock {
  _FakeAssessmentClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}

final class _FailOnceClearRepository implements AssessmentRepository {
  _FailOnceClearRepository(this._delegate);

  final AssessmentRepository _delegate;
  bool failNextClear = false;

  @override
  Future<void> clearPendingAbsence(String incidentId) {
    if (failNextClear) {
      failNextClear = false;
      throw StateError('Simulated interrupted clear.');
    }
    return _delegate.clearPendingAbsence(incidentId);
  }

  @override
  Future<void> deleteAll() => _delegate.deleteAll();

  @override
  Future<AssessmentSession?> loadActiveSession() =>
      _delegate.loadActiveSession();

  @override
  Future<AssessmentIncident?> loadIncident(String id) =>
      _delegate.loadIncident(id);

  @override
  Future<List<AssessmentIncident>> loadIncidents(String sessionId) =>
      _delegate.loadIncidents(sessionId);

  @override
  Future<PendingAbsence?> loadPendingAbsence() =>
      _delegate.loadPendingAbsence();

  @override
  Future<AssessmentSession?> loadSession(String id) =>
      _delegate.loadSession(id);

  @override
  Future<List<AssessmentSession>> loadSessions() => _delegate.loadSessions();

  @override
  Future<void> saveIncident(AssessmentIncident incident) =>
      _delegate.saveIncident(incident);

  @override
  Future<void> savePendingAbsence(PendingAbsence pendingAbsence) =>
      _delegate.savePendingAbsence(pendingAbsence);

  @override
  Future<void> saveSession(AssessmentSession session) =>
      _delegate.saveSession(session);
}
