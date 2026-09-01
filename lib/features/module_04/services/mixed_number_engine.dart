import '../../module_03/models/fraction_models.dart';
import '../../module_03/services/fraction_engine.dart';
import '../models/mixed_number_models.dart';

final class MixedNumberEngine {
  const MixedNumberEngine([this._fractions = const FractionEngine()]);

  final FractionEngine _fractions;

  MixedNumber create(int whole, int numerator, int denominator) =>
      MixedNumber(whole, numerator, denominator);

  MixedConversionStep toImproper(MixedNumber value) {
    final result = value.improperFraction;
    return MixedConversionStep(
      input: value.text,
      expression:
          '${value.whole} × ${value.denominator} + ${value.numerator} = ${result.numerator}',
      result: result.fractionText,
      explanation:
          'Multiply the whole by the denominator, add the numerator, and keep the denominator.',
    );
  }

  MixedConversionStep fromImproper(ExactFraction value) {
    if (value.numerator < 0) {
      throw const MixedNumberException(
        'Negative mixed numbers are introduced in Module 9.',
      );
    }
    final mixed = MixedNumber.fromImproper(value);
    final remainder = value.numerator % value.denominator;
    return MixedConversionStep(
      input: value.fractionText,
      expression:
          '${value.numerator} = ${mixed.whole} × ${value.denominator} + $remainder',
      result: mixed.text,
      explanation:
          'The quotient is the whole and the remainder is the fractional numerator.',
    );
  }

  MixedOperationResult add(MixedNumber left, MixedNumber right) {
    final common = _fractions.commonDenominator(
      left.fractionPart,
      right.fractionPart,
    );
    final combinedNumerator =
        common.leftStep.numerator + common.rightStep.numerator;
    final carriedWhole = combinedNumerator ~/ common.denominator;
    final carry = carriedWhole > 0
        ? CarryStep(
            improperNumerator: combinedNumerator,
            denominator: common.denominator,
            carriedWhole: carriedWhole,
            remainderNumerator: combinedNumerator % common.denominator,
            explanation:
                '$combinedNumerator/${common.denominator} contains $carriedWhole whole; carry it to the whole-number sum.',
          )
        : null;
    final exact = _fractions.add([
      left.improperFraction,
      right.improperFraction,
    ]);
    return MixedOperationResult(
      leftImproper: left.improperFraction,
      rightImproper: right.improperFraction,
      exactResult: exact,
      value: MixedNumber.fromImproper(exact),
      carryStep: carry,
    );
  }

  MixedOperationResult subtract(MixedNumber left, MixedNumber right) {
    if (left.improperFraction.compareTo(right.improperFraction) < 0) {
      throw const MixedNumberException(
        'This result is negative and belongs to Module 9.',
      );
    }
    final common = _fractions.commonDenominator(
      left.fractionPart,
      right.fractionPart,
    );
    final needsBorrow =
        common.leftStep.numerator < common.rightStep.numerator &&
        left.whole > 0;
    final borrow = needsBorrow
        ? BorrowStep(
            originalWhole: left.whole,
            originalNumerator: common.leftStep.numerator,
            denominator: common.denominator,
            borrowedWhole: left.whole - 1,
            borrowedNumerator: common.leftStep.numerator + common.denominator,
            explanation:
                'Borrow one whole as ${common.denominator}/${common.denominator}.',
          )
        : null;
    final exact = _fractions.subtract(
      left.improperFraction,
      right.improperFraction,
    );
    return MixedOperationResult(
      leftImproper: left.improperFraction,
      rightImproper: right.improperFraction,
      exactResult: exact,
      value: MixedNumber.fromImproper(exact),
      borrowStep: borrow,
    );
  }

  MixedOperationResult multiply(MixedNumber left, MixedNumber right) {
    final exact = _fractions.multiply([
      left.improperFraction,
      right.improperFraction,
    ]);
    return MixedOperationResult(
      leftImproper: left.improperFraction,
      rightImproper: right.improperFraction,
      exactResult: exact,
      value: MixedNumber.fromImproper(exact),
    );
  }

  MixedOperationResult divide(MixedNumber left, MixedNumber right) {
    final exact = _fractions.divide(
      left.improperFraction,
      right.improperFraction,
    );
    return MixedOperationResult(
      leftImproper: left.improperFraction,
      rightImproper: right.improperFraction,
      exactResult: exact,
      value: MixedNumber.fromImproper(exact),
    );
  }

  MixedNumber totalForPieces(MixedNumber piece, int count) {
    if (count < 0) {
      throw const MixedNumberException('Piece count cannot be negative.');
    }
    final total = _fractions.multiply([
      piece.improperFraction,
      ExactFraction(count, 1),
    ]);
    return MixedNumber.fromImproper(total);
  }

  CutPlan cutPlan(MixedNumber total, MixedNumber piece) {
    if (piece.improperFraction.isZero) {
      throw const MixedNumberException(
        'Piece length must be greater than zero.',
      );
    }
    final quotient = _fractions.divide(
      total.improperFraction,
      piece.improperFraction,
    );
    final pieceCount = quotient.numerator ~/ quotient.denominator;
    final used = _fractions.multiply([
      piece.improperFraction,
      ExactFraction(pieceCount, 1),
    ]);
    final remainder = _fractions.subtract(total.improperFraction, used);
    return CutPlan(
      pieceCount: pieceCount,
      remainder: MixedNumber.fromImproper(remainder),
    );
  }

  DistracterSelection validateGivens({
    required Set<String> selectedIds,
    required Set<String> requiredIds,
  }) => DistracterSelection(
    selectedIds: Set.unmodifiable(selectedIds),
    requiredIds: Set.unmodifiable(requiredIds),
  );
}
