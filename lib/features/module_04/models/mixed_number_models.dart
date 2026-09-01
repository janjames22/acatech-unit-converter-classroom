import '../../module_03/models/fraction_models.dart';

final class MixedNumber {
  factory MixedNumber(int whole, int numerator, int denominator) {
    if (whole < 0 || numerator < 0) {
      throw const MixedNumberException(
        'Negative mixed numbers are introduced in Module 9.',
      );
    }
    final fraction = ExactFraction(numerator, denominator);
    if (fraction.numerator < 0) {
      throw const MixedNumberException(
        'Negative mixed numbers are introduced in Module 9.',
      );
    }
    final total = ExactFraction(
      whole * fraction.denominator + fraction.numerator,
      fraction.denominator,
    );
    return MixedNumber.fromImproper(total);
  }

  factory MixedNumber.fromImproper(ExactFraction value) {
    if (value.numerator < 0) {
      throw const MixedNumberException(
        'Negative mixed numbers are introduced in Module 9.',
      );
    }
    final whole = value.numerator ~/ value.denominator;
    final remainder = value.numerator % value.denominator;
    if (remainder == 0) {
      return MixedNumber._(whole, 0, 1);
    }
    final fraction = ExactFraction(remainder, value.denominator);
    return MixedNumber._(whole, fraction.numerator, fraction.denominator);
  }

  const MixedNumber._(this.whole, this.numerator, this.denominator);

  final int whole;
  final int numerator;
  final int denominator;

  bool get hasFraction => numerator != 0;
  bool get isProperFraction => whole == 0 && numerator < denominator;

  ExactFraction get fractionPart => ExactFraction(numerator, denominator);

  ExactFraction get improperFraction =>
      ExactFraction(whole * denominator + numerator, denominator);

  String get text {
    if (!hasFraction) {
      return '$whole';
    }
    if (whole == 0) {
      return '$numerator/$denominator';
    }
    return '$whole $numerator/$denominator';
  }

  @override
  bool operator ==(Object other) =>
      other is MixedNumber && improperFraction == other.improperFraction;

  @override
  int get hashCode => improperFraction.hashCode;

  @override
  String toString() => text;
}

final class MixedConversionStep {
  const MixedConversionStep({
    required this.input,
    required this.expression,
    required this.result,
    required this.explanation,
  });

  final String input;
  final String expression;
  final String result;
  final String explanation;
}

final class BorrowStep {
  const BorrowStep({
    required this.originalWhole,
    required this.originalNumerator,
    required this.denominator,
    required this.borrowedWhole,
    required this.borrowedNumerator,
    required this.explanation,
  });

  final int originalWhole;
  final int originalNumerator;
  final int denominator;
  final int borrowedWhole;
  final int borrowedNumerator;
  final String explanation;
}

final class CarryStep {
  const CarryStep({
    required this.improperNumerator,
    required this.denominator,
    required this.carriedWhole,
    required this.remainderNumerator,
    required this.explanation,
  });

  final int improperNumerator;
  final int denominator;
  final int carriedWhole;
  final int remainderNumerator;
  final String explanation;
}

final class MixedOperationResult {
  const MixedOperationResult({
    required this.leftImproper,
    required this.rightImproper,
    required this.exactResult,
    required this.value,
    this.borrowStep,
    this.carryStep,
  });

  final ExactFraction leftImproper;
  final ExactFraction rightImproper;
  final ExactFraction exactResult;
  final MixedNumber value;
  final BorrowStep? borrowStep;
  final CarryStep? carryStep;
}

final class CutPlan {
  const CutPlan({required this.pieceCount, required this.remainder});

  final int pieceCount;
  final MixedNumber remainder;
}

final class DistracterSelection {
  const DistracterSelection({
    required this.selectedIds,
    required this.requiredIds,
  });

  final Set<String> selectedIds;
  final Set<String> requiredIds;

  bool get isCorrect =>
      selectedIds.length == requiredIds.length &&
      selectedIds.containsAll(requiredIds);
}

final class MixedNumberException implements Exception {
  const MixedNumberException(this.message);

  final String message;

  @override
  String toString() => message;
}
