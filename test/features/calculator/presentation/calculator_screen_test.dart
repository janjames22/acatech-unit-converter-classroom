import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/theme/app_theme.dart';
import 'package:unit_converter/features/calculator/calculator.dart';

void main() {
  late CalculatorController controller;

  setUp(() => controller = CalculatorController());
  tearDown(() => controller.dispose());

  Future<void> pumpCalculator(
    WidgetTester tester, {
    double width = 390,
    double height = 900,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        home: Scaffold(body: CalculatorScreen(controller: controller)),
      ),
    );
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String keyName) async {
    final finder = find.byKey(ValueKey('calculator-key-$keyName'));
    await tester.scrollUntilVisible(
      finder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('opens with basic and scientific controls', (tester) async {
    await pumpCalculator(tester);

    expect(find.text('Scientific Calculator'), findsOneWidget);
    expect(find.byKey(const ValueKey('calculator-display')), findsOneWidget);
    expect(find.byKey(const ValueKey('calculator-keyboard')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calculator-scientific-buttons')),
      findsOneWidget,
    );
    for (final keyName in [
      'clear',
      'backspace',
      'digit-0',
      'digit-9',
      'divide',
      'multiply',
      'subtract',
      'add',
      'equals',
      'sqrt',
      'sin',
      'log',
      'pi',
    ]) {
      expect(
        find.byKey(ValueKey('calculator-key-$keyName')),
        findsOneWidget,
        reason: keyName,
      );
    }
  });

  testWidgets('updates the expression and displays a basic result', (
    tester,
  ) async {
    await pumpCalculator(tester);

    await tapKey(tester, 'digit-2');
    await tapKey(tester, 'add');
    await tapKey(tester, 'digit-2');
    expect(find.text('2+2'), findsOneWidget);

    await tapKey(tester, 'equals');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('calculator-result'))).data,
      '4',
    );
  });

  testWidgets('switches angle mode and evaluates scientific input', (
    tester,
  ) async {
    await pumpCalculator(tester);

    await tapKey(tester, 'sqrt');
    await tapKey(tester, 'digit-2');
    await tapKey(tester, 'digit-5');
    await tapKey(tester, 'close-parenthesis');
    await tapKey(tester, 'equals');

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('calculator-result'))).data,
      '5',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('calculator-angle-selector')),
    );
    await tester.tap(find.text('RAD'));
    await tester.pump();
    expect(controller.state.angleMode, CalculatorAngleMode.radians);
  });

  testWidgets('shows errors and exposes reusable mobile history', (
    tester,
  ) async {
    await pumpCalculator(tester, width: 390);

    await tapKey(tester, 'digit-1');
    await tapKey(tester, 'divide');
    await tapKey(tester, 'digit-0');
    await tapKey(tester, 'equals');
    expect(find.byKey(const ValueKey('calculator-error')), findsOneWidget);

    controller
      ..clear()
      ..inputDigit('5')
      ..inputOperator('×')
      ..inputDigit('5')
      ..evaluate();
    await tester.pump();
    final historyButton = find.byKey(const ValueKey('calculator-open-history'));
    await tester.scrollUntilVisible(
      historyButton,
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    expect(find.text('Previous Calculations'), findsOneWidget);
    final historyExpression = find.descendant(
      of: find.byKey(const ValueKey('calculator-history-panel')),
      matching: find.text('5×5'),
    );
    expect(historyExpression, findsOneWidget);
    expect(find.text('= 25'), findsOneWidget);
    await tester.tap(historyExpression);
    await tester.pumpAndSettle();
    expect(controller.state.expression, '5×5');
    expect(controller.state.displayValue, '25');
  });

  testWidgets('supports all target widths without layout exceptions', (
    tester,
  ) async {
    const widths = <double>[320, 360, 390, 430, 768, 1024, 1366, 1920, 2560];
    await pumpCalculator(tester, width: widths.first);

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'calculator layout at ${width}px',
      );
      expect(
        find.byKey(const ValueKey('calculator-key-equals')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calculator-history-panel')),
        width >= 1024 ? findsOneWidget : findsNothing,
        reason: 'history layout at ${width}px',
      );
    }
  });

  testWidgets('uses Material 3 dark theme and large touch targets', (
    tester,
  ) async {
    await pumpCalculator(tester, width: 360, themeMode: ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(CalculatorScreen))).useMaterial3,
      isTrue,
    );
    expect(
      Theme.of(tester.element(find.byType(CalculatorScreen))).brightness,
      Brightness.dark,
    );

    final equals = find.byKey(const ValueKey('calculator-key-equals'));
    await tester.scrollUntilVisible(
      equals,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getSize(equals).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(equals).width, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });
}
