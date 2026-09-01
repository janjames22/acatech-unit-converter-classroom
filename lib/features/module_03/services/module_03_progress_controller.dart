import 'package:flutter/foundation.dart';

import '../models/module_03_content.dart';
import '../models/module_03_progress.dart';
import 'module_03_progress_repository.dart';

final class Module3ProgressController extends ChangeNotifier {
  Module3ProgressController(this._repository);

  final Module3ProgressRepository _repository;
  Module3Progress _progress = const Module3Progress();
  bool _initialized = false;
  bool _disposed = false;
  String? _errorMessage;

  Module3Progress get progress => _progress;
  bool get isInitialized => _initialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      _progress = await _repository.load();
      _errorMessage = null;
    } on Object {
      _progress = const Module3Progress();
      _errorMessage =
          'Saved Module 3 progress could not be read. A fresh local record is being used.';
    } finally {
      _initialized = true;
      _safeNotify();
    }
  }

  Future<void> markLessonViewed(String lessonId) async {
    if (_progress.viewedLessonIds.contains(lessonId)) {
      return;
    }
    if (!Module3Curriculum.lessons.any((lesson) => lesson.id == lessonId)) {
      throw ArgumentError.value(lessonId, 'lessonId', 'Unknown lesson.');
    }
    await _commit(
      _progress.copyWith(
        viewedLessonIds: {..._progress.viewedLessonIds, lessonId},
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> recordPracticeAttempt(
    String questionId, {
    required bool mastered,
  }) async {
    if (!Module3Curriculum.practiceProblems.any(
      (question) => question.id == questionId,
    )) {
      throw ArgumentError.value(questionId, 'questionId', 'Unknown question.');
    }
    final attempts = Map<String, int>.of(_progress.practiceAttempts);
    attempts[questionId] = (attempts[questionId] ?? 0) + 1;
    await _commit(
      _progress.copyWith(
        practiceAttempts: attempts,
        masteredQuestionIds: mastered
            ? {..._progress.masteredQuestionIds, questionId}
            : _progress.masteredQuestionIds,
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _commit(Module3Progress next) async {
    try {
      await _repository.save(next);
      _progress = next;
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Module 3 progress could not be saved on this device.';
    }
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
