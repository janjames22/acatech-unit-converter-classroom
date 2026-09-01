import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/features/module_04/module_04.dart';

void main() {
  test('versioned Module 4 progress round-trips in local storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesModule4ProgressRepository(preferences);
    final progress = Module4Progress(
      viewedLessonIds: const {'m04_l01'},
      masteredQuestionIds: const {'m04_q01'},
      practiceAttempts: const {'m04_q01': 2, 'm04_q02': 1},
      updatedAtUtc: DateTime.utc(2026, 9, 2, 10, 20),
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.viewedLessonIds, {'m04_l01'});
    expect(restored.score, 1);
    expect(restored.totalAttempts, 3);
    final stored =
        jsonDecode(
              preferences.getString(
                SharedPreferencesModule4ProgressRepository.storageKey,
              )!,
            )
            as Map<String, Object?>;
    expect(stored['schemaVersion'], 1);
    expect(stored['moduleId'], 'module_04');
    expect(stored['completionStatus'], 'inProgress');
  });

  test('controller tracks lessons, attempts, score, and completion', () async {
    final controller = Module4ProgressController(
      InMemoryModule4ProgressRepository(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    for (final lesson in Module4Curriculum.lessons) {
      await controller.markLessonViewed(lesson.id);
    }
    await controller.recordPracticeAttempt('m04_q01', mastered: false);
    for (final problem in Module4Curriculum.practiceProblems) {
      await controller.recordPracticeAttempt(problem.id, mastered: true);
    }

    expect(controller.progress.viewedLessonIds.length, 5);
    expect(controller.progress.score, 8);
    expect(controller.progress.totalAttempts, 9);
    expect(
      controller.progress.completionStatus(
        lessonCount: Module4Curriculum.lessons.length,
        questionCount: Module4Curriculum.practiceProblems.length,
      ),
      Module4CompletionStatus.complete,
    );
  });

  test(
    'unsupported local schema falls back without blocking the module',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPreferencesModule4ProgressRepository.storageKey: jsonEncode({
          'schemaVersion': 99,
          'moduleId': 'module_04',
        }),
      });
      final preferences = await SharedPreferences.getInstance();
      final controller = Module4ProgressController(
        SharedPreferencesModule4ProgressRepository(preferences),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.progress.score, 0);
      expect(controller.errorMessage, contains('could not be read'));
    },
  );
}
