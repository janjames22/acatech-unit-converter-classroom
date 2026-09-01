import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/features/module_02/module_02.dart';

void main() {
  test('progress round-trips locally with explicit schema metadata', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesModule2ProgressRepository(preferences);
    final progress = Module2Progress(
      viewedLessonIds: const {'m02_l01'},
      masteredQuestionIds: const {'m02_q01', 'm02_q02'},
      updatedAtUtc: DateTime.utc(2026, 9, 1, 3, 4, 5),
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.viewedLessonIds, {'m02_l01'});
    expect(restored.masteredQuestionIds, {'m02_q01', 'm02_q02'});
    expect(restored.score, 2);
    final stored =
        jsonDecode(
              preferences.getString(
                SharedPreferencesModule2ProgressRepository.storageKey,
              )!,
            )
            as Map<String, Object?>;
    expect(stored['schemaVersion'], 1);
    expect(stored['moduleId'], 'module_02');
    expect(stored['practiceCompleted'], isFalse);
    expect(stored['completionStatus'], 'inProgress');
  });

  test('controller tracks lesson, practice, score, and completion', () async {
    final controller = Module2ProgressController(
      InMemoryModule2ProgressRepository(),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    for (final lesson in Module2Curriculum.lessons) {
      await controller.markLessonViewed(lesson.id);
    }
    for (final question in Module2Curriculum.practiceProblems) {
      await controller.markQuestionMastered(question.id);
    }

    expect(controller.progress.viewedLessonIds.length, 5);
    expect(controller.progress.score, 7);
    expect(controller.progress.practiceCompleted(7), isTrue);
    expect(
      controller.progress.completionStatus(lessonCount: 5, questionCount: 7),
      Module2CompletionStatus.complete,
    );
  });

  test(
    'invalid stored schema is reported without crashing the module',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPreferencesModule2ProgressRepository.storageKey: jsonEncode({
          'schemaVersion': 99,
          'moduleId': 'module_02',
        }),
      });
      final preferences = await SharedPreferences.getInstance();
      final controller = Module2ProgressController(
        SharedPreferencesModule2ProgressRepository(preferences),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.progress.score, 0);
      expect(controller.errorMessage, contains('could not be read'));
    },
  );
}
