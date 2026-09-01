import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/theme/app_theme.dart';
import 'package:unit_converter/features/module_03/module_03.dart';

import '../../../helpers/practice_input_test_helpers.dart';

void main() {
  late Module3ProgressController progressController;

  setUp(() async {
    progressController = Module3ProgressController(
      InMemoryModule3ProgressRepository(),
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
          body: Module3Screen(
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
        of: find.byKey(const ValueKey('module3-scroll-view')),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('shows objectives, lessons, correction, and aviation content', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    expect(find.text(Module3Curriculum.title), findsOneWidget);
    expect(find.text('Module introduction'), findsOneWidget);
    expect(find.text('Learning objectives'), findsOneWidget);

    final lcdLesson = find.byKey(const ValueKey('module3-lesson-m03_l02'));
    await tester.scrollUntilVisible(
      lcdLesson,
      450,
      scrollable: moduleScrollable(),
    );
    await tester.tap(lcdLesson);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('module3-lesson-title-m03_l02')),
      findsOneWidget,
    );
    expect(find.text('Worked examples'), findsOneWidget);
    expect(find.text('Aviation example'), findsOneWidget);
    expect(find.textContaining('LCD is 64'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(progressController.progress.viewedLessonIds, contains('m03_l02'));
  });

  testWidgets('practice gives reduction feedback, retry, and attempt score', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final input = find.byKey(const ValueKey('module3-practice-input'));
    await tester.scrollUntilVisible(input, 650, scrollable: moduleScrollable());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('module3-practice-card')),
        matching: find.byType(EditableText),
      ),
      findsNothing,
    );
    await tapPracticeKeys(tester, 'module3', ['6']);
    await tapPracticeControl(tester, 'module3-denominator');
    await tapPracticeKeys(tester, 'module3', ['2', '0']);
    await tapPracticeControl(tester, 'module3-check-answer');
    await tester.pump();

    expect(find.textContaining('reduce the fraction'), findsOneWidget);
    expect(find.byKey(const ValueKey('module3-retry-answer')), findsOneWidget);
    expect(progressController.progress.totalAttempts, 1);

    await tapPracticeControl(tester, 'module3-retry-answer');
    await tapPracticeControl(tester, 'module3-numerator');
    await tapPracticeKeys(tester, 'module3', ['clear', '3']);
    await tapPracticeControl(tester, 'module3-denominator');
    await tapPracticeKeys(tester, 'module3', ['clear', '1', '0']);
    await tapPracticeControl(tester, 'module3-check-answer');
    await tester.pump();

    expect(find.textContaining('Correct.'), findsOneWidget);
    expect(progressController.progress.score, 1);
    expect(progressController.progress.totalAttempts, 2);
    expect(find.text('1/9 score'), findsOneWidget);
  });

  testWidgets('fraction lab shows corrected exact panel result and LCD', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 1000);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final explore = find.byKey(const ValueKey('module3-lab-explore'));
    await tester.scrollUntilVisible(
      explore,
      650,
      scrollable: moduleScrollable(),
    );
    await tester.tap(explore);
    await tester.pump();

    expect(find.text('Addition result: 7/64'), findsOneWidget);
    expect(find.textContaining('Common denominator 64'), findsOneWidget);
    expect(find.textContaining('3/32 = 6/64'), findsOneWidget);
  });

  testWidgets('calculator launcher uses the supplied callback', (tester) async {
    var opened = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester, onOpenCalculator: () => opened = true);

    await tester.tap(find.byKey(const ValueKey('module3-open-calculator')));
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
        reason: 'Module 3 layout at ${width}px',
      );
      expect(find.byKey(const ValueKey('module3-title')), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('module3-open-calculator')))
            .height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
