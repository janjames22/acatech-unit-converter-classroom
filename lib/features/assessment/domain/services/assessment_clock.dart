abstract interface class AssessmentClock {
  DateTime now();
}

final class SystemAssessmentClock implements AssessmentClock {
  const SystemAssessmentClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
