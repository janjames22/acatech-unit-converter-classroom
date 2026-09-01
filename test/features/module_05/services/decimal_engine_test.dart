import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_05/module_05.dart';

void main() {
  const engine = DecimalEngine();
  const fractions = FractionDecimalEngine();
  const shop = ShopSixtyFourthsEngine();

  group('exact decimal representation and place value', () {
    test('normalizes leading and trailing zeros without binary floats', () {
      expect(engine.parse('0002.3400').text, '2.34');
      expect(engine.parse('0.000').text, '0');
      expect(engine.parse('0.50'), engine.parse('0.5'));
    });

    test('retains very long exact input using a BigInt coefficient', () {
      const source = '123456789012345678901234567890.000000000000000001';
      expect(engine.parse(source).text, source);
    });

    test('rejects invalid and out-of-scope negative decimal input', () {
      expect(() => engine.parse('1.2.3'), throwsA(isA<DecimalException>()));
      expect(() => engine.parse('-0.5'), throwsA(isA<DecimalException>()));
    });

    test('identifies places and reads the fractional group', () {
      final places = engine.placeValues(engine.parse('37.205'));
      expect(places.map((place) => place.name), [
        'tens',
        'ones',
        'tenths',
        'hundredths',
        'thousandths',
      ]);
      expect(places.map((place) => place.digit), [3, 7, 2, 0, 5]);
      expect(engine.read(engine.parse('37.005')), '37 and 5 thousandths');
    });

    test('compares aligned values exactly', () {
      expect(engine.compare(engine.parse('0.763'), engine.parse('0.736')), 1);
      expect(engine.compare(engine.parse('0.50'), engine.parse('0.5')), 0);
      expect(engine.compare(engine.parse('0.099'), engine.parse('0.1')), -1);
    });
  });

  group('decimal operations', () {
    test('adds without the 0.1 plus 0.2 floating-point artifact', () {
      expect(
        engine.add(engine.parse('0.1'), engine.parse('0.2')).result.text,
        '0.3',
      );
      expect(
        engine.sum([
          engine.parse('2.34'),
          engine.parse('37.5'),
          engine.parse('0.09'),
        ]).text,
        '39.93',
      );
    });

    test('matches the authoritative subtraction example', () {
      expect(
        engine
            .subtract(engine.parse('37.272'), engine.parse('14.88'))
            .result
            .text,
        '22.392',
      );
      expect(
        () => engine.subtract(engine.parse('1'), engine.parse('2')),
        throwsA(isA<DecimalException>()),
      );
    });

    test('matches the authoritative multiplication example', () {
      expect(
        engine.multiply(engine.parse('9.45'), engine.parse('120')).result.text,
        '1134',
      );
    });

    test('returns exact terminating and repeating division results', () {
      final exact = engine.divide(engine.parse('262.6'), engine.parse('40.4'));
      expect(exact.exactFraction.text, '13/2');
      expect(exact.terminatingValue?.text, '6.5');
      expect(exact.expansion.plainText, '6.5');

      final repeating = engine.divide(engine.parse('1'), engine.parse('3'));
      expect(repeating.terminatingValue, isNull);
      expect(repeating.expansion.plainText, '0.(3)');
      expect(
        () => engine.divide(engine.parse('1'), engine.parse('0')),
        throwsA(isA<DecimalException>()),
      );
    });
  });

  group('rounding and fraction conversion', () {
    test('applies the three curriculum half-up examples', () {
      expect(engine.roundHalfUp(engine.parse('2.1938'), 1).displayText, '2.2');
      expect(engine.roundHalfUp(engine.parse('3.1648'), 2).displayText, '3.16');
      expect(
        engine.roundHalfUp(engine.parse('3.7487'), 3).displayText,
        '3.749',
      );
    });

    test('rounds an exact midpoint upward and preserves requested zeros', () {
      final midpoint = engine.roundHalfUp(engine.parse('2.150'), 1);
      expect(midpoint.displayText, '2.2');
      expect(midpoint.inspectionDigit, 5);
      expect(midpoint.roundedUp, isTrue);
      expect(engine.roundHalfUp(engine.parse('2'), 3).displayText, '2.000');
    });

    test('converts exact fractions and bounds repeating cycles', () {
      expect(fractions.decimalToFraction(engine.parse('0.3125')).text, '5/16');
      expect(
        fractions
            .expand(BigDecimalFraction(BigInt.one, BigInt.from(2)))
            .plainText,
        '0.5',
      );
      expect(
        fractions
            .expand(BigDecimalFraction(BigInt.from(3), BigInt.from(8)))
            .plainText,
        '0.375',
      );
      expect(
        fractions
            .expand(BigDecimalFraction(BigInt.one, BigInt.from(6)))
            .plainText,
        '0.1(6)',
      );
      expect(
        () => fractions.expand(
          BigDecimalFraction(BigInt.one, BigInt.from(97)),
          maxCycleDigits: 5,
        ),
        throwsA(isA<DecimalException>()),
      );
    });

    test('performs shop 64ths and drill/ream steps without early rounding', () {
      final converted = shop.convert(engine.parse('0.3123'));
      expect(converted.timesSixtyFour.text, '19.9872');
      expect(converted.roundedNumerator, BigInt.from(20));
      expect(converted.unreducedText, '20/64');
      expect(converted.reduced.text, '5/16');

      final drill = shop.drillForReamedSize(engine.parse('0.763'));
      expect(drill.reamedFraction.text, '49/64');
      expect(drill.undersize.text, '1/64');
      expect(drill.drillFraction.text, '3/4');
    });
  });
}
