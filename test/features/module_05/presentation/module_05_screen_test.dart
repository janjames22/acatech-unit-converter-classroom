import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/theme/app_theme.dart';
import 'package:unit_converter/features/module_05/module_05.dart';

import '../../../helpers/practice_input_test_helpers.dart';

void main() {
  late Module5ProgressController progressController;

  setUp(() async {
    progressController = Module5ProgressController(
      InMemoryModule5ProgressRepository(),
    );
    await progressController.initialize();
  });

  tearDown(() => progressController.dispose());

  Future<void> pumpModule(
    WidgetTester tester, {
    VoidCallback? onOpenCalculator,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Module5Screen(
            progressController: progressController,
            onOpenCalculator: onOpenCalculator ?? () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder moduleScrollable() => find
      .descendant(
        of: find.byKey(const ValueKey('module5-scroll-view')),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets(
    'shows lessons, explicit repeating notation, and chart correction',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await pumpModule(tester);

      expect(find.text(Module5Curriculum.title), findsOneWidget);
      expect(find.text('Module introduction'), findsOneWidget);
      expect(find.text('Learning objectives'), findsOneWidget);

      final conversionLesson = find.byKey(
        const ValueKey('module5-lesson-m05_l06'),
      );
      await tester.scrollUntilVisible(
        conversionLesson,
        500,
        scrollable: moduleScrollable(),
      );
      await tester.tap(conversionLesson);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('module5-lesson-title-m05_l06')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('module5-repeating-notation')),
        findsOneWidget,
      );
      expect(find.textContaining('corrupted row label'), findsOneWidget);
      expect(find.textContaining('9/16'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(progressController.progress.viewedLessonIds, contains('m05_l06'));
    },
  );

  testWidgets('practice supports incorrect feedback, retry, and scoring', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final input = find.byKey(const ValueKey('module5-practice-input'));
    await tester.scrollUntilVisible(input, 750, scrollable: moduleScrollable());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('module5-practice-card')),
        matching: find.byType(EditableText),
      ),
      findsNothing,
    );
    await tapPracticeKeys(tester, 'module5', ['3', '7', '.', '0', '5']);
    await tapPracticeControl(tester, 'module5-check-answer');

    expect(find.textContaining('Not yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('module5-retry-answer')), findsOneWidget);
    expect(progressController.progress.totalAttempts, 1);

    await tapPracticeControl(tester, 'module5-retry-answer');
    await tapPracticeKeys(tester, 'module5', [
      'clear',
      '3',
      '7',
      '.',
      '0',
      '0',
      '5',
    ]);
    await tapPracticeControl(tester, 'module5-check-answer');

    expect(find.textContaining('Correct.'), findsOneWidget);
    expect(progressController.progress.score, 1);
    expect(progressController.progress.totalAttempts, 2);
    expect(find.text('1/13 score'), findsOneWidget);
  });

  testWidgets('decimal lab shows exact aligned subtraction evidence', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 1000);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final explore = find.byKey(const ValueKey('module5-lab-explore'));
    await tester.scrollUntilVisible(
      explore,
      700,
      scrollable: moduleScrollable(),
    );
    await tester.tap(explore);
    await tester.pump();

    expect(find.text('Subtraction result: 22.392'), findsOneWidget);
    expect(find.textContaining('Align decimal points'), findsWidgets);
    expect(find.textContaining('37 and 272 thousandths'), findsOneWidget);
  });

  testWidgets('calculator launcher uses the existing navigation callback', (
    tester,
  ) async {
    var opened = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester, onOpenCalculator: () => opened = true);

    await tester.tap(find.byKey(const ValueKey('module5-open-calculator')));
    expect(opened, isTrue);
  });

  testWidgets('has no layout exceptions at all required widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const widths = <double>[320, 360, 390, 430, 768, 1024, 1366, 1920];
    tester.view.physicalSize = const Size(320, 1000);
    await pumpModule(tester);

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Module 5 layout at ${width}px',
      );
      expect(find.byKey(const ValueKey('module5-title')), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('module5-open-calculator')))
            .height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
