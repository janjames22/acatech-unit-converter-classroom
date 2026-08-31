import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/converter/converter.dart';

void main() {
  group('ConversionNumberFormatter', () {
    test('formats ordinary values without insignificant zeroes', () {
      expect(ConversionNumberFormatter.format(1234), '1234');
      expect(ConversionNumberFormatter.format(12.340000), '12.34');
      expect(ConversionNumberFormatter.format(0.30000000000000004), '0.3');
      expect(ConversionNumberFormatter.format(-42.5), '-42.5');
    });

    test('honors significant digits in fixed notation', () {
      expect(
        ConversionNumberFormatter.format(1234.567, significantDigits: 4),
        '1235',
      );
      expect(
        ConversionNumberFormatter.format(0.001234567, significantDigits: 4),
        '0.001235',
      );
    });

    test('normalizes positive and negative zero', () {
      expect(ConversionNumberFormatter.format(0), '0');
      expect(ConversionNumberFormatter.format(-0.0), '0');
    });

    test('uses compact normalized scientific notation at default bounds', () {
      expect(ConversionNumberFormatter.format(1e-10), '1e-10');
      expect(ConversionNumberFormatter.format(1e12), '1e12');
      expect(ConversionNumberFormatter.format(-2.5e15), '-2.5e15');
      expect(ConversionNumberFormatter.format(1e-9), '0.000000001');
    });

    test('supports custom scientific bounds', () {
      expect(
        ConversionNumberFormatter.format(
          12345,
          scientificLowerBound: 1e-3,
          scientificUpperBound: 1000,
        ),
        '1.2345e4',
      );
    });

    test('represents non-finite values explicitly', () {
      expect(ConversionNumberFormatter.format(double.nan), 'NaN');
      expect(ConversionNumberFormatter.format(double.infinity), '∞');
      expect(ConversionNumberFormatter.format(double.negativeInfinity), '-∞');
    });

    test('validates formatter options', () {
      expect(
        () => ConversionNumberFormatter.format(1, significantDigits: 0),
        throwsRangeError,
      );
      expect(
        () => ConversionNumberFormatter.format(1, significantDigits: 22),
        throwsRangeError,
      );
      expect(
        () => ConversionNumberFormatter.format(1, scientificLowerBound: 0),
        throwsArgumentError,
      );
      expect(
        () => ConversionNumberFormatter.format(
          1,
          scientificLowerBound: 10,
          scientificUpperBound: 10,
        ),
        throwsArgumentError,
      );
    });
  });
}
