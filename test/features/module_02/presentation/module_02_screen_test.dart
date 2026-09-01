import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/theme/app_theme.dart';
import 'package:unit_converter/features/module_02/module_02.dart';

import '../../../helpers/practice_input_test_helpers.dart';

void main() {
  late Module2ProgressController progressController;

  setUp(() async {
    progressController = Module2ProgressController(
      InMemoryModule2ProgressRepository(),
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
          body: Module2Screen(
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
        of: find.byKey(const ValueKey('module2-scroll-view')),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('shows introduction, objectives, lessons, and aviation content', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    expect(find.text(Module2Curriculum.title), findsOneWidget);
    expect(find.text('Module introduction'), findsOneWidget);
    expect(find.text('Learning objectives'), findsOneWidget);
    expect(find.text('Whole numbers and place value'), findsOneWidget);

    final firstLesson = find.byKey(const ValueKey('module2-lesson-m02_l01'));
    await tester.scrollUntilVisible(
      firstLesson,
      400,
      scrollable: moduleScrollable(),
    );
    await tester.tap(firstLesson);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('module2-lesson-title-m02_l01')),
      findsOneWidget,
    );
    expect(find.text('Worked examples'), findsOneWidget);
    expect(find.text('Aviation example'), findsOneWidget);
    expect(find.text('Given'), findsOneWidget);
    expect(find.text('Formula'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(progressController.progress.viewedLessonIds, contains('m02_l01'));
  });

  testWidgets('practice provides incorrect feedback, retry, and local score', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final input = find.byKey(const ValueKey('module2-practice-input'));
    await tester.scrollUntilVisible(input, 600, scrollable: moduleScrollable());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('module2-practice-card')),
        matching: find.byType(EditableText),
      ),
      findsNothing,
    );
    await tapPracticeKeys(tester, 'module2', ['1']);
    await tapPracticeControl(tester, 'module2-check-answer');

    expect(find.textContaining('Not yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('module2-retry-answer')), findsOneWidget);
    expect(find.textContaining('97,578'), findsOneWidget);

    await tapPracticeControl(tester, 'module2-retry-answer');
    await tapPracticeKeys(tester, 'module2', ['9', '7', '5', '7', '8']);
    await tapPracticeControl(tester, 'module2-check-answer');
    await tester.pump();

    expect(find.textContaining('Correct.'), findsOneWidget);
    expect(progressController.progress.score, 1);
    expect(find.text('1/7 practice score'), findsOneWidget);
  });

  testWidgets('whole-number lab exposes division and divisibility evidence', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 1000);
    addTearDown(tester.view.reset);
    await pumpModule(tester);

    final explore = find.byKey(const ValueKey('module2-lab-explore'));
    await tester.scrollUntilVisible(
      explore,
      600,
      scrollable: moduleScrollable(),
    );
    await tester.tap(explore);
    await tester.pump();

    expect(find.textContaining('Division result: 159'), findsOneWidget);
    expect(find.textContaining('3816 is divisible by 3'), findsOneWidget);
    expect(find.textContaining('Prime factors:'), findsOneWidget);
  });

  testWidgets('calculator launcher uses the supplied integration callback', (
    tester,
  ) async {
    var opened = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpModule(tester, onOpenCalculator: () => opened = true);

    await tester.tap(find.byKey(const ValueKey('module2-open-calculator')));
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
        reason: 'Module 2 layout at ${width}px',
      );
      expect(find.byKey(const ValueKey('module2-title')), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('module2-open-calculator')))
            .height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
