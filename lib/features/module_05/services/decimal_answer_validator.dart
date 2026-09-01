import '../../module_03/services/fraction_answer_validator.dart';
import '../models/decimal_models.dart';
import '../models/module_05_content.dart';

enum DecimalValidationStatus {
  correct,
  incorrect,
  invalid,
  wrongPrecision,
  needsReduction,
  missingUnit,
  repeatingNotation,
}

final class DecimalValidation {
  const DecimalValidation({
    required this.status,
    required this.message,
    required this.explanation,
  });

  final DecimalValidationStatus status;
  final String message;
  final String explanation;

  bool get isCorrect => status == DecimalValidationStatus.correct;
  bool get recordsAttempt => status != DecimalValidationStatus.invalid;
}

final class DecimalAnswerValidator {
  const DecimalAnswerValidator([
    this._fractions = const FractionAnswerValidator(),
  ]);

  final FractionAnswerValidator _fractions;

  DecimalValidation validate({
    required String response,
    required String unit,
    required Module5PracticeProblem problem,
  }) {
    final valueResult = switch (problem.kind) {
      DecimalAnswerKind.decimal => _validateDecimal(response, problem),
      DecimalAnswerKind.fraction => _validateFraction(response, problem),
      DecimalAnswerKind.repeating => _validateRepeating(response, problem),
    };
    if (valueResult != null) {
      return valueResult;
    }
    final expectedUnit = problem.expectedUnit;
    if (expectedUnit != null &&
        _normalizeUnit(unit) != _normalizeUnit(expectedUnit)) {
      return DecimalValidation(
        status: DecimalValidationStatus.missingUnit,
        message:
            'The value is correct. Include the required unit: $expectedUnit.',
        explanation: problem.explanation,
      );
    }
    return DecimalValidation(
      status: DecimalValidationStatus.correct,
      message: 'Correct. The exact value and requested precision are complete.',
      explanation: problem.explanation,
    );
  }

  DecimalValidation? _validateDecimal(
    String response,
    Module5PracticeProblem problem,
  ) {
    DecimalQuantity parsed;
    try {
      parsed = DecimalQuantity.parse(response);
    } on Object {
      return DecimalValidation(
        status: DecimalValidationStatus.invalid,
        message: 'Enter a valid non-negative decimal number.',
        explanation: problem.explanation,
      );
    }
    if (parsed != problem.expectedDecimal) {
      return DecimalValidation(
        status: DecimalValidationStatus.incorrect,
        message: 'Not yet. Keep the decimal places aligned and retry.',
        explanation: problem.explanation,
      );
    }
    final requiredPlaces = problem.requiredDecimalPlaces;
    if (requiredPlaces != null &&
        _writtenDecimalPlaces(response) != requiredPlaces) {
      return DecimalValidation(
        status: DecimalValidationStatus.wrongPrecision,
        message:
            'The value is equivalent, but show exactly $requiredPlaces decimal place${requiredPlaces == 1 ? '' : 's'}.',
        explanation: problem.explanation,
      );
    }
    return null;
  }

  DecimalValidation? _validateFraction(
    String response,
    Module5PracticeProblem problem,
  ) {
    final parsed = _fractions.tryParse(response);
    if (parsed == null) {
      return DecimalValidation(
        status: DecimalValidationStatus.invalid,
        message: 'Enter a fraction such as 5/16.',
        explanation: problem.explanation,
      );
    }
    final value = BigDecimalFraction(
      BigInt.from(parsed.value.numerator),
      BigInt.from(parsed.value.denominator),
    );
    if (value != problem.expectedFraction) {
      return DecimalValidation(
        status: DecimalValidationStatus.incorrect,
        message: 'Not yet. Follow the conversion steps and retry.',
        explanation: problem.explanation,
      );
    }
    if (!parsed.wasReduced) {
      return DecimalValidation(
        status: DecimalValidationStatus.needsReduction,
        message:
            'The value is correct, but reduce the fraction to lowest terms.',
        explanation: problem.explanation,
      );
    }
    return null;
  }

  DecimalValidation? _validateRepeating(
    String response,
    Module5PracticeProblem problem,
  ) {
    final normalized = response.replaceAll(' ', '');
    if (normalized == problem.expectedRepeating) {
      return null;
    }
    if (normalized == '0.3' || normalized == '0.333') {
      return DecimalValidation(
        status: DecimalValidationStatus.repeatingNotation,
        message: 'Mark the repeating digit explicitly as 0.(3).',
        explanation: problem.explanation,
      );
    }
    if (normalized.isEmpty) {
      return DecimalValidation(
        status: DecimalValidationStatus.invalid,
        message: 'Enter repeating notation such as 0.(3).',
        explanation: problem.explanation,
      );
    }
    return DecimalValidation(
      status: DecimalValidationStatus.incorrect,
      message: 'Not yet. Parentheses must contain exactly the repeating cycle.',
      explanation: problem.explanation,
    );
  }

  static int _writtenDecimalPlaces(String value) {
    final normalized = value.trim().replaceAll(',', '');
    final point = normalized.indexOf('.');
    return point < 0 ? 0 : normalized.length - point - 1;
  }

  static String _normalizeUnit(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('.', '');
    return switch (normalized) {
      'inch' || 'inches' => 'in',
      'foot' || 'feet' => 'ft',
      'ohm' || 'ohms' || 'ω' => 'ohm',
      'watt' || 'watts' => 'w',
      _ => normalized,
    };
  }
}
