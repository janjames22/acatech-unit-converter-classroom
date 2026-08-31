import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/features/assessment/data/shared_preferences_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_incident.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/domain/models/pending_absence.dart';
import 'package:unit_converter/features/assessment/domain/models/presence_event.dart';

void main() {
  late SharedPreferencesAssessmentRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = SharedPreferencesAssessmentRepository(
      await SharedPreferences.getInstance(),
    );
  });

  test(
    'persists and restores sessions, incidents, and pending state',
    () async {
      final startedAt = DateTime.utc(2026, 8, 28, 9);
      final session = AssessmentSession(
        id: 'session-1',
        studentName: 'Student 1',
        assessmentName: 'Physics quiz',
        startedAt: startedAt,
        plannedDuration: const Duration(minutes: 60),
      );
      final pending = PendingAbsence(
        incidentId: 'incident-1',
        sessionId: session.id,
        leftAt: startedAt.add(const Duration(minutes: 5)),
        trigger: AssessmentPresenceState.hidden,
      );
      final incident = AssessmentIncident(
        id: pending.incidentId,
        sessionId: session.id,
        leftAt: pending.leftAt,
        returnedAt: pending.leftAt.add(const Duration(seconds: 12)),
        duration: const Duration(seconds: 12),
        classification: AssessmentIncidentClassification.extendedAbsence,
        reason: 'Application visibility was interrupted.',
      );

      await repository.saveSession(session);
      await repository.savePendingAbsence(pending);
      await repository.saveIncident(incident);

      expect(await repository.loadActiveSession(), session);
      expect(await repository.loadPendingAbsence(), pending);
      expect(await repository.loadIncidents(session.id), <AssessmentIncident>[
        incident,
      ]);
    },
  );

  test('upserts records and deletes only assessment data', () async {
    final startedAt = DateTime.utc(2026, 8, 28, 9);
    final session = AssessmentSession(
      id: 'session-1',
      studentName: 'Student 1',
      assessmentName: 'Quiz',
      startedAt: startedAt,
    );
    await repository.saveSession(session);
    await repository.saveSession(
      session.end(startedAt.add(const Duration(minutes: 2))),
    );

    expect((await repository.loadSessions()), hasLength(1));
    expect((await repository.loadSessions()).single.isActive, isFalse);

    await repository.deleteAll();
    expect(await repository.loadSessions(), isEmpty);
    expect(await repository.loadPendingAbsence(), isNull);
  });
}
