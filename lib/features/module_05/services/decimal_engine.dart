import '../models/decimal_models.dart';

final class DecimalEngine {
  const DecimalEngine();

  DecimalQuantity parse(String source) => DecimalQuantity.parse(source);

  List<DecimalPlace> placeValues(DecimalQuantity value) {
    final text = value.text;
    final parts = text.split('.');
    final whole = parts[0];
    final fractional = parts.length == 2 ? parts[1] : '';
    return [
      for (var index = 0; index < whole.length; index++)
        DecimalPlace(
          digit: int.parse(whole[index]),
          exponent: whole.length - index - 1,
          name: _placeName(whole.length - index - 1),
        ),
      for (var index = 0; index < fractional.length; index++)
        DecimalPlace(
          digit: int.parse(fractional[index]),
          exponent: -(index + 1),
          name: _placeName(-(index + 1)),
        ),
    ];
  }

  String read(DecimalQuantity value) {
    final parts = value.text.split('.');
    if (parts.length == 1) {
      return parts.single;
    }
    final fractional = parts[1];
    return '${parts[0]} and ${BigInt.parse(fractional)} ${_fractionalGroupName(fractional.length)}';
  }

  int compare(DecimalQuantity left, DecimalQuantity right) =>
      left.compareTo(right).sign;

  DecimalOperationResult add(DecimalQuantity left, DecimalQuantity right) {
    final scale = left.scale > right.scale ? left.scale : right.scale;
    final result = DecimalQuantity(
      left.coefficientAtScale(scale) + right.coefficientAtScale(scale),
      scale,
    );
    return DecimalOperationResult(
      left: left,
      right: right,
      result: result,
      explanation:
          'Align decimal points at $scale fractional place${scale == 1 ? '' : 's'}, then add each column.',
    );
  }

  DecimalQuantity sum(Iterable<DecimalQuantity> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) {
      throw const DecimalException('At least one decimal is required.');
    }
    return list
        .skip(1)
        .fold(list.first, (total, value) => add(total, value).result);
  }

  DecimalOperationResult subtract(DecimalQuantity left, DecimalQuantity right) {
    final scale = left.scale > right.scale ? left.scale : right.scale;
    final coefficient =
        left.coefficientAtScale(scale) - right.coefficientAtScale(scale);
    if (coefficient.isNegative) {
      throw const DecimalException(
        'A negative decimal result belongs to Module 9.',
      );
    }
    return DecimalOperationResult(
      left: left,
      right: right,
      result: DecimalQuantity(coefficient, scale),
      explanation:
          'Align decimal points at $scale fractional place${scale == 1 ? '' : 's'}, then subtract each column.',
    );
  }

  DecimalOperationResult multiply(DecimalQuantity left, DecimalQuantity right) {
    final result = DecimalQuantity(
      left.coefficient * right.coefficient,
      left.scale + right.scale,
    );
    return DecimalOperationResult(
      left: left,
      right: right,
      result: result,
      explanation:
          'Multiply as whole-number coefficients, then place ${left.scale + right.scale} total decimal digit${left.scale + right.scale == 1 ? '' : 's'}.',
    );
  }

  DecimalDivisionResult divide(
    DecimalQuantity dividend,
    DecimalQuantity divisor, {
    int maxCycleDigits = 256,
  }) {
    if (divisor.isZero) {
      throw const DecimalException('Cannot divide by zero.');
    }
    final fraction = BigDecimalFraction(
      dividend.coefficient * BigInt.from(10).pow(divisor.scale),
      divisor.coefficient * BigInt.from(10).pow(dividend.scale),
    );
    final expansion = const FractionDecimalEngine().expand(
      fraction,
      maxCycleDigits: maxCycleDigits,
    );
    return DecimalDivisionResult(
      exactFraction: fraction,
      expansion: expansion,
      terminatingValue: expansion.isTerminating
          ? DecimalQuantity.parse(expansion.plainText)
          : null,
    );
  }

  RoundingResult roundHalfUp(DecimalQuantity value, int decimalPlaces) {
    if (decimalPlaces < 0) {
      throw const DecimalException('Rounding precision cannot be negative.');
    }
    if (decimalPlaces >= value.scale) {
      final retained = value.scale == 0
          ? (value.coefficient % BigInt.from(10)).toInt()
          : (value.coefficient % BigInt.from(10)).toInt();
      return RoundingResult(
        original: value,
        value: value,
        decimalPlaces: decimalPlaces,
        retainedDigit: retained,
        inspectionDigit: 0,
        roundedUp: false,
        displayText: value.toFixed(decimalPlaces),
      );
    }
    final removedPlaces = value.scale - decimalPlaces;
    final factor = BigInt.from(10).pow(removedPlaces);
    final retainedCoefficient = value.coefficient ~/ factor;
    final inspectionFactor = BigInt.from(10).pow(removedPlaces - 1);
    final inspectionDigit =
        ((value.coefficient ~/ inspectionFactor) % BigInt.from(10)).toInt();
    final retainedDigit = (retainedCoefficient % BigInt.from(10)).toInt();
    final roundedUp = inspectionDigit >= 5;
    final roundedCoefficient = roundedUp
        ? retainedCoefficient + BigInt.one
        : retainedCoefficient;
    final rounded = DecimalQuantity(roundedCoefficient, decimalPlaces);
    return RoundingResult(
      original: value,
      value: rounded,
      decimalPlaces: decimalPlaces,
      retainedDigit: retainedDigit,
      inspectionDigit: inspectionDigit,
      roundedUp: roundedUp,
      displayText: rounded.toFixed(decimalPlaces),
    );
  }

  static String _placeName(int exponent) => switch (exponent) {
    0 => 'ones',
    1 => 'tens',
    2 => 'hundreds',
    3 => 'thousands',
    -1 => 'tenths',
    -2 => 'hundredths',
    -3 => 'thousandths',
    -4 => 'ten-thousandths',
    -5 => 'hundred-thousandths',
    -6 => 'millionths',
    _ => '10^$exponent place',
  };

  static String _fractionalGroupName(int digits) => switch (digits) {
    1 => 'tenths',
    2 => 'hundredths',
    3 => 'thousandths',
    4 => 'ten-thousandths',
    5 => 'hundred-thousandths',
    6 => 'millionths',
    _ => 'parts in 10^$digits',
  };
}

final class FractionDecimalEngine {
  const FractionDecimalEngine();

  BigDecimalFraction decimalToFraction(DecimalQuantity value) => value.fraction;

  RepeatingDecimal expand(
    BigDecimalFraction fraction, {
    int maxCycleDigits = 256,
  }) {
    if (maxCycleDigits < 1) {
      throw const DecimalException('Cycle bound must be at least one digit.');
    }
    final whole = fraction.numerator ~/ fraction.denominator;
    var remainder = fraction.numerator.remainder(fraction.denominator);
    if (remainder == BigInt.zero) {
      return RepeatingDecimal(
        whole: whole.toString(),
        nonRepeating: '',
        repeating: '',
      );
    }
    final seen = <BigInt, int>{};
    final digits = <String>[];
    int? cycleStart;
    while (remainder != BigInt.zero) {
      final prior = seen[remainder];
      if (prior != null) {
        cycleStart = prior;
        break;
      }
      if (digits.length >= maxCycleDigits) {
        throw DecimalException(
          'Repeating cycle exceeds the $maxCycleDigits-digit learning limit.',
        );
      }
      seen[remainder] = digits.length;
      remainder *= BigInt.from(10);
      digits.add((remainder ~/ fraction.denominator).toString());
      remainder = remainder.remainder(fraction.denominator);
    }
    final split = cycleStart ?? digits.length;
    return RepeatingDecimal(
      whole: whole.toString(),
      nonRepeating: digits.take(split).join(),
      repeating: cycleStart == null ? '' : digits.skip(split).join(),
    );
  }
}

final class ShopSixtyFourthsEngine {
  const ShopSixtyFourthsEngine([this._decimals = const DecimalEngine()]);

  final DecimalEngine _decimals;

  ShopFractionResult convert(DecimalQuantity value) {
    final timesSixtyFour = _decimals
        .multiply(value, DecimalQuantity(BigInt.from(64), 0))
        .result;
    final rounded = _decimals.roundHalfUp(timesSixtyFour, 0);
    final numerator = rounded.value.coefficient;
    return ShopFractionResult(
      source: value,
      timesSixtyFour: timesSixtyFour,
      roundedNumerator: numerator,
      unreducedText: '$numerator/64',
      reduced: BigDecimalFraction(numerator, BigInt.from(64)),
    );
  }

  DrillReamResult drillForReamedSize(DecimalQuantity reamedSize) {
    final reamed = convert(reamedSize);
    if (reamed.roundedNumerator < BigInt.one) {
      throw const DecimalException(
        'The reamed size must exceed the 1/64 inch undersize.',
      );
    }
    final drillNumerator = reamed.roundedNumerator - BigInt.one;
    return DrillReamResult(
      reamedDecimal: reamedSize,
      reamedFraction: reamed.reduced,
      undersize: BigDecimalFraction(BigInt.one, BigInt.from(64)),
      drillFraction: BigDecimalFraction(drillNumerator, BigInt.from(64)),
    );
  }
}
