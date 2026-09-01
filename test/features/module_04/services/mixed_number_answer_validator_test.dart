import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/module_04/module_04.dart';

void main() {
  const validator = MixedNumberAnswerValidator();

  test('accepts the required improper and reduced mixed forms', () {
    expect(
      validator
          .validate(
            response: '87/16',
            unit: '',
            selectedGivenIds: const {},
            problem: Module4Curriculum.practiceProblems[0],
          )
          .isCorrect,
      isTrue,
    );
    expect(
      validator
          .validate(
            response: '2 23/32',
            unit: '',
            selectedGivenIds: const {},
            problem: Module4Curriculum.practiceProblems[1],
          )
          .isCorrect,
      isTrue,
    );
  });

  test('distinguishes invalid, incorrect, and unreduced responses', () {
    final problem = Module4Curriculum.practiceProblems.first;
    expect(
      validator
          .validate(
            response: '',
            unit: '',
            selectedGivenIds: const {},
            problem: problem,
          )
          .status,
      MixedNumberValidationStatus.invalid,
    );
    expect(
      validator
          .validate(
            response: '86/16',
            unit: '',
            selectedGivenIds: const {},
            problem: problem,
          )
          .status,
      MixedNumberValidationStatus.incorrect,
    );
    expect(
      validator
          .validate(
            response: '174/32',
            unit: '',
            selectedGivenIds: const {},
            problem: problem,
          )
          .status,
      MixedNumberValidationStatus.needsReduction,
    );
  });

  test('requires mixed form when the curriculum asks for it', () {
    final problem = Module4Curriculum.practiceProblems[1];
    expect(
      validator
          .validate(
            response: '87/32',
            unit: '',
            selectedGivenIds: const {},
            problem: problem,
          )
          .status,
      MixedNumberValidationStatus.needsMixedForm,
    );
  });

  test(
    'checks bolt givens independently and rejects overall-length distracter',
    () {
      final problem = Module4Curriculum.practiceProblems[3];
      expect(
        validator
            .validate(
              response: '1 13/16',
              unit: 'in',
              selectedGivenIds: const {'shank', 'threaded', 'overall'},
              problem: problem,
            )
            .status,
        MixedNumberValidationStatus.wrongGivens,
      );
      expect(
        validator
            .validate(
              response: '1 13/16',
              unit: 'inches',
              selectedGivenIds: const {'shank', 'threaded'},
              problem: problem,
            )
            .isCorrect,
        isTrue,
      );
    },
  );

  test('checks aviation units separately from exact arithmetic', () {
    final problem = Module4Curriculum.practiceProblems[5];
    expect(
      validator
          .validate(
            response: '16 1/2',
            unit: '',
            selectedGivenIds: const {},
            problem: problem,
          )
          .status,
      MixedNumberValidationStatus.missingUnit,
    );
    expect(
      validator
          .validate(
            response: '16 1/2',
            unit: 'inch',
            selectedGivenIds: const {},
            problem: problem,
          )
          .isCorrect,
      isTrue,
    );
  });
}
