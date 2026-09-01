import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/theme/app_theme.dart';
import 'package:unit_converter/features/module_04/module_04.dart';

import '../../../helpers/practice_input_test_helpers.dart';

void main() {
  late Module4ProgressController progressController;

  setUp(() async {
    progressController = Module4ProgressController(
      InMemoryModule4ProgressRepository(),
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
          body: Module4Screen(
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
        of: find.byKey(const ValueKey('module4-scroll-view')),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('shows lessons and authoritative aviation bolt correction', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    expect(find.text(Module4Curriculum.title), findsOneWidget);
    expect(find.text('Module introduction'), findsOneWidget);
    expect(find.text('Learning objectives'), findsOneWidget);

    final borrowLesson = find.byKey(const ValueKey('module4-lesson-m04_l03'));
    await tester.scrollUntilVisible(
      borrowLesson,
      450,
      scrollable: moduleScrollable(),
    );
    await tester.tap(borrowLesson);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('module4-lesson-title-m04_l03')),
      findsOneWidget,
    );
    expect(find.text('Aviation example'), findsOneWidget);
    expect(
      find.textContaining('Authoritative curriculum result'),
      findsOneWidget,
    );
    expect(
      find.textContaining('overall-length value is a distracter'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(progressController.progress.viewedLessonIds, contains('m04_l03'));
  });

  testWidgets('practice supports reduction feedback, retry, and scoring', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final input = find.byKey(const ValueKey('module4-practice-input'));
    await tester.scrollUntilVisible(input, 700, scrollable: moduleScrollable());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('module4-practice-card')),
        matching: find.byType(EditableText),
      ),
      findsNothing,
    );
    await tapPracticeControl(tester, 'module4-numerator');
    await tapPracticeKeys(tester, 'module4', ['1', '7', '4']);
    await tapPracticeControl(tester, 'module4-denominator');
    await tapPracticeKeys(tester, 'module4', ['3', '2']);
    await tapPracticeControl(tester, 'module4-check-answer');
    await tester.pump();

    expect(find.textContaining('reduce the fractional part'), findsOneWidget);
    expect(find.byKey(const ValueKey('module4-retry-answer')), findsOneWidget);
    expect(progressController.progress.totalAttempts, 1);

    await tapPracticeControl(tester, 'module4-retry-answer');
    await tapPracticeControl(tester, 'module4-numerator');
    await tapPracticeKeys(tester, 'module4', ['clear', '8', '7']);
    await tapPracticeControl(tester, 'module4-denominator');
    await tapPracticeKeys(tester, 'module4', ['clear', '1', '6']);
    await tapPracticeControl(tester, 'module4-check-answer');
    await tester.pump();

    expect(find.textContaining('Correct.'), findsOneWidget);
    expect(progressController.progress.score, 1);
    expect(progressController.progress.totalAttempts, 2);
    expect(find.text('1/8 score'), findsOneWidget);
  });

  testWidgets('mixed-number lab displays conversion and borrowing evidence', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 1000);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final explore = find.byKey(const ValueKey('module4-lab-explore'));
    await tester.scrollUntilVisible(
      explore,
      650,
      scrollable: moduleScrollable(),
    );
    await tester.tap(explore);
    await tester.pump();

    expect(find.text('Subtraction result: 1 13/16'), findsOneWidget);
    expect(find.textContaining('3 1/8 = 25/8'), findsOneWidget);
    expect(find.textContaining('Borrow one whole as 16/16'), findsOneWidget);
  });

  testWidgets('calculator launcher uses the existing navigation callback', (
    tester,
  ) async {
    var opened = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester, onOpenCalculator: () => opened = true);

    await tester.tap(find.byKey(const ValueKey('module4-open-calculator')));
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
        reason: 'Module 4 layout at ${width}px',
      );
      expect(find.byKey(const ValueKey('module4-title')), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('module4-open-calculator')))
            .height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
