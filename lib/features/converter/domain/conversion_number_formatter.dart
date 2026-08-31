import 'dart:math' as math;

/// Stable, locale-neutral formatting for calculated conversion values.
///
/// It avoids binary floating-point noise, removes insignificant trailing
/// zeroes, normalizes negative zero, and switches to scientific notation for
/// values that are cumbersome to read in fixed notation.
abstract final class ConversionNumberFormatter {
  static const int defaultSignificantDigits = 12;
  static const double defaultScientificLowerBound = 1e-9;
  static const double defaultScientificUpperBound = 1e12;

  static String format(
    double value, {
    int significantDigits = defaultSignificantDigits,
    double scientificLowerBound = defaultScientificLowerBound,
    double scientificUpperBound = defaultScientificUpperBound,
  }) {
    _validateOptions(
      significantDigits: significantDigits,
      scientificLowerBound: scientificLowerBound,
      scientificUpperBound: scientificUpperBound,
    );

    if (value.isNaN) {
      return 'NaN';
    }
    if (value == double.infinity) {
      return '∞';
    }
    if (value == double.negativeInfinity) {
      return '-∞';
    }
    if (value == 0) {
      return '0';
    }

    final magnitude = value.abs();
    if (magnitude < scientificLowerBound || magnitude >= scientificUpperBound) {
      return _scientific(value, significantDigits);
    }

    final exponent = (math.log(magnitude) / math.ln10).floor();
    final fractionDigits = (significantDigits - exponent - 1).clamp(0, 20);
    return _stripTrailingZeroes(value.toStringAsFixed(fractionDigits));
  }

  static String _scientific(double value, int significantDigits) {
    final raw = value.toStringAsExponential(significantDigits - 1);
    final parts = raw.split('e');
    final coefficient = _stripTrailingZeroes(parts.first);
    final exponent = int.parse(parts.last);
    return '${coefficient}e$exponent';
  }

  static String _stripTrailingZeroes(String value) {
    if (!value.contains('.')) {
      return value;
    }

    var end = value.length;
    while (end > 0 && value.codeUnitAt(end - 1) == 0x30) {
      end--;
    }
    if (end > 0 && value.codeUnitAt(end - 1) == 0x2e) {
      end--;
    }
    final result = value.substring(0, end);
    return result == '-0' ? '0' : result;
  }

  static void _validateOptions({
    required int significantDigits,
    required double scientificLowerBound,
    required double scientificUpperBound,
  }) {
    if (significantDigits < 1 || significantDigits > 21) {
      throw RangeError.range(significantDigits, 1, 21, 'significantDigits');
    }
    if (!scientificLowerBound.isFinite || scientificLowerBound <= 0) {
      throw ArgumentError.value(
        scientificLowerBound,
        'scientificLowerBound',
        'must be finite and greater than zero',
      );
    }
    if (!scientificUpperBound.isFinite ||
        scientificUpperBound <= scientificLowerBound) {
      throw ArgumentError.value(
        scientificUpperBound,
        'scientificUpperBound',
        'must be finite and greater than scientificLowerBound',
      );
    }
  }
}
