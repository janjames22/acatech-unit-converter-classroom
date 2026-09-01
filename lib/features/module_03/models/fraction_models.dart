enum FractionClassification { proper, improper, whole }

enum CommonDenominatorMethod { leastCommonMultiple, productOfDenominators }

final class ExactFraction implements Comparable<ExactFraction> {
  factory ExactFraction(int numerator, int denominator) {
    if (denominator == 0) {
      throw const FractionException('A fraction denominator cannot be zero.');
    }
    if (numerator == 0) {
      return const ExactFraction._(0, 1);
    }
    final sign = denominator < 0 ? -1 : 1;
    final signedNumerator = numerator * sign;
    final positiveDenominator = denominator.abs();
    final divisor = _gcd(signedNumerator.abs(), positiveDenominator);
    return ExactFraction._(
      signedNumerator ~/ divisor,
      positiveDenominator ~/ divisor,
    );
  }

  const ExactFraction._(this.numerator, this.denominator);

  static const zero = ExactFraction._(0, 1);
  static const one = ExactFraction._(1, 1);

  final int numerator;
  final int denominator;

  FractionClassification get classification {
    if (denominator == 1) {
      return FractionClassification.whole;
    }
    return numerator.abs() < denominator
        ? FractionClassification.proper
        : FractionClassification.improper;
  }

  bool get isZero => numerator == 0;

  ExactFraction operator +(ExactFraction other) => ExactFraction(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );

  ExactFraction operator -(ExactFraction other) => ExactFraction(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );

  ExactFraction operator *(ExactFraction other) => ExactFraction(
    numerator * other.numerator,
    denominator * other.denominator,
  );

  ExactFraction operator /(ExactFraction other) {
    if (other.isZero) {
      throw const FractionException(
        'Division by a zero fraction is undefined.',
      );
    }
    return ExactFraction(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  String get fractionText =>
      denominator == 1 ? '$numerator' : '$numerator/$denominator';

  String get mixedNumberText {
    if (denominator == 1 || numerator.abs() < denominator) {
      return fractionText;
    }
    final whole = numerator ~/ denominator;
    final remainder = numerator.abs() % denominator;
    return remainder == 0 ? '$whole' : '$whole $remainder/$denominator';
  }

  @override
  int compareTo(ExactFraction other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  @override
  bool operator ==(Object other) =>
      other is ExactFraction &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => fractionText;

  static int _gcd(int left, int right) {
    var a = left;
    var b = right;
    while (b != 0) {
      final remainder = a % b;
      a = b;
      b = remainder;
    }
    return a;
  }
}

final class EquivalentFractionStep {
  const EquivalentFractionStep({
    required this.original,
    required this.multiplier,
    required this.numerator,
    required this.denominator,
  });

  final ExactFraction original;
  final int multiplier;
  final int numerator;
  final int denominator;

  ExactFraction get value => ExactFraction(numerator, denominator);

  String get fractionText => '$numerator/$denominator';
}

final class CommonDenominatorResult {
  const CommonDenominatorResult({
    required this.denominator,
    required this.method,
    required this.leftStep,
    required this.rightStep,
  });

  final int denominator;
  final CommonDenominatorMethod method;
  final EquivalentFractionStep leftStep;
  final EquivalentFractionStep rightStep;
}

final class CancellationStep {
  const CancellationStep({
    required this.leftNumerator,
    required this.leftDenominator,
    required this.rightNumerator,
    required this.rightDenominator,
    required this.explanation,
  });

  final int leftNumerator;
  final int leftDenominator;
  final int rightNumerator;
  final int rightDenominator;
  final String explanation;
}

final class ReductionResult {
  const ReductionResult({
    required this.originalNumerator,
    required this.originalDenominator,
    required this.commonFactor,
    required this.reduced,
  });

  final int originalNumerator;
  final int originalDenominator;
  final int commonFactor;
  final ExactFraction reduced;

  bool get wasAlreadyReduced => commonFactor == 1;
}

final class ToleranceRange {
  const ToleranceRange({
    required this.minimum,
    required this.nominal,
    required this.maximum,
  });

  final ExactFraction minimum;
  final ExactFraction nominal;
  final ExactFraction maximum;
}

final class FractionException implements Exception {
  const FractionException(this.message);

  final String message;

  @override
  String toString() => message;
}
