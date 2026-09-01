import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/calculator/calculator.dart';

void main() {
  group('CalculatorController editing and evaluation', () {
    test('builds and evaluates a basic expression with history', () {
      final controller = CalculatorController(
        clock: () => DateTime.utc(2026, 9, 1, 12),
      );
      addTearDown(controller.dispose);

      controller
        ..inputDigit('2')
        ..inputOperator('+')
        ..inputDigit('2')
        ..evaluate();

      expect(controller.state.expression, '2+2');
      expect(controller.state.displayValue, '4');
      expect(controller.state.lastValue, 4);
      expect(controller.state.history.entries, hasLength(1));
      expect(controller.state.history.entries.single.expression, '2+2');
      expect(
        controller.state.history.entries.single.calculatedAt,
        DateTime.utc(2026, 9, 1, 12),
      );
    });

    test('supports decimals, parentheses, delete, percent, and clear', () {
      final controller = CalculatorController();
      addTearDown(controller.dispose);

      controller
        ..inputParenthesis('(')
        ..inputDigit('1')
        ..inputDecimal()
        ..inputDigit('5')
        ..inputOperator('+')
        ..inputDigit('2')
        ..inputParenthesis(')')
        ..inputPercent();
      expect(controller.state.expression, '(1.5+2)%');

      controller.backspace();
      expect(controller.state.expression, '(1.5+2)');
      controller.evaluate();
      expect(controller.state.displayValue, '3.5');

      controller.clear();
      expect(controller.state.expression, isEmpty);
      expect(controller.state.displayValue, '0');
      expect(controller.state.history.entries, hasLength(1));
    });

    test('evaluates scientific expressions in degree and radian modes', () {
      final controller = CalculatorController();
      addTearDown(controller.dispose);

      controller
        ..inputFunction('sin')
        ..inputDigit('9')
        ..inputDigit('0')
        ..inputParenthesis(')')
        ..evaluate();
      expect(controller.state.displayValue, '1');

      controller
        ..setAngleMode(CalculatorAngleMode.radians)
        ..inputFunction('cos')
        ..inputConstant('π')
        ..inputParenthesis(')')
        ..evaluate();
      expect(controller.state.displayValue, '-1');
    });

    test('shows recoverable engine errors', () {
      final controller = CalculatorController();
      addTearDown(controller.dispose);

      controller
        ..inputDigit('1')
        ..inputOperator('÷')
        ..inputDigit('0')
        ..evaluate();
      expect(controller.state.errorMessage, 'Cannot divide by zero.');

      controller.inputDigit('7');
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.expression, '1÷07');
      controller.clear();
      expect(controller.state.errorMessage, isNull);
    });
  });

  group('CalculatorController memory and history', () {
    test('adds, recalls, subtracts, and clears memory', () {
      final controller = CalculatorController();
      addTearDown(controller.dispose);

      controller
        ..inputDigit('5')
        ..evaluate()
        ..memoryAdd();
      expect(controller.state.memoryValue, 5);

      controller
        ..clear()
        ..memoryRecall();
      expect(controller.state.expression, '5');
      controller
        ..evaluate()
        ..memorySubtract();
      expect(controller.state.memoryValue, 0);

      controller.memoryClear();
      expect(controller.state.memoryValue, isNull);
    });

    test('reuses and clears local history without reevaluating', () {
      final controller = CalculatorController();
      addTearDown(controller.dispose);
      controller
        ..inputDigit('9')
        ..inputOperator('−')
        ..inputDigit('4')
        ..evaluate();
      final entry = controller.state.history.entries.single;

      controller
        ..clear()
        ..reuseHistory(entry);
      expect(controller.state.expression, '9−4');
      expect(controller.state.displayValue, '5');
      expect(controller.state.history.entries, hasLength(1));

      controller.clearHistory();
      expect(controller.state.history.isEmpty, isTrue);
    });
  });
}
