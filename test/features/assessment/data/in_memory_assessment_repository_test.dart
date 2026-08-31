import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_incident.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/domain/models/pending_absence.dart';
import 'package:unit_converter/features/assessment/domain/models/presence_event.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 28, 13);

  AssessmentSession session(String id) => AssessmentSession(
    id: id,
    studentName: 'Student',
    assessmentName: 'Quiz',
    startedAt: startedAt,
  );

  AssessmentIncident incident(
    String id, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return AssessmentIncident(
      id: id,
      sessionId: 'session-1',
      leftAt: startedAt,
      returnedAt: startedAt.add(duration),
      duration: duration,
      classification: AssessmentIncidentClassification.review,
      reason: 'Application visibility was interrupted.',
    );
  }

  group('InMemoryAssessmentRepository', () {
    test('upserts sessions and finds the active session', () async {
      final repository = InMemoryAssessmentRepository();
      final active = session('session-1');

      await repository.saveSession(active);
      expect(await repository.loadActiveSession(), active);

      final ended = active.end(startedAt.add(const Duration(minutes: 5)));
      await repository.saveSession(ended);
      expect(await repository.loadSession(active.id), ended);
      expect(await repository.loadActiveSession(), isNull);
      expect(await repository.loadSessions(), <AssessmentSession>[ended]);
    });

    test('upserts incidents by stable ID instead of duplicating', () async {
      final repository = InMemoryAssessmentRepository();
      final original = incident('incident-1');
      final replacement = incident(
        'incident-1',
        duration: const Duration(seconds: 4),
      );

      await repository.saveIncident(original);
      await repository.saveIncident(replacement);

      expect(await repository.loadIncident('incident-1'), replacement);
      expect(await repository.loadIncidents('session-1'), <AssessmentIncident>[
        replacement,
      ]);
    });

    test('clears only the expected pending incident ID', () async {
      final pending = PendingAbsence(
        incidentId: 'incident-1',
        sessionId: 'session-1',
        leftAt: startedAt,
        trigger: AssessmentPresenceState.hidden,
      );
      final repository = InMemoryAssessmentRepository(pendingAbsence: pending);

      await repository.clearPendingAbsence('another-incident');
      expect(await repository.loadPendingAbsence(), pending);

      await repository.clearPendingAbsence(pending.incidentId);
      expect(await repository.loadPendingAbsence(), isNull);
    });

    test('reports corrupt state with multiple active sessions', () async {
      final repository = InMemoryAssessmentRepository(
        sessions: <AssessmentSession>[
          session('session-1'),
          session('session-2'),
        ],
      );

      await expectLater(repository.loadActiveSession(), throwsStateError);
    });

    test('deleteAll clears sessions, incidents, and pending state', () async {
      final pending = PendingAbsence(
        incidentId: 'incident-1',
        sessionId: 'session-1',
        leftAt: startedAt,
        trigger: AssessmentPresenceState.paused,
      );
      final repository = InMemoryAssessmentRepository(
        sessions: <AssessmentSession>[session('session-1')],
        incidents: <AssessmentIncident>[incident('incident-1')],
        pendingAbsence: pending,
      );

      await repository.deleteAll();

      expect(await repository.loadSessions(), isEmpty);
      expect(await repository.loadIncidents('session-1'), isEmpty);
      expect(await repository.loadPendingAbsence(), isNull);
    });
  });
}
