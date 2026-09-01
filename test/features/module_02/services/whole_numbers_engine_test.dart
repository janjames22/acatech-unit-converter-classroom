import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_02/module_02.dart';

void main() {
  const engine = WholeNumbersEngine();

  group('four whole-number operations', () {
    test('matches authoritative addition and subtraction examples', () {
      expect(engine.add([4314, 122, 93132, 10]), 97578);
      expect(engine.subtract(97564, 3461), 94103);
    });

    test('matches multiplication and remainder examples', () {
      expect(engine.multiply(35, 18), 630);
      expect(
        engine.divide(218, 7),
        const DivisionResult(quotient: 31, remainder: 1),
      );
      expect(engine.divide(48, 8).isExact, isTrue);
    });

    test('rejects negative inputs, negative results, and division by zero', () {
      expect(() => engine.add([-1, 2]), throwsA(isA<WholeNumberException>()));
      expect(
        () => engine.subtract(2, 3),
        throwsA(
          isA<WholeNumberException>().having(
            (error) => error.message,
            'message',
            contains('Module 9'),
          ),
        ),
      );
      expect(() => engine.divide(5, 0), throwsA(isA<WholeNumberException>()));
    });
  });

  group('factors, primes, and multiples', () {
    test('lists factors and prime factorizations of 48 and 60', () {
      expect(engine.factors(48), [1, 2, 3, 4, 6, 8, 12, 16, 24, 48]);
      expect(engine.factors(60), [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]);
      expect(engine.primeFactorization(48), const [
        PrimeFactor(base: 2, exponent: 4),
        PrimeFactor(base: 3, exponent: 1),
      ]);
      expect(engine.primeFactorization(60), const [
        PrimeFactor(base: 2, exponent: 2),
        PrimeFactor(base: 3, exponent: 1),
        PrimeFactor(base: 5, exponent: 1),
      ]);
    });

    test('handles one, primes, repeated factors, GCD, and LCM', () {
      expect(engine.factors(1), [1]);
      expect(engine.primeFactorization(1), isEmpty);
      expect(engine.primeFactorization(13), const [
        PrimeFactor(base: 13, exponent: 1),
      ]);
      expect(engine.greatestCommonDivisor(48, 60), 12);
      expect(engine.leastCommonMultiple(16, 24), 48);
      expect(engine.multiples(5, count: 4), [5, 10, 15, 20]);
    });

    test('rejects zero where a positive factor input is required', () {
      expect(() => engine.factors(0), throwsA(isA<WholeNumberException>()));
      expect(
        () => engine.leastCommonMultiple(0, 4),
        throwsA(isA<WholeNumberException>()),
      );
    });
  });

  group('place value and divisibility', () {
    test('creates place-value rows including zero', () {
      expect(engine.placeValues(0).single.contribution, 0);
      final rows = engine.placeValues(93132);
      expect(rows.map((row) => row.contribution), [90000, 3000, 100, 30, 2]);
      expect(rows.first.placeName, 'ten-thousands');
    });

    test('explains the four specified divisibility checks for 3816', () {
      for (final rule in [
        DivisibilityRule.by3,
        DivisibilityRule.by4,
        DivisibilityRule.by8,
        DivisibilityRule.by9,
      ]) {
        final result = engine.checkDivisibility(3816, rule);
        expect(result.isDivisible, isTrue, reason: 'rule ${rule.divisor}');
        expect(result.explanation, contains('${rule.divisor}'));
      }
    });

    test('supports every curriculum rule and negative results', () {
      for (final rule in DivisibilityRule.values) {
        expect(engine.checkDivisibility(360, rule).isDivisible, isTrue);
      }
      expect(
        engine.checkDivisibility(17, DivisibilityRule.by3).isDivisible,
        isFalse,
      );
      expect(
        engine.checkDivisibility(17, DivisibilityRule.by3).explanation,
        contains('not divisible'),
      );
    });
  });
}
