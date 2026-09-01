final class DecimalQuantity implements Comparable<DecimalQuantity> {
  factory DecimalQuantity(BigInt coefficient, int scale) {
    if (scale < 0) {
      throw const DecimalException('Decimal scale cannot be negative.');
    }
    if (coefficient.isNegative) {
      throw const DecimalException(
        'Negative decimals are introduced in Module 9.',
      );
    }
    var normalizedCoefficient = coefficient;
    var normalizedScale = scale;
    while (normalizedScale > 0 &&
        normalizedCoefficient.remainder(BigInt.from(10)) == BigInt.zero) {
      normalizedCoefficient ~/= BigInt.from(10);
      normalizedScale--;
    }
    return DecimalQuantity._(normalizedCoefficient, normalizedScale);
  }

  factory DecimalQuantity.parse(String source) {
    final value = source.trim().replaceAll(',', '');
    if (value.startsWith('-') || value.startsWith('−')) {
      throw const DecimalException(
        'Negative decimals are introduced in Module 9.',
      );
    }
    final match = RegExp(r'^\+?(\d+)(?:\.(\d*))?$').firstMatch(value);
    if (match == null) {
      throw const DecimalException('Enter a valid decimal number.');
    }
    final whole = match.group(1)!;
    final fractional = match.group(2) ?? '';
    final digits = '$whole$fractional';
    return DecimalQuantity(BigInt.parse(digits), fractional.length);
  }

  const DecimalQuantity._(this.coefficient, this.scale);

  final BigInt coefficient;
  final int scale;

  bool get isZero => coefficient == BigInt.zero;

  BigDecimalFraction get fraction =>
      BigDecimalFraction(coefficient, BigInt.from(10).pow(scale));

  String get text {
    final digits = coefficient.toString();
    if (scale == 0) {
      return digits;
    }
    if (digits.length <= scale) {
      return '0.${List.filled(scale - digits.length, '0').join()}$digits';
    }
    final point = digits.length - scale;
    return '${digits.substring(0, point)}.${digits.substring(point)}';
  }

  String toFixed(int decimalPlaces) {
    if (decimalPlaces < scale) {
      throw const DecimalException(
        'Round the value before requesting fewer decimal places.',
      );
    }
    if (decimalPlaces == 0) {
      return text;
    }
    final current = scale == 0 ? '$text.' : text;
    return '$current${List.filled(decimalPlaces - scale, '0').join()}';
  }

  BigInt coefficientAtScale(int targetScale) {
    if (targetScale < scale) {
      throw const DecimalException('Target scale cannot discard digits.');
    }
    return coefficient * BigInt.from(10).pow(targetScale - scale);
  }

  @override
  int compareTo(DecimalQuantity other) {
    final alignedScale = scale > other.scale ? scale : other.scale;
    return coefficientAtScale(
      alignedScale,
    ).compareTo(other.coefficientAtScale(alignedScale));
  }

  @override
  bool operator ==(Object other) =>
      other is DecimalQuantity &&
      coefficient == other.coefficient &&
      scale == other.scale;

  @override
  int get hashCode => Object.hash(coefficient, scale);

  @override
  String toString() => text;
}

final class BigDecimalFraction {
  factory BigDecimalFraction(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw const DecimalException('A fraction denominator cannot be zero.');
    }
    var normalizedNumerator = numerator;
    var normalizedDenominator = denominator;
    if (normalizedDenominator.isNegative) {
      normalizedNumerator = -normalizedNumerator;
      normalizedDenominator = -normalizedDenominator;
    }
    if (normalizedNumerator.isNegative) {
      throw const DecimalException(
        'Negative values are introduced in Module 9.',
      );
    }
    final divisor = normalizedNumerator.gcd(normalizedDenominator);
    return BigDecimalFraction._(
      normalizedNumerator ~/ divisor,
      normalizedDenominator ~/ divisor,
    );
  }

  const BigDecimalFraction._(this.numerator, this.denominator);

  final BigInt numerator;
  final BigInt denominator;

  String get text => denominator == BigInt.one
      ? numerator.toString()
      : '$numerator/$denominator';

  @override
  bool operator ==(Object other) =>
      other is BigDecimalFraction &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}

final class DecimalPlace {
  const DecimalPlace({
    required this.digit,
    required this.exponent,
    required this.name,
  });

  final int digit;
  final int exponent;
  final String name;
}

final class DecimalOperationResult {
  const DecimalOperationResult({
    required this.left,
    required this.right,
    required this.result,
    required this.explanation,
  });

  final DecimalQuantity left;
  final DecimalQuantity right;
  final DecimalQuantity result;
  final String explanation;
}

final class DecimalDivisionResult {
  const DecimalDivisionResult({
    required this.exactFraction,
    required this.expansion,
    this.terminatingValue,
  });

  final BigDecimalFraction exactFraction;
  final RepeatingDecimal expansion;
  final DecimalQuantity? terminatingValue;
}

final class RoundingResult {
  const RoundingResult({
    required this.original,
    required this.value,
    required this.decimalPlaces,
    required this.retainedDigit,
    required this.inspectionDigit,
    required this.roundedUp,
    required this.displayText,
  });

  final DecimalQuantity original;
  final DecimalQuantity value;
  final int decimalPlaces;
  final int retainedDigit;
  final int inspectionDigit;
  final bool roundedUp;
  final String displayText;
}

final class RepeatingDecimal {
  const RepeatingDecimal({
    required this.whole,
    required this.nonRepeating,
    required this.repeating,
  });

  final String whole;
  final String nonRepeating;
  final String repeating;

  bool get isTerminating => repeating.isEmpty;

  String get plainText {
    if (nonRepeating.isEmpty && repeating.isEmpty) {
      return whole;
    }
    if (repeating.isEmpty) {
      return '$whole.$nonRepeating';
    }
    return '$whole.$nonRepeating($repeating)';
  }
}

final class ShopFractionResult {
  const ShopFractionResult({
    required this.source,
    required this.timesSixtyFour,
    required this.roundedNumerator,
    required this.unreducedText,
    required this.reduced,
  });

  final DecimalQuantity source;
  final DecimalQuantity timesSixtyFour;
  final BigInt roundedNumerator;
  final String unreducedText;
  final BigDecimalFraction reduced;
}

final class DrillReamResult {
  const DrillReamResult({
    required this.reamedDecimal,
    required this.reamedFraction,
    required this.undersize,
    required this.drillFraction,
  });

  final DecimalQuantity reamedDecimal;
  final BigDecimalFraction reamedFraction;
  final BigDecimalFraction undersize;
  final BigDecimalFraction drillFraction;
}

final class DecimalException implements Exception {
  const DecimalException(this.message);

  final String message;

  @override
  String toString() => message;
}
