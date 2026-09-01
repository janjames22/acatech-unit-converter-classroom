import 'dart:math' as math;

abstract final class CalculatorNumberFormatter {
  static String format(double value, {int significantDigits = 12}) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Must be finite.');
    }
    if (significantDigits < 1 || significantDigits > 21) {
      throw RangeError.range(significantDigits, 1, 21, 'significantDigits');
    }
    if (value == 0) {
      return '0';
    }

    final magnitude = value.abs();
    if (magnitude < 1e-9 || magnitude >= 1e12) {
      final raw = value.toStringAsExponential(significantDigits - 1);
      final parts = raw.split('e');
      return '${_strip(parts.first)}e${int.parse(parts.last)}';
    }

    final exponent = (math.log(magnitude) / math.ln10).floor();
    final fractionDigits = (significantDigits - exponent - 1).clamp(0, 20);
    return _strip(value.toStringAsFixed(fractionDigits));
  }

  static String _strip(String value) {
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
}
