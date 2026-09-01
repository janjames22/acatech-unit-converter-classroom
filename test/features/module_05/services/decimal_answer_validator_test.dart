import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_05/module_05.dart';

void main() {
  const validator = DecimalAnswerValidator();

  test('accepts exact decimals and normalized aviation units', () {
    expect(
      validator
          .validate(
            response: '39.930',
            unit: 'ohms',
            problem: Module5Curriculum.practiceProblems[2],
          )
          .isCorrect,
      isTrue,
    );
    expect(
      validator
          .validate(
            response: '1,134',
            unit: 'watts',
            problem: Module5Curriculum.practiceProblems[4],
          )
          .isCorrect,
      isTrue,
    );
  });

  test('distinguishes invalid, incorrect, and missing-unit responses', () {
    final problem = Module5Curriculum.practiceProblems[1];
    expect(
      validator.validate(response: '', unit: '', problem: problem).status,
      DecimalValidationStatus.invalid,
    );
    expect(
      validator
          .validate(response: '0.736', unit: 'in', problem: problem)
          .status,
      DecimalValidationStatus.incorrect,
    );
    expect(
      validator.validate(response: '0.763', unit: '', problem: problem).status,
      DecimalValidationStatus.missingUnit,
    );
  });

  test('requires the requested written rounding precision', () {
    final problem = Module5Curriculum.practiceProblems[7];
    expect(
      validator.validate(response: '3.160', unit: '', problem: problem).status,
      DecimalValidationStatus.wrongPrecision,
    );
    expect(
      validator
          .validate(response: '3.16', unit: '', problem: problem)
          .isCorrect,
      isTrue,
    );
  });

  test('requires a reduced shop fraction', () {
    final problem = Module5Curriculum.practiceProblems[9];
    expect(
      validator
          .validate(response: '20/64', unit: 'in', problem: problem)
          .status,
      DecimalValidationStatus.needsReduction,
    );
    expect(
      validator
          .validate(response: '5/16', unit: 'inch', problem: problem)
          .isCorrect,
      isTrue,
    );
  });

  test('requires explicit repeating-cycle notation', () {
    final problem = Module5Curriculum.practiceProblems[12];
    expect(
      validator.validate(response: '0.333', unit: '', problem: problem).status,
      DecimalValidationStatus.repeatingNotation,
    );
    expect(
      validator
          .validate(response: '0.(3)', unit: '', problem: problem)
          .isCorrect,
      isTrue,
    );
  });
}
