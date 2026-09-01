import '../../module_03/services/fraction_answer_validator.dart';
import '../models/module_04_content.dart';
import 'mixed_number_engine.dart';

enum MixedNumberValidationStatus {
  correct,
  incorrect,
  invalid,
  needsReduction,
  needsMixedForm,
  missingUnit,
  wrongGivens,
}

final class MixedNumberValidation {
  const MixedNumberValidation({
    required this.status,
    required this.message,
    required this.explanation,
  });

  final MixedNumberValidationStatus status;
  final String message;
  final String explanation;

  bool get isCorrect => status == MixedNumberValidationStatus.correct;
  bool get recordsAttempt => status != MixedNumberValidationStatus.invalid;
}

final class MixedNumberAnswerValidator {
  const MixedNumberAnswerValidator([
    this._fractions = const FractionAnswerValidator(),
    this._engine = const MixedNumberEngine(),
  ]);

  final FractionAnswerValidator _fractions;
  final MixedNumberEngine _engine;

  MixedNumberValidation validate({
    required String response,
    required String unit,
    required Set<String> selectedGivenIds,
    required Module4PracticeProblem problem,
  }) {
    final parsed = _fractions.tryParse(response);
    if (parsed == null) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.invalid,
        message:
            'Enter an improper fraction, whole number, or mixed number such as 1 13/16.',
        explanation: problem.explanation,
      );
    }
    if (problem.requiredGivenIds.isNotEmpty &&
        !_engine
            .validateGivens(
              selectedIds: selectedGivenIds,
              requiredIds: problem.requiredGivenIds,
            )
            .isCorrect) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.wrongGivens,
        message: 'Select only the values used by the stated formula.',
        explanation: problem.explanation,
      );
    }
    if (parsed.value != problem.expected) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.incorrect,
        message: 'Not yet. Convert the complete mixed numbers, then retry.',
        explanation: problem.explanation,
      );
    }
    if (!parsed.wasReduced) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.needsReduction,
        message: 'The value is correct, but reduce the fractional part.',
        explanation: problem.explanation,
      );
    }
    if (problem.requireMixedForm &&
        problem.expected.denominator != 1 &&
        !_isMixedForm(response)) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.needsMixedForm,
        message:
            'The value is correct. Express the improper result in mixed form.',
        explanation: problem.explanation,
      );
    }
    final expectedUnit = problem.expectedUnit;
    if (expectedUnit != null && _normalizeUnit(unit) != expectedUnit) {
      return MixedNumberValidation(
        status: MixedNumberValidationStatus.missingUnit,
        message:
            'The number is correct. Include the required unit: $expectedUnit.',
        explanation: problem.explanation,
      );
    }
    return MixedNumberValidation(
      status: MixedNumberValidationStatus.correct,
      message: 'Correct. The mixed-number answer is reduced and complete.',
      explanation: problem.explanation,
    );
  }

  static bool _isMixedForm(String value) =>
      RegExp(r'^\s*\d+\s+\d+\s*/\s*\d+\s*$').hasMatch(value);

  static String _normalizeUnit(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('.', '');
    return switch (normalized) {
      'inch' || 'inches' => 'in',
      'foot' || 'feet' => 'ft',
      'piece' => 'pieces',
      _ => normalized,
    };
  }
}
