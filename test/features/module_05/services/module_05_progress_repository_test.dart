import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/features/module_05/module_05.dart';

void main() {
  test('versioned Module 5 progress round-trips in local storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesModule5ProgressRepository(preferences);
    final progress = Module5Progress(
      viewedLessonIds: const {'m05_l01'},
      masteredQuestionIds: const {'m05_q01'},
      practiceAttempts: const {'m05_q01': 2, 'm05_q02': 1},
      updatedAtUtc: DateTime.utc(2026, 9, 2, 14, 20),
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.viewedLessonIds, {'m05_l01'});
    expect(restored.score, 1);
    expect(restored.totalAttempts, 3);
    final stored =
        jsonDecode(
              preferences.getString(
                SharedPreferencesModule5ProgressRepository.storageKey,
              )!,
            )
            as Map<String, Object?>;
    expect(stored['schemaVersion'], 1);
    expect(stored['moduleId'], 'module_05');
    expect(stored['completionStatus'], 'inProgress');
  });

  test('controller tracks lessons, attempts, score, and completion', () async {
    final controller = Module5ProgressController(
      InMemoryModule5ProgressRepository(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    for (final lesson in Module5Curriculum.lessons) {
      await controller.markLessonViewed(lesson.id);
    }
    await controller.recordPracticeAttempt('m05_q01', mastered: false);
    for (final problem in Module5Curriculum.practiceProblems) {
      await controller.recordPracticeAttempt(problem.id, mastered: true);
    }

    expect(controller.progress.viewedLessonIds.length, 6);
    expect(controller.progress.score, 13);
    expect(controller.progress.totalAttempts, 14);
    expect(
      controller.progress.completionStatus(
        lessonCount: Module5Curriculum.lessons.length,
        questionCount: Module5Curriculum.practiceProblems.length,
      ),
      Module5CompletionStatus.complete,
    );
  });

  test(
    'unsupported local schema falls back without blocking the module',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPreferencesModule5ProgressRepository.storageKey: jsonEncode({
          'schemaVersion': 99,
          'moduleId': 'module_05',
        }),
      });
      final preferences = await SharedPreferences.getInstance();
      final controller = Module5ProgressController(
        SharedPreferencesModule5ProgressRepository(preferences),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.progress.score, 0);
      expect(controller.errorMessage, contains('could not be read'));
    },
  );
}
