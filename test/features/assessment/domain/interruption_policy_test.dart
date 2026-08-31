import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_incident.dart';
import 'package:unit_converter/features/assessment/domain/services/interruption_policy.dart';

void main() {
  const policy = InterruptionPolicy();

  group('InterruptionPolicy', () {
    test('ignores durations strictly below two seconds', () {
      expect(
        policy.classify(Duration.zero),
        AssessmentIncidentClassification.ignored,
      );
      expect(
        policy.classify(const Duration(microseconds: 1999999)),
        AssessmentIncidentClassification.ignored,
      );
    });

    test('classifies exactly two seconds through below ten as review', () {
      expect(
        policy.classify(const Duration(seconds: 2)),
        AssessmentIncidentClassification.review,
      );
      expect(
        policy.classify(const Duration(microseconds: 9999999)),
        AssessmentIncidentClassification.review,
      );
    });

    test('classifies exactly ten seconds and above as extended absence', () {
      expect(
        policy.classify(const Duration(seconds: 10)),
        AssessmentIncidentClassification.extendedAbsence,
      );
      expect(
        policy.classify(const Duration(hours: 1)),
        AssessmentIncidentClassification.extendedAbsence,
      );
    });

    test('rejects negative durations', () {
      expect(
        () => policy.classify(const Duration(microseconds: -1)),
        throwsArgumentError,
      );
    });
  });
}
