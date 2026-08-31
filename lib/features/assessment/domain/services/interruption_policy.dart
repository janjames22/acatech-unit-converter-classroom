import '../models/assessment_incident.dart';

/// The fixed v2 interruption thresholds from the assessment brief.
final class InterruptionPolicy {
  const InterruptionPolicy();

  static const Duration reviewThreshold = Duration(seconds: 2);
  static const Duration extendedAbsenceThreshold = Duration(seconds: 10);

  AssessmentIncidentClassification classify(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration', 'Must not be negative.');
    }
    if (duration < reviewThreshold) {
      return AssessmentIncidentClassification.ignored;
    }
    if (duration < extendedAbsenceThreshold) {
      return AssessmentIncidentClassification.review;
    }
    return AssessmentIncidentClassification.extendedAbsence;
  }
}
