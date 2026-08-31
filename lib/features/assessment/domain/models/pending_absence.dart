import 'presence_event.dart';

/// Durable state created as soon as an active session becomes hidden/paused.
///
/// Reusing [incidentId] when finalizing makes recovery idempotent if the app
/// stops between saving the incident and clearing this record.
final class PendingAbsence {
  PendingAbsence({
    required this.incidentId,
    required this.sessionId,
    required this.leftAt,
    required this.trigger,
    this.exclusionReason,
  }) {
    if (incidentId.trim().isEmpty) {
      throw ArgumentError.value(incidentId, 'incidentId', 'Must not be empty.');
    }
    if (sessionId.trim().isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'Must not be empty.');
    }
    if (trigger != AssessmentPresenceState.hidden &&
        trigger != AssessmentPresenceState.paused) {
      throw ArgumentError.value(
        trigger,
        'trigger',
        'Only hidden or paused may start an absence candidate.',
      );
    }
    if (exclusionReason != null && exclusionReason!.trim().isEmpty) {
      throw ArgumentError.value(
        exclusionReason,
        'exclusionReason',
        'Must not be blank when supplied.',
      );
    }
  }

  final String incidentId;
  final String sessionId;
  final DateTime leftAt;
  final AssessmentPresenceState trigger;
  final String? exclusionReason;

  PendingAbsence markExcluded(String reason) {
    return PendingAbsence(
      incidentId: incidentId,
      sessionId: sessionId,
      leftAt: leftAt,
      trigger: trigger,
      exclusionReason: reason,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'incidentId': incidentId,
    'sessionId': sessionId,
    'leftAt': leftAt.toUtc().toIso8601String(),
    'trigger': trigger.name,
    'exclusionReason': exclusionReason,
  };

  factory PendingAbsence.fromJson(Map<String, Object?> json) {
    return PendingAbsence(
      incidentId: json['incidentId']! as String,
      sessionId: json['sessionId']! as String,
      leftAt: DateTime.parse(json['leftAt']! as String),
      trigger: AssessmentPresenceState.values.byName(
        json['trigger']! as String,
      ),
      exclusionReason: json['exclusionReason'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PendingAbsence &&
            incidentId == other.incidentId &&
            sessionId == other.sessionId &&
            leftAt.microsecondsSinceEpoch ==
                other.leftAt.microsecondsSinceEpoch &&
            trigger == other.trigger &&
            exclusionReason == other.exclusionReason;
  }

  @override
  int get hashCode => Object.hash(
    incidentId,
    sessionId,
    leftAt.microsecondsSinceEpoch,
    trigger,
    exclusionReason,
  );

  @override
  String toString() {
    return 'PendingAbsence(incidentId: $incidentId, sessionId: $sessionId, '
        'leftAt: $leftAt, excluded: ${exclusionReason != null})';
  }
}
