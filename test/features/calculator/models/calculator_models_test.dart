import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/calculator/calculator.dart';

void main() {
  group('CalculatorAngleMode', () {
    test('provides stable display labels', () {
      expect(CalculatorAngleMode.degrees.label, 'DEG');
      expect(CalculatorAngleMode.radians.label, 'RAD');
    });
  });

  group('CalculatorHistory', () {
    final first = CalculatorHistoryEntry(
      expression: '1+1',
      result: '2',
      value: 2,
      calculatedAt: DateTime.utc(2026, 9),
    );
    final second = CalculatorHistoryEntry(
      expression: '2+2',
      result: '4',
      value: 4,
      calculatedAt: DateTime.utc(2026, 9, 1, 0, 1),
    );

    test('adds newest entries first without mutating the source', () {
      final original = CalculatorHistory(maxEntries: 2);
      final updated = original.add(first).add(second);

      expect(original.entries, isEmpty);
      expect(updated.entries, [second, first]);
      expect(() => updated.entries.add(first), throwsUnsupportedError);
    });

    test('enforces its bound and can be cleared immutably', () {
      final history = CalculatorHistory(maxEntries: 1).add(first).add(second);

      expect(history.entries, [second]);
      final cleared = history.clear();
      expect(cleared.entries, isEmpty);
      expect(cleared.maxEntries, 1);
      expect(history.entries, [second]);
    });

    test('rejects invalid bounds and oversized initial entries', () {
      expect(() => CalculatorHistory(maxEntries: 0), throwsArgumentError);
      expect(
        () => CalculatorHistory(entries: [first, second], maxEntries: 1),
        throwsArgumentError,
      );
    });
  });

  group('CalculatorState', () {
    test('starts with deterministic calculator defaults', () {
      final state = CalculatorState.initial();

      expect(state.expression, isEmpty);
      expect(state.displayValue, '0');
      expect(state.angleMode, CalculatorAngleMode.degrees);
      expect(state.lastValue, isNull);
      expect(state.memoryValue, isNull);
      expect(state.history.isEmpty, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasMemory, isFalse);
    });

    test('copyWith preserves values and supports explicit nullable clears', () {
      final populated = CalculatorState.initial().copyWith(
        expression: 'sqrt(9)',
        displayValue: '3',
        lastValue: 3.0,
        memoryValue: 3.0,
        errorMessage: 'temporary error',
        angleMode: CalculatorAngleMode.radians,
      );
      final cleared = populated.copyWith(
        lastValue: null,
        memoryValue: null,
        errorMessage: null,
      );

      expect(populated.expression, 'sqrt(9)');
      expect(populated.angleMode, CalculatorAngleMode.radians);
      expect(populated.hasError, isTrue);
      expect(populated.hasMemory, isTrue);
      expect(cleared.expression, populated.expression);
      expect(cleared.lastValue, isNull);
      expect(cleared.memoryValue, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.hasError, isFalse);
      expect(cleared.hasMemory, isFalse);
    });
  });
}
