enum AssessmentSessionStatus { active, ended }

/// A locally managed assessment session.
///
/// The model deliberately contains no claims about student intent. It only
/// describes when monitoring was active and the labels supplied by a teacher.
final class AssessmentSession {
  AssessmentSession({
    required this.id,
    required this.studentName,
    required this.assessmentName,
    required this.startedAt,
    this.plannedDuration,
    this.endedAt,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
    if (studentName.trim().isEmpty) {
      throw ArgumentError.value(
        studentName,
        'studentName',
        'Must not be empty.',
      );
    }
    if (assessmentName.trim().isEmpty) {
      throw ArgumentError.value(
        assessmentName,
        'assessmentName',
        'Must not be empty.',
      );
    }
    if (plannedDuration case final duration? when duration <= Duration.zero) {
      throw ArgumentError.value(
        duration,
        'plannedDuration',
        'Must be greater than zero.',
      );
    }
    if (endedAt case final end? when end.isBefore(startedAt)) {
      throw ArgumentError.value(
        end,
        'endedAt',
        'Must not be before startedAt.',
      );
    }
  }

  final String id;
  final String studentName;
  final String assessmentName;
  final DateTime startedAt;
  final Duration? plannedDuration;
  final DateTime? endedAt;

  AssessmentSessionStatus get status => endedAt == null
      ? AssessmentSessionStatus.active
      : AssessmentSessionStatus.ended;

  bool get isActive => status == AssessmentSessionStatus.active;

  AssessmentSession end(DateTime at) {
    if (endedAt != null) {
      return this;
    }
    return AssessmentSession(
      id: id,
      studentName: studentName,
      assessmentName: assessmentName,
      startedAt: startedAt,
      plannedDuration: plannedDuration,
      endedAt: at,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'studentName': studentName,
    'assessmentName': assessmentName,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'plannedDurationMicroseconds': plannedDuration?.inMicroseconds,
    'endedAt': endedAt?.toUtc().toIso8601String(),
  };

  factory AssessmentSession.fromJson(Map<String, Object?> json) {
    final plannedDurationMicroseconds =
        json['plannedDurationMicroseconds'] as int?;
    final endedAt = json['endedAt'] as String?;

    return AssessmentSession(
      id: json['id']! as String,
      studentName: json['studentName']! as String,
      assessmentName: json['assessmentName']! as String,
      startedAt: DateTime.parse(json['startedAt']! as String),
      plannedDuration: plannedDurationMicroseconds == null
          ? null
          : Duration(microseconds: plannedDurationMicroseconds),
      endedAt: endedAt == null ? null : DateTime.parse(endedAt),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssessmentSession &&
            id == other.id &&
            studentName == other.studentName &&
            assessmentName == other.assessmentName &&
            startedAt.microsecondsSinceEpoch ==
                other.startedAt.microsecondsSinceEpoch &&
            plannedDuration == other.plannedDuration &&
            endedAt?.microsecondsSinceEpoch ==
                other.endedAt?.microsecondsSinceEpoch;
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentName,
    assessmentName,
    startedAt.microsecondsSinceEpoch,
    plannedDuration,
    endedAt?.microsecondsSinceEpoch,
  );

  @override
  String toString() {
    return 'AssessmentSession(id: $id, status: ${status.name}, '
        'assessmentName: $assessmentName)';
  }
}
