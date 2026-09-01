import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_02/module_02.dart';

void main() {
  const validator = WholeNumberAnswerValidator();

  test('accepts formatting variants and factor notation', () {
    final sum = Module2Curriculum.practiceProblems[0];
    expect(validator.validate('97,578', sum).isCorrect, isTrue);
    expect(validator.validate(' 97578 ', sum).isCorrect, isTrue);

    final factorization = Module2Curriculum.practiceProblems[4];
    expect(validator.validate('2² × 3 × 5', factorization).isCorrect, isTrue);
    expect(validator.validate('2^2 * 3 * 5', factorization).isCorrect, isTrue);
  });

  test('distinguishes invalid, incorrect, and correct answers', () {
    final problem = Module2Curriculum.practiceProblems[3];
    expect(
      validator.validate('', problem).status,
      AnswerValidationStatus.invalid,
    );
    final incorrect = validator.validate('31', problem);
    expect(incorrect.status, AnswerValidationStatus.incorrect);
    expect(incorrect.explanation, contains('remainder is 1'));
    expect(
      validator.validate('31 remainder 1', problem).status,
      AnswerValidationStatus.correct,
    );
  });
}
