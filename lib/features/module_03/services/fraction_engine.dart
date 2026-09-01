import '../../module_02/services/whole_numbers_engine.dart';
import '../models/fraction_models.dart';

final class FractionEngine {
  const FractionEngine([this._wholeNumbers = const WholeNumbersEngine()]);

  final WholeNumbersEngine _wholeNumbers;

  ExactFraction create(int numerator, int denominator) =>
      ExactFraction(numerator, denominator);

  ExactFraction simplify(int numerator, int denominator) =>
      ExactFraction(numerator, denominator);

  EquivalentFractionStep equivalent(
    ExactFraction fraction,
    int targetDenominator,
  ) {
    if (targetDenominator <= 0 ||
        targetDenominator % fraction.denominator != 0) {
      throw const FractionException(
        'The target denominator must be a positive multiple of the denominator.',
      );
    }
    final multiplier = targetDenominator ~/ fraction.denominator;
    return EquivalentFractionStep(
      original: fraction,
      multiplier: multiplier,
      numerator: fraction.numerator * multiplier,
      denominator: targetDenominator,
    );
  }

  CommonDenominatorResult commonDenominator(
    ExactFraction left,
    ExactFraction right, {
    CommonDenominatorMethod method =
        CommonDenominatorMethod.leastCommonMultiple,
  }) {
    final denominator = switch (method) {
      CommonDenominatorMethod.leastCommonMultiple =>
        _wholeNumbers.leastCommonMultiple(left.denominator, right.denominator),
      CommonDenominatorMethod.productOfDenominators =>
        left.denominator * right.denominator,
    };
    return CommonDenominatorResult(
      denominator: denominator,
      method: method,
      leftStep: equivalent(left, denominator),
      rightStep: equivalent(right, denominator),
    );
  }

  ExactFraction add(Iterable<ExactFraction> fractions) {
    final values = fractions.toList(growable: false);
    if (values.isEmpty) {
      throw const FractionException('Enter at least one fraction to add.');
    }
    return values.fold(ExactFraction.zero, (sum, value) => sum + value);
  }

  ExactFraction subtract(ExactFraction left, ExactFraction right) =>
      left - right;

  ExactFraction multiply(Iterable<ExactFraction> fractions) {
    final values = fractions.toList(growable: false);
    if (values.isEmpty) {
      throw const FractionException('Enter at least one fraction to multiply.');
    }
    return values.fold(ExactFraction.one, (product, value) => product * value);
  }

  ExactFraction divide(ExactFraction dividend, ExactFraction divisor) =>
      dividend / divisor;

  int compare(ExactFraction left, ExactFraction right) => left.compareTo(right);

  ReductionResult reduction(int numerator, int denominator) {
    if (denominator == 0) {
      throw const FractionException('A fraction denominator cannot be zero.');
    }
    final commonFactor = numerator == 0
        ? denominator.abs()
        : _wholeNumbers.greatestCommonDivisor(
            numerator.abs(),
            denominator.abs(),
          );
    return ReductionResult(
      originalNumerator: numerator,
      originalDenominator: denominator,
      commonFactor: commonFactor,
      reduced: ExactFraction(numerator, denominator),
    );
  }

  List<CancellationStep> cancellationSteps(
    ExactFraction left,
    ExactFraction right,
  ) {
    var leftNumerator = left.numerator;
    var leftDenominator = left.denominator;
    var rightNumerator = right.numerator;
    var rightDenominator = right.denominator;
    final steps = <CancellationStep>[];

    final firstFactor = _crossFactor(leftNumerator, rightDenominator);
    if (firstFactor > 1) {
      leftNumerator ~/= firstFactor;
      rightDenominator ~/= firstFactor;
      steps.add(
        CancellationStep(
          leftNumerator: leftNumerator,
          leftDenominator: leftDenominator,
          rightNumerator: rightNumerator,
          rightDenominator: rightDenominator,
          explanation:
              'Cancel the left numerator and right denominator by $firstFactor.',
        ),
      );
    }

    final secondFactor = _crossFactor(rightNumerator, leftDenominator);
    if (secondFactor > 1) {
      rightNumerator ~/= secondFactor;
      leftDenominator ~/= secondFactor;
      steps.add(
        CancellationStep(
          leftNumerator: leftNumerator,
          leftDenominator: leftDenominator,
          rightNumerator: rightNumerator,
          rightDenominator: rightDenominator,
          explanation:
              'Cancel the right numerator and left denominator by $secondFactor.',
        ),
      );
    }
    return List.unmodifiable(steps);
  }

  ToleranceRange toleranceRange(
    ExactFraction nominal,
    ExactFraction tolerance,
  ) => ToleranceRange(
    minimum: nominal - tolerance,
    nominal: nominal,
    maximum: nominal + tolerance,
  );

  int _crossFactor(int left, int right) {
    if (left == 0) {
      return right.abs();
    }
    return _wholeNumbers.greatestCommonDivisor(left.abs(), right.abs());
  }
}
