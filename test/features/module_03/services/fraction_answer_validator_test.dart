import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_03/module_03.dart';

void main() {
  const validator = FractionAnswerValidator();

  test('accepts reduced improper and mixed-number equivalents', () {
    final problem = Module3Curriculum.practiceProblems[1];
    expect(
      validator
          .validate(response: '193/105', unit: '', problem: problem)
          .isCorrect,
      isTrue,
    );
    expect(
      validator
          .validate(response: '1 88/105', unit: '', problem: problem)
          .isCorrect,
      isTrue,
    );
  });

  test('distinguishes incorrect, unreduced, and invalid answers', () {
    final problem = Module3Curriculum.practiceProblems.first;
    expect(
      validator.validate(response: '', unit: '', problem: problem).status,
      FractionValidationStatus.invalid,
    );
    expect(
      validator.validate(response: '1/2', unit: '', problem: problem).status,
      FractionValidationStatus.incorrect,
    );
    expect(
      validator.validate(response: '6/20', unit: '', problem: problem).status,
      FractionValidationStatus.needsReduction,
    );
  });

  test('scores the required unit separately from arithmetic', () {
    final problem = Module3Curriculum.practiceProblems[2];
    expect(
      validator.validate(response: '7/64', unit: '', problem: problem).status,
      FractionValidationStatus.missingUnit,
    );
    expect(
      validator
          .validate(response: '7/64', unit: 'inches', problem: problem)
          .status,
      FractionValidationStatus.correct,
    );
  });

  test('parses normalized negative signs and rejects zero denominators', () {
    expect(validator.tryParse('1/-2')?.value, ExactFraction(-1, 2));
    expect(validator.tryParse('−1/2')?.value, ExactFraction(-1, 2));
    expect(validator.tryParse('3/0'), isNull);
    expect(validator.tryParse('1 5/4'), isNull);
  });
}
