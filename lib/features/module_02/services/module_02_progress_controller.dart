import 'package:flutter/foundation.dart';

import '../models/module_02_content.dart';
import '../models/module_02_progress.dart';
import 'module_02_progress_repository.dart';

final class Module2ProgressController extends ChangeNotifier {
  Module2ProgressController(this._repository);

  final Module2ProgressRepository _repository;
  Module2Progress _progress = const Module2Progress();
  bool _initialized = false;
  bool _disposed = false;
  String? _errorMessage;

  Module2Progress get progress => _progress;
  bool get isInitialized => _initialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      _progress = await _repository.load();
      _errorMessage = null;
    } on Object {
      _progress = const Module2Progress();
      _errorMessage =
          'Saved Module 2 progress could not be read. A fresh local record is being used.';
    } finally {
      _initialized = true;
      _safeNotify();
    }
  }

  Future<void> markLessonViewed(String lessonId) async {
    if (_progress.viewedLessonIds.contains(lessonId)) {
      return;
    }
    final lessonExists = Module2Curriculum.lessons.any(
      (lesson) => lesson.id == lessonId,
    );
    if (!lessonExists) {
      throw ArgumentError.value(lessonId, 'lessonId', 'Unknown lesson.');
    }
    await _commit(
      _progress.copyWith(
        viewedLessonIds: {..._progress.viewedLessonIds, lessonId},
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> markQuestionMastered(String questionId) async {
    if (_progress.masteredQuestionIds.contains(questionId)) {
      return;
    }
    final questionExists = Module2Curriculum.practiceProblems.any(
      (question) => question.id == questionId,
    );
    if (!questionExists) {
      throw ArgumentError.value(questionId, 'questionId', 'Unknown question.');
    }
    await _commit(
      _progress.copyWith(
        masteredQuestionIds: {..._progress.masteredQuestionIds, questionId},
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _commit(Module2Progress next) async {
    try {
      await _repository.save(next);
      _progress = next;
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Module 2 progress could not be saved on this device.';
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
