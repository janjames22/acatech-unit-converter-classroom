enum Module4CompletionStatus { notStarted, inProgress, complete }

final class Module4Progress {
  const Module4Progress({
    this.viewedLessonIds = const <String>{},
    this.masteredQuestionIds = const <String>{},
    this.practiceAttempts = const <String, int>{},
    this.updatedAtUtc,
  });

  static const schemaVersion = 1;

  final Set<String> viewedLessonIds;
  final Set<String> masteredQuestionIds;
  final Map<String, int> practiceAttempts;
  final DateTime? updatedAtUtc;

  int get score => masteredQuestionIds.length;
  int get totalAttempts => practiceAttempts.values.fold(0, (a, b) => a + b);
  bool practiceCompleted(int count) => score >= count;

  Module4CompletionStatus completionStatus({
    required int lessonCount,
    required int questionCount,
  }) {
    if (viewedLessonIds.length >= lessonCount &&
        practiceCompleted(questionCount)) {
      return Module4CompletionStatus.complete;
    }
    if (viewedLessonIds.isNotEmpty || practiceAttempts.isNotEmpty) {
      return Module4CompletionStatus.inProgress;
    }
    return Module4CompletionStatus.notStarted;
  }

  Module4Progress copyWith({
    Set<String>? viewedLessonIds,
    Set<String>? masteredQuestionIds,
    Map<String, int>? practiceAttempts,
    DateTime? updatedAtUtc,
  }) => Module4Progress(
    viewedLessonIds: Set.unmodifiable(viewedLessonIds ?? this.viewedLessonIds),
    masteredQuestionIds: Set.unmodifiable(
      masteredQuestionIds ?? this.masteredQuestionIds,
    ),
    practiceAttempts: Map.unmodifiable(
      practiceAttempts ?? this.practiceAttempts,
    ),
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );

  Map<String, Object?> toJson({
    required int lessonCount,
    required int questionCount,
  }) => <String, Object?>{
    'schemaVersion': schemaVersion,
    'moduleId': 'module_04',
    'viewedLessonIds': viewedLessonIds.toList()..sort(),
    'masteredQuestionIds': masteredQuestionIds.toList()..sort(),
    'practiceAttempts': practiceAttempts,
    'score': score,
    'totalAttempts': totalAttempts,
    'practiceCompleted': practiceCompleted(questionCount),
    'completionStatus': completionStatus(
      lessonCount: lessonCount,
      questionCount: questionCount,
    ).name,
    'updatedAtUtc': updatedAtUtc?.toIso8601String(),
  };

  factory Module4Progress.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != schemaVersion ||
        json['moduleId'] != 'module_04') {
      throw const FormatException('Unsupported Module 4 progress record.');
    }
    return Module4Progress(
      viewedLessonIds: Set.unmodifiable(_stringSet(json['viewedLessonIds'])),
      masteredQuestionIds: Set.unmodifiable(
        _stringSet(json['masteredQuestionIds']),
      ),
      practiceAttempts: Map.unmodifiable(_attemptMap(json['practiceAttempts'])),
      updatedAtUtc: switch (json['updatedAtUtc']) {
        final String value => DateTime.parse(value).toUtc(),
        null => null,
        _ => throw const FormatException('Invalid progress timestamp.'),
      },
    );
  }

  static Set<String> _stringSet(Object? value) {
    if (value is! List<Object?>) {
      throw const FormatException('Invalid Module 4 progress list.');
    }
    return value.map((item) {
      if (item is! String || item.isEmpty) {
        throw const FormatException('Invalid Module 4 progress identifier.');
      }
      return item;
    }).toSet();
  }

  static Map<String, int> _attemptMap(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Invalid Module 4 attempt map.');
    }
    final result = <String, int>{};
    for (final entry in value.entries) {
      if (entry.key is! String ||
          (entry.key as String).isEmpty ||
          entry.value is! int ||
          (entry.value as int) < 0) {
        throw const FormatException('Invalid Module 4 attempt entry.');
      }
      result[entry.key as String] = entry.value as int;
    }
    return result;
  }
}
