enum Module2CompletionStatus { notStarted, inProgress, complete }

final class Module2Progress {
  const Module2Progress({
    this.viewedLessonIds = const <String>{},
    this.masteredQuestionIds = const <String>{},
    this.updatedAtUtc,
  });

  static const schemaVersion = 1;

  final Set<String> viewedLessonIds;
  final Set<String> masteredQuestionIds;
  final DateTime? updatedAtUtc;

  int get score => masteredQuestionIds.length;

  bool practiceCompleted(int questionCount) => score >= questionCount;

  Module2CompletionStatus completionStatus({
    required int lessonCount,
    required int questionCount,
  }) {
    if (viewedLessonIds.length >= lessonCount &&
        practiceCompleted(questionCount)) {
      return Module2CompletionStatus.complete;
    }
    if (viewedLessonIds.isNotEmpty || masteredQuestionIds.isNotEmpty) {
      return Module2CompletionStatus.inProgress;
    }
    return Module2CompletionStatus.notStarted;
  }

  Module2Progress copyWith({
    Set<String>? viewedLessonIds,
    Set<String>? masteredQuestionIds,
    DateTime? updatedAtUtc,
  }) {
    return Module2Progress(
      viewedLessonIds: Set.unmodifiable(
        viewedLessonIds ?? this.viewedLessonIds,
      ),
      masteredQuestionIds: Set.unmodifiable(
        masteredQuestionIds ?? this.masteredQuestionIds,
      ),
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  Map<String, Object?> toJson({
    required int lessonCount,
    required int questionCount,
  }) => <String, Object?>{
    'schemaVersion': schemaVersion,
    'moduleId': 'module_02',
    'viewedLessonIds': viewedLessonIds.toList()..sort(),
    'masteredQuestionIds': masteredQuestionIds.toList()..sort(),
    'lessonViewed': viewedLessonIds.isNotEmpty,
    'practiceCompleted': practiceCompleted(questionCount),
    'score': score,
    'completionStatus': completionStatus(
      lessonCount: lessonCount,
      questionCount: questionCount,
    ).name,
    'updatedAtUtc': updatedAtUtc?.toIso8601String(),
  };

  factory Module2Progress.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != schemaVersion ||
        json['moduleId'] != 'module_02') {
      throw const FormatException('Unsupported Module 2 progress record.');
    }
    return Module2Progress(
      viewedLessonIds: Set.unmodifiable(_stringSet(json['viewedLessonIds'])),
      masteredQuestionIds: Set.unmodifiable(
        _stringSet(json['masteredQuestionIds']),
      ),
      updatedAtUtc: switch (json['updatedAtUtc']) {
        final String value => DateTime.parse(value).toUtc(),
        null => null,
        _ => throw const FormatException('Invalid progress timestamp.'),
      },
    );
  }

  static Set<String> _stringSet(Object? value) {
    if (value is! List<Object?>) {
      throw const FormatException('Invalid Module 2 progress list.');
    }
    return value.map((item) {
      if (item is! String || item.isEmpty) {
        throw const FormatException('Invalid Module 2 progress identifier.');
      }
      return item;
    }).toSet();
  }
}
