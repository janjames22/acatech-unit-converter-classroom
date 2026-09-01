import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/calculator/calculator.dart';

void main() {
  const engine = CalculatorEngine();

  group('CalculatorEngine basic expressions', () {
    test('evaluates arithmetic, decimals, negatives, and parentheses', () {
      expect(engine.evaluate('2+2'), 4);
      expect(engine.evaluate('10/2'), 5);
      expect(engine.evaluate('1.5 + 2.25'), 3.75);
      expect(engine.evaluate('-5 + 2'), -3);
      expect(engine.evaluate('(2+3)*4'), 20);
      expect(engine.evaluate('2×3+8÷4'), 8);
    });

    test('uses standard precedence and right-associative powers', () {
      expect(engine.evaluate('2+3*4'), 14);
      expect(engine.evaluate('2^3^2'), 512);
      expect(engine.evaluate('-2^2'), -4);
      expect(engine.evaluate('2^-2'), closeTo(0.25, 1e-12));
    });

    test('supports fraction and deterministic percentage expressions', () {
      expect(engine.evaluate('1/2 + 1/4'), closeTo(0.75, 1e-12));
      expect(engine.evaluate('50%'), closeTo(0.5, 1e-12));
      expect(engine.evaluate('200*10%'), closeTo(20, 1e-12));
    });

    test('accepts scientific numeric literals', () {
      expect(engine.evaluate('1e3 + 2.5e-1'), closeTo(1000.25, 1e-12));
    });
  });

  group('CalculatorEngine scientific expressions', () {
    test('evaluates root, power, exponential, and reciprocal functions', () {
      expect(engine.evaluate('sqrt(81)'), 9);
      expect(engine.evaluate('3^4'), 81);
      expect(engine.evaluate('exp(1)'), closeTo(math.e, 1e-12));
      expect(engine.evaluate('recip(4)'), closeTo(0.25, 1e-12));
    });

    test('evaluates trigonometry in degree mode', () {
      expect(engine.evaluate('sin(90)'), closeTo(1, 1e-12));
      expect(engine.evaluate('cos(180)'), closeTo(-1, 1e-12));
      expect(engine.evaluate('tan(45)'), closeTo(1, 1e-12));
    });

    test('evaluates trigonometry in radian mode', () {
      expect(
        engine.evaluate('sin(pi/2)', angleMode: CalculatorAngleMode.radians),
        closeTo(1, 1e-12),
      );
      expect(
        engine.evaluate('cos(pi)', angleMode: CalculatorAngleMode.radians),
        closeTo(-1, 1e-12),
      );
    });

    test('evaluates logarithms and constants', () {
      expect(engine.evaluate('log(1000)'), closeTo(3, 1e-12));
      expect(engine.evaluate('ln(e)'), closeTo(1, 1e-12));
      expect(engine.evaluate('π'), closeTo(math.pi, 1e-12));
    });
  });

  group('CalculatorEngine error handling', () {
    test('rejects division and reciprocal by zero', () {
      expect(
        () => engine.evaluate('1/0'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.type,
            'type',
            CalculatorErrorType.divisionByZero,
          ),
        ),
      );
      expect(
        () => engine.evaluate('recip(0)'),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('rejects invalid and incomplete expressions', () {
      for (final expression in ['', '2+', '(2+3', '2 3', 'unknown(1)']) {
        expect(
          () => engine.evaluate(expression),
          throwsA(isA<CalculatorException>()),
          reason: expression,
        );
      }
    });

    test('rejects scientific domain and non-finite errors', () {
      for (final expression in ['sqrt(-1)', 'log(0)', 'ln(-2)', 'tan(90)']) {
        expect(
          () => engine.evaluate(expression),
          throwsA(
            isA<CalculatorException>().having(
              (error) => error.type,
              'type',
              CalculatorErrorType.domain,
            ),
          ),
          reason: expression,
        );
      }
      expect(
        () => engine.evaluate('exp(10000)'),
        throwsA(
          isA<CalculatorException>().having(
            (error) => error.type,
            'type',
            CalculatorErrorType.nonFinite,
          ),
        ),
      );
    });

    test('rejects unsupported numeric literals and characters', () {
      for (final expression in ['1e9999', '.', '2@3']) {
        expect(
          () => engine.evaluate(expression),
          throwsA(isA<CalculatorException>()),
          reason: expression,
        );
      }
    });
  });

  group('CalculatorNumberFormatter', () {
    test('removes floating point noise and normalizes zero', () {
      expect(CalculatorNumberFormatter.format(0.30000000000000004), '0.3');
      expect(CalculatorNumberFormatter.format(-0.0), '0');
      expect(CalculatorNumberFormatter.format(1000), '1000');
    });

    test('uses normalized scientific notation for extreme magnitudes', () {
      expect(CalculatorNumberFormatter.format(1.25e15), '1.25e15');
      expect(CalculatorNumberFormatter.format(1e-12), '1e-12');
    });

    test('rejects non-finite values and invalid precision', () {
      expect(
        () => CalculatorNumberFormatter.format(double.infinity),
        throwsArgumentError,
      );
      expect(
        () => CalculatorNumberFormatter.format(1, significantDigits: 0),
        throwsRangeError,
      );
    });
  });
}
