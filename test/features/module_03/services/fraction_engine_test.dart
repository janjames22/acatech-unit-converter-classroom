import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_03/module_03.dart';

void main() {
  const engine = FractionEngine();

  group('exact fraction representation', () {
    test('normalizes signs, zero, and lowest terms', () {
      expect(ExactFraction(6, 8), ExactFraction(3, 4));
      expect(ExactFraction(1, -2), ExactFraction(-1, 2));
      expect(ExactFraction(-1, -2), ExactFraction(1, 2));
      expect(ExactFraction(0, -99), ExactFraction.zero);
      expect(() => ExactFraction(1, 0), throwsA(isA<FractionException>()));
    });

    test('classifies proper, improper, and whole values', () {
      expect(ExactFraction(3, 4).classification, FractionClassification.proper);
      expect(
        ExactFraction(7, 4).classification,
        FractionClassification.improper,
      );
      expect(ExactFraction(8, 4).classification, FractionClassification.whole);
      expect(ExactFraction(193, 105).mixedNumberText, '1 88/105');
      expect(ExactFraction(-7, 5).mixedNumberText, '-1 2/5');
    });
  });

  group('common denominators and equivalents', () {
    test('supports both curriculum common-denominator methods', () {
      final least = engine.commonDenominator(
        ExactFraction(1, 5),
        ExactFraction(1, 10),
      );
      expect(least.denominator, 10);
      expect(least.leftStep.fractionText, '2/10');
      expect(least.rightStep.fractionText, '1/10');

      final product = engine.commonDenominator(
        ExactFraction(1, 5),
        ExactFraction(1, 10),
        method: CommonDenominatorMethod.productOfDenominators,
      );
      expect(product.denominator, 50);
      expect(product.leftStep.fractionText, '10/50');
      expect(product.rightStep.fractionText, '5/50');
    });

    test('locks the corrected panel LCD at 64', () {
      final common = engine.commonDenominator(
        ExactFraction(3, 32),
        ExactFraction(1, 64),
      );
      expect(common.denominator, 64);
      expect(common.leftStep.fractionText, '6/64');
      expect(common.rightStep.fractionText, '1/64');
    });

    test('rejects a non-equivalent target denominator', () {
      expect(
        () => engine.equivalent(ExactFraction(2, 3), 5),
        throwsA(isA<FractionException>()),
      );
    });
  });

  group('fraction operations', () {
    test('matches the authoritative addition examples', () {
      expect(
        engine.add([ExactFraction(1, 5), ExactFraction(1, 10)]),
        ExactFraction(3, 10),
      );
      expect(
        engine.add([
          ExactFraction(2, 3),
          ExactFraction(3, 5),
          ExactFraction(4, 7),
        ]),
        ExactFraction(193, 105),
      );
      expect(
        engine.add([ExactFraction(3, 32), ExactFraction(1, 64)]),
        ExactFraction(7, 64),
      );
    });

    test('matches subtraction, multiplication, and division examples', () {
      expect(
        engine.subtract(ExactFraction(13, 16), ExactFraction(7, 16)),
        ExactFraction(3, 8),
      );
      expect(
        engine.multiply([
          ExactFraction(3, 5),
          ExactFraction(7, 8),
          ExactFraction(1, 2),
        ]),
        ExactFraction(21, 80),
      );
      expect(
        engine.multiply([ExactFraction(14, 15), ExactFraction(3, 2)]),
        ExactFraction(7, 5),
      );
      expect(
        engine.divide(ExactFraction(7, 8), ExactFraction(4, 3)),
        ExactFraction(21, 32),
      );
    });

    test('rejects division by a zero fraction and empty operations', () {
      expect(
        () => engine.divide(ExactFraction(1, 2), ExactFraction.zero),
        throwsA(isA<FractionException>()),
      );
      expect(() => engine.add(const []), throwsA(isA<FractionException>()));
      expect(
        () => engine.multiply(const []),
        throwsA(isA<FractionException>()),
      );
    });
  });

  group('comparison, cancellation, tolerance, and reduction', () {
    test('compares fractions exactly', () {
      expect(engine.compare(ExactFraction(2, 3), ExactFraction(3, 5)), 1);
      expect(engine.compare(ExactFraction(1, 2), ExactFraction(2, 4)), 0);
      expect(engine.compare(ExactFraction(-1, 2), ExactFraction(0, 1)), -1);
    });

    test('shows both cancellation steps for 14/15 × 3/2', () {
      final steps = engine.cancellationSteps(
        ExactFraction(14, 15),
        ExactFraction(3, 2),
      );
      expect(steps, hasLength(2));
      expect(steps.last.leftNumerator, 7);
      expect(steps.last.leftDenominator, 5);
      expect(steps.last.rightNumerator, 1);
      expect(steps.last.rightDenominator, 1);
    });

    test('calculates the aileron tolerance range exactly', () {
      final range = engine.toleranceRange(
        ExactFraction(7, 8),
        ExactFraction(1, 5),
      );
      expect(range.minimum, ExactFraction(27, 40));
      expect(range.maximum, ExactFraction(43, 40));
      expect(range.maximum.mixedNumberText, '1 3/40');
    });

    test('identifies already-reduced values and large common factors', () {
      final reduced = engine.reduction(6, 16);
      expect(reduced.commonFactor, 2);
      expect(reduced.reduced, ExactFraction(3, 8));
      expect(engine.reduction(21, 80).wasAlreadyReduced, isTrue);
      final large = engine.reduction(1000000, 2500000);
      expect(large.commonFactor, 500000);
      expect(large.reduced, ExactFraction(2, 5));
    });

    test('converts authoritative layout values to mixed numbers', () {
      expect(ExactFraction(87, 32).mixedNumberText, '2 23/32');
      expect(ExactFraction(29, 16).mixedNumberText, '1 13/16');
    });
  });
}
