import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_03/module_03.dart';
import 'package:unit_converter/features/module_04/module_04.dart';

void main() {
  const engine = MixedNumberEngine();

  group('mixed-number representation and conversion', () {
    test('classifies and normalizes proper, improper, and mixed values', () {
      expect(engine.create(0, 3, 4).isProperFraction, isTrue);
      expect(engine.create(1, 6, 8).text, '1 3/4');
      expect(engine.create(2, 9, 4).text, '4 1/4');
      expect(engine.create(6, 0, 8).text, '6');
    });

    test('converts 5 7/16 to the authoritative improper value', () {
      final step = engine.toImproper(engine.create(5, 7, 16));
      expect(step.result, '87/16');
      expect(step.expression, '5 × 16 + 7 = 87');
    });

    test('converts 87/32 to 2 23/32 with quotient evidence', () {
      final step = engine.fromImproper(ExactFraction(87, 32));
      expect(step.result, '2 23/32');
      expect(step.expression, '87 = 2 × 32 + 23');
    });

    test('rejects invalid denominators and out-of-scope negative values', () {
      expect(() => engine.create(1, 2, 0), throwsA(isA<FractionException>()));
      expect(
        () => engine.create(-1, 1, 2),
        throwsA(isA<MixedNumberException>()),
      );
      expect(
        () => engine.fromImproper(ExactFraction(-3, 2)),
        throwsA(isA<MixedNumberException>()),
      );
    });
  });

  group('addition and subtraction', () {
    test('adds the authoritative cargo example with a carry', () {
      final result = engine.add(engine.create(4, 3, 4), engine.create(2, 1, 3));
      expect(result.exactResult, ExactFraction(85, 12));
      expect(result.value.text, '7 1/12');
      expect(result.carryStep?.carriedWhole, 1);
      expect(result.carryStep?.remainderNumerator, 1);
    });

    test('adds without inventing a carry when the parts remain proper', () {
      final result = engine.add(engine.create(1, 1, 8), engine.create(2, 1, 8));
      expect(result.value.text, '3 1/4');
      expect(result.carryStep, isNull);
    });

    test('subtracts the authoritative bolt grip with borrowing', () {
      final result = engine.subtract(
        engine.create(3, 1, 8),
        engine.create(1, 5, 16),
      );
      expect(result.exactResult, ExactFraction(29, 16));
      expect(result.value.text, '1 13/16');
      expect(result.borrowStep?.borrowedWhole, 2);
      expect(result.borrowStep?.borrowedNumerator, 18);
    });

    test('subtracts without borrowing and preserves a whole result', () {
      final result = engine.subtract(
        engine.create(5, 3, 4),
        engine.create(2, 3, 4),
      );
      expect(result.value.text, '3');
      expect(result.borrowStep, isNull);
    });

    test('defers negative subtraction to the signed-number module', () {
      expect(
        () => engine.subtract(engine.create(1, 0, 1), engine.create(2, 0, 1)),
        throwsA(isA<MixedNumberException>()),
      );
    });
  });

  group('multiplication, division, and aviation cut planning', () {
    test('multiplies complete mixed values before returning to mixed form', () {
      final result = engine.multiply(
        engine.create(2, 1, 2),
        engine.create(1, 3, 4),
      );
      expect(result.leftImproper, ExactFraction(5, 2));
      expect(result.rightImproper, ExactFraction(7, 4));
      expect(result.value.text, '4 3/8');
    });

    test('calculates the twelve-spacer stack exactly', () {
      expect(engine.totalForPieces(engine.create(1, 3, 8), 12).text, '16 1/2');
      expect(
        () => engine.totalForPieces(engine.create(1, 3, 8), -1),
        throwsA(isA<MixedNumberException>()),
      );
    });

    test('divides the cable example into six exact pieces', () {
      final result = engine.divide(
        engine.create(7, 1, 2),
        engine.create(1, 1, 4),
      );
      expect(result.value.text, '6');
    });

    test('reports complete cuts and exact remainder', () {
      final exact = engine.cutPlan(
        engine.create(7, 1, 2),
        engine.create(1, 1, 4),
      );
      expect(exact.pieceCount, 6);
      expect(exact.remainder.text, '0');

      final remainder = engine.cutPlan(
        engine.create(8, 0, 1),
        engine.create(1, 1, 2),
      );
      expect(remainder.pieceCount, 5);
      expect(remainder.remainder.text, '1/2');
      expect(
        () => engine.cutPlan(engine.create(8, 0, 1), engine.create(0, 0, 1)),
        throwsA(isA<MixedNumberException>()),
      );
    });

    test('requires the exact given set and rejects distracters', () {
      expect(
        engine
            .validateGivens(
              selectedIds: {'shank', 'threaded'},
              requiredIds: {'shank', 'threaded'},
            )
            .isCorrect,
        isTrue,
      );
      expect(
        engine
            .validateGivens(
              selectedIds: {'shank', 'threaded', 'overall'},
              requiredIds: {'shank', 'threaded'},
            )
            .isCorrect,
        isFalse,
      );
    });
  });
}
