import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/features/module_03/module_03.dart';

void main() {
  test('progress and attempt counts round-trip locally', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesModule3ProgressRepository(preferences);
    final progress = Module3Progress(
      viewedLessonIds: const {'m03_l01'},
      masteredQuestionIds: const {'m03_q01'},
      practiceAttempts: const {'m03_q01': 2, 'm03_q02': 1},
      updatedAtUtc: DateTime.utc(2026, 9, 1, 10, 20),
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.viewedLessonIds, {'m03_l01'});
    expect(restored.score, 1);
    expect(restored.totalAttempts, 3);
    final stored =
        jsonDecode(
              preferences.getString(
                SharedPreferencesModule3ProgressRepository.storageKey,
              )!,
            )
            as Map<String, Object?>;
    expect(stored['schemaVersion'], 1);
    expect(stored['moduleId'], 'module_03');
    expect(stored['completionStatus'], 'inProgress');
  });

  test('controller tracks lessons, attempts, scores, and completion', () async {
    final controller = Module3ProgressController(
      InMemoryModule3ProgressRepository(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    for (final lesson in Module3Curriculum.lessons) {
      await controller.markLessonViewed(lesson.id);
    }
    await controller.recordPracticeAttempt('m03_q01', mastered: false);
    for (final problem in Module3Curriculum.practiceProblems) {
      await controller.recordPracticeAttempt(problem.id, mastered: true);
    }

    expect(controller.progress.viewedLessonIds.length, 6);
    expect(controller.progress.score, 9);
    expect(controller.progress.totalAttempts, 10);
    expect(
      controller.progress.completionStatus(lessonCount: 6, questionCount: 9),
      Module3CompletionStatus.complete,
    );
  });

  test('unsupported schema falls back without crashing the screen', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesModule3ProgressRepository.storageKey: jsonEncode({
        'schemaVersion': 99,
        'moduleId': 'module_03',
      }),
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = Module3ProgressController(
      SharedPreferencesModule3ProgressRepository(preferences),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.isInitialized, isTrue);
    expect(controller.progress.score, 0);
    expect(controller.errorMessage, contains('could not be read'));
  });
}
