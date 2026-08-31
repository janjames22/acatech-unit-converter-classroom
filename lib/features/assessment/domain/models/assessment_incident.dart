enum AssessmentIncidentClassification {
  ignored,
  review,
  extendedAbsence,
  unresolved,
  excluded,
}

/// A neutral record of an observed application-visibility change.
final class AssessmentIncident {
  factory AssessmentIncident({
    required String id,
    required String sessionId,
    required DateTime leftAt,
    required DateTime? returnedAt,
    required Duration? duration,
    required AssessmentIncidentClassification classification,
    required String reason,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
    if (sessionId.trim().isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'Must not be empty.');
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Must not be empty.');
    }
    if ((returnedAt == null) != (duration == null)) {
      throw ArgumentError(
        'returnedAt and duration must either both be set or both be null.',
      );
    }
    if (returnedAt != null) {
      if (returnedAt.isBefore(leftAt)) {
        throw ArgumentError.value(
          returnedAt,
          'returnedAt',
          'Must not be before leftAt.',
        );
      }
      final observedDuration = returnedAt.difference(leftAt);
      if (duration != observedDuration) {
        throw ArgumentError.value(
          duration,
          'duration',
          'Must equal returnedAt - leftAt ($observedDuration).',
        );
      }
    }

    return AssessmentIncident._(
      id: id,
      sessionId: sessionId,
      leftAt: leftAt,
      returnedAt: returnedAt,
      duration: duration,
      classification: classification,
      reason: reason,
    );
  }

  const AssessmentIncident._({
    required this.id,
    required this.sessionId,
    required this.leftAt,
    required this.returnedAt,
    required this.duration,
    required this.classification,
    required this.reason,
  });

  final String id;
  final String sessionId;
  final DateTime leftAt;
  final DateTime? returnedAt;
  final Duration? duration;
  final AssessmentIncidentClassification classification;
  final String reason;

  int? get durationSeconds => duration?.inSeconds;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'sessionId': sessionId,
    'leftAt': leftAt.toUtc().toIso8601String(),
    'returnedAt': returnedAt?.toUtc().toIso8601String(),
    'durationMicroseconds': duration?.inMicroseconds,
    'classification': classification.name,
    'reason': reason,
  };

  factory AssessmentIncident.fromJson(Map<String, Object?> json) {
    final returnedAt = json['returnedAt'] as String?;
    final durationMicroseconds = json['durationMicroseconds'] as int?;

    return AssessmentIncident(
      id: json['id']! as String,
      sessionId: json['sessionId']! as String,
      leftAt: DateTime.parse(json['leftAt']! as String),
      returnedAt: returnedAt == null ? null : DateTime.parse(returnedAt),
      duration: durationMicroseconds == null
          ? null
          : Duration(microseconds: durationMicroseconds),
      classification: AssessmentIncidentClassification.values.byName(
        json['classification']! as String,
      ),
      reason: json['reason']! as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssessmentIncident &&
            id == other.id &&
            sessionId == other.sessionId &&
            leftAt.microsecondsSinceEpoch ==
                other.leftAt.microsecondsSinceEpoch &&
            returnedAt?.microsecondsSinceEpoch ==
                other.returnedAt?.microsecondsSinceEpoch &&
            duration == other.duration &&
            classification == other.classification &&
            reason == other.reason;
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    leftAt.microsecondsSinceEpoch,
    returnedAt?.microsecondsSinceEpoch,
    duration,
    classification,
    reason,
  );

  @override
  String toString() {
    return 'AssessmentIncident(id: $id, sessionId: $sessionId, '
        'classification: ${classification.name})';
  }
}
