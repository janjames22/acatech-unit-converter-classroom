import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_incident.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/domain/models/pending_absence.dart';
import 'package:unit_converter/features/assessment/domain/models/presence_event.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 28, 13);

  group('assessment model serialization', () {
    test('round-trips active and ended sessions through a plain map', () {
      final active = AssessmentSession(
        id: 'session-1',
        studentName: 'Juan Dela Cruz',
        assessmentName: 'Physics Quiz',
        startedAt: startedAt,
        plannedDuration: const Duration(minutes: 60),
      );
      final ended = active.end(startedAt.add(const Duration(minutes: 45)));

      expect(AssessmentSession.fromJson(active.toJson()), active);
      expect(AssessmentSession.fromJson(ended.toJson()), ended);
      expect(active.status, AssessmentSessionStatus.active);
      expect(ended.status, AssessmentSessionStatus.ended);
    });

    test('round-trips every incident classification', () {
      for (final classification in AssessmentIncidentClassification.values) {
        final hasReturn =
            classification != AssessmentIncidentClassification.unresolved &&
            classification != AssessmentIncidentClassification.excluded;
        final returnedAt = hasReturn
            ? startedAt.add(const Duration(seconds: 4))
            : null;
        final incident = AssessmentIncident(
          id: 'incident-${classification.name}',
          sessionId: 'session-1',
          leftAt: startedAt,
          returnedAt: returnedAt,
          duration: returnedAt?.difference(startedAt),
          classification: classification,
          reason: 'Neutral visibility observation.',
        );

        expect(AssessmentIncident.fromJson(incident.toJson()), incident);
      }
    });

    test('round-trips presence events and pending absence records', () {
      final event = PresenceEvent(
        state: AssessmentPresenceState.hidden,
        observedAt: startedAt,
      );
      final pending = PendingAbsence(
        incidentId: 'incident-1',
        sessionId: 'session-1',
        leftAt: startedAt,
        trigger: AssessmentPresenceState.hidden,
      ).markExcluded('Device screen was off.');

      expect(PresenceEvent.fromJson(event.toJson()), event);
      expect(PendingAbsence.fromJson(pending.toJson()), pending);
    });
  });

  group('assessment model invariants', () {
    test('session end cannot precede its start', () {
      expect(
        () => AssessmentSession(
          id: 'session-1',
          studentName: 'Student',
          assessmentName: 'Quiz',
          startedAt: startedAt,
          endedAt: startedAt.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('incident timestamps and duration must agree', () {
      expect(
        () => AssessmentIncident(
          id: 'incident-1',
          sessionId: 'session-1',
          leftAt: startedAt,
          returnedAt: startedAt.add(const Duration(seconds: 3)),
          duration: const Duration(seconds: 2),
          classification: AssessmentIncidentClassification.review,
          reason: 'Application visibility was interrupted.',
        ),
        throwsArgumentError,
      );
    });

    test('only hidden and paused can trigger pending absence', () {
      expect(
        () => PendingAbsence(
          incidentId: 'incident-1',
          sessionId: 'session-1',
          leftAt: startedAt,
          trigger: AssessmentPresenceState.inactive,
        ),
        throwsArgumentError,
      );
    });
  });
}
