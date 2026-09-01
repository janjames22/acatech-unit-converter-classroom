import '../models/module_02_content.dart';

enum AnswerValidationStatus { correct, incorrect, invalid }

final class AnswerValidation {
  const AnswerValidation({
    required this.status,
    required this.message,
    required this.explanation,
  });

  final AnswerValidationStatus status;
  final String message;
  final String explanation;

  bool get isCorrect => status == AnswerValidationStatus.correct;
}

final class WholeNumberAnswerValidator {
  const WholeNumberAnswerValidator();

  AnswerValidation validate(String response, Module2PracticeProblem problem) {
    final normalized = _normalize(response);
    if (normalized.isEmpty) {
      return AnswerValidation(
        status: AnswerValidationStatus.invalid,
        message: 'Enter an answer before checking.',
        explanation: problem.explanation,
      );
    }
    final accepted = problem.acceptedAnswers.map(_normalize);
    if (accepted.contains(normalized)) {
      return AnswerValidation(
        status: AnswerValidationStatus.correct,
        message: 'Correct. Your working matches the whole-number result.',
        explanation: problem.explanation,
      );
    }
    return AnswerValidation(
      status: AnswerValidationStatus.incorrect,
      message: 'Not yet. Review the explanation, then retry.',
      explanation: problem.explanation,
    );
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('²', '^2')
      .replaceAll('×', 'x')
      .replaceAll('*', 'x')
      .replaceAll('remainder', 'r')
      .replaceAll(RegExp(r'[,\s]+'), '')
      .replaceAll(RegExp(r'[^a-z0-9^x+-]'), '');
}
