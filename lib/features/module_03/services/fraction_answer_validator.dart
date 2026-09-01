import '../models/fraction_models.dart';
import '../models/module_03_content.dart';

enum FractionValidationStatus {
  correct,
  incorrect,
  invalid,
  needsReduction,
  missingUnit,
}

final class FractionValidation {
  const FractionValidation({
    required this.status,
    required this.message,
    required this.explanation,
  });

  final FractionValidationStatus status;
  final String message;
  final String explanation;

  bool get isCorrect => status == FractionValidationStatus.correct;
  bool get recordsAttempt => status != FractionValidationStatus.invalid;
}

final class ParsedFraction {
  const ParsedFraction({required this.value, required this.wasReduced});

  final ExactFraction value;
  final bool wasReduced;
}

final class FractionAnswerValidator {
  const FractionAnswerValidator();

  FractionValidation validate({
    required String response,
    required String unit,
    required Module3PracticeProblem problem,
  }) {
    final parsed = tryParse(response);
    if (parsed == null) {
      return FractionValidation(
        status: FractionValidationStatus.invalid,
        message:
            'Enter a fraction such as 3/8 or a mixed number such as 1 2/5.',
        explanation: problem.explanation,
      );
    }
    if (parsed.value != problem.expected) {
      return FractionValidation(
        status: FractionValidationStatus.incorrect,
        message: 'Not yet. Review the exact fraction steps, then retry.',
        explanation: problem.explanation,
      );
    }
    if (!parsed.wasReduced) {
      return FractionValidation(
        status: FractionValidationStatus.needsReduction,
        message:
            'The value is correct, but reduce the fraction to lowest terms.',
        explanation: problem.explanation,
      );
    }
    final expectedUnit = problem.expectedUnit;
    if (expectedUnit != null && _normalizeUnit(unit) != expectedUnit) {
      return FractionValidation(
        status: FractionValidationStatus.missingUnit,
        message:
            'The number is correct. Include the required unit: $expectedUnit.',
        explanation: problem.explanation,
      );
    }
    return FractionValidation(
      status: FractionValidationStatus.correct,
      message: 'Correct. The exact answer is reduced and complete.',
      explanation: problem.explanation,
    );
  }

  ParsedFraction? tryParse(String input) {
    final value = input.trim().replaceAll('−', '-');
    if (value.isEmpty) {
      return null;
    }
    final mixed = RegExp(r'^([+-]?\d+)\s+(\d+)\s*/\s*(\d+)$').firstMatch(value);
    if (mixed != null) {
      final whole = int.parse(mixed.group(1)!);
      final numerator = int.parse(mixed.group(2)!);
      final denominator = int.parse(mixed.group(3)!);
      if (denominator == 0 || numerator >= denominator) {
        return null;
      }
      final signedNumerator = whole < 0
          ? whole * denominator - numerator
          : whole * denominator + numerator;
      return ParsedFraction(
        value: ExactFraction(signedNumerator, denominator),
        wasReduced: _gcd(numerator, denominator) == 1,
      );
    }
    final fraction = RegExp(r'^([+-]?\d+)\s*/\s*([+-]?\d+)$').firstMatch(value);
    if (fraction != null) {
      final numerator = int.parse(fraction.group(1)!);
      final denominator = int.parse(fraction.group(2)!);
      if (denominator == 0) {
        return null;
      }
      return ParsedFraction(
        value: ExactFraction(numerator, denominator),
        wasReduced: numerator == 0
            ? denominator.abs() == 1
            : _gcd(numerator.abs(), denominator.abs()) == 1,
      );
    }
    final integer = int.tryParse(value);
    return integer == null
        ? null
        : ParsedFraction(value: ExactFraction(integer, 1), wasReduced: true);
  }

  static String _normalizeUnit(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('.', '');
    return switch (normalized) {
      'inch' || 'inches' => 'in',
      _ => normalized,
    };
  }

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
