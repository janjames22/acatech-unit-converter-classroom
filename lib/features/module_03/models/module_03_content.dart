import 'fraction_models.dart';

final class Module3Lesson {
  const Module3Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.objectives,
    required this.explanations,
    required this.examples,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> objectives;
  final List<String> explanations;
  final List<Module3WorkedExample> examples;
}

final class Module3WorkedExample {
  const Module3WorkedExample({
    required this.title,
    required this.given,
    required this.formula,
    required this.substitution,
    required this.solution,
    required this.explanation,
    this.aviationContext = false,
    this.correctionNote,
  });

  final String title;
  final String given;
  final String formula;
  final String substitution;
  final String solution;
  final String explanation;
  final bool aviationContext;
  final String? correctionNote;
}

final class Module3PracticeProblem {
  const Module3PracticeProblem({
    required this.id,
    required this.prompt,
    required this.expected,
    required this.explanation,
    this.expectedUnit,
    this.acceptMixedNumber = true,
  });

  final String id;
  final String prompt;
  final ExactFraction expected;
  final String explanation;
  final String? expectedUnit;
  final bool acceptMixedNumber;
}

abstract final class Module3Curriculum {
  static const title = 'Module 3 — Fractions';
  static const introduction =
      'Fractions express exact parts of a whole. Aviation mathematics uses '
      'them for sheet-metal thickness, tolerances, shims, hole-center layout, '
      'and component travel. Exact fraction work prevents rounding error before '
      'a final measurement is selected.';

  static const objectives = <String>[
    'Identify numerators, denominators, proper fractions, and improper fractions.',
    'Create equivalent fractions and find a least common denominator by two curriculum methods.',
    'Add, subtract, multiply, and divide fractions exactly.',
    'Use cancellation when appropriate and reduce every final fraction to lowest terms.',
    'Compare fractions and express an improper result as a mixed number.',
    'Organize aviation calculations as Given, Formula, Substitute, and Solve with units.',
  ];

  static const lessons = <Module3Lesson>[
    Module3Lesson(
      id: 'm03_l01',
      title: 'Fraction anatomy and equivalent forms',
      summary:
          'Build valid fractions and recognize proper and improper values.',
      objectives: [
        'Name the numerator and denominator.',
        'Explain why a denominator can never be zero.',
        'Generate and compare equivalent fractions.',
      ],
      explanations: [
        'The numerator counts selected equal parts. The denominator states how many equal parts make one whole and therefore cannot be zero.',
        'Multiplying a numerator and denominator by the same nonzero whole number changes the appearance but not the value.',
        'A proper fraction has magnitude below one. An improper fraction has a numerator whose magnitude is at least its denominator.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Equivalent sheet thickness',
          given: 'Thickness = 1/2 inch',
          formula: 'Equivalent = (numerator × n)/(denominator × n)',
          substitution: '(1 × 2)/(2 × 2)',
          solution: '1/2 = 2/4 inch',
          explanation:
              'Both parts are multiplied by 2, so the value is unchanged.',
          aviationContext: true,
        ),
      ],
    ),
    Module3Lesson(
      id: 'm03_l02',
      title: 'Least common denominators',
      summary: 'Use the least-shared-multiple or denominator-product method.',
      objectives: [
        'Find the least common denominator using an LCM.',
        'Use the product of denominators as a valid common denominator.',
        'Convert every term to an equivalent fraction before addition or subtraction.',
      ],
      explanations: [
        'Fractions can be added or subtracted only after their parts have the same size. A common denominator establishes that shared part size.',
        'The least-shared-multiple method minimizes later reduction. Multiplying denominators always produces a common denominator, although it may not be the least one.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Corrected panel-thickness LCD',
          given: 'Skin 3/32 inch; coating 1/64 inch',
          formula: 'LCD = LCM(32, 64)',
          substitution: 'LCM(32, 64) = 64; 3/32 = 6/64',
          solution: 'LCD = 64',
          explanation:
              'The authoritative curriculum correction uses 64, not the handbook’s printed value of 1.',
          aviationContext: true,
          correctionNote: 'Curriculum correction: the LCD is 64.',
        ),
      ],
    ),
    Module3Lesson(
      id: 'm03_l03',
      title: 'Adding fractions',
      summary: 'Convert unlike denominators, combine numerators, and reduce.',
      objectives: [
        'Add fractions with like and unlike denominators.',
        'Retain the common denominator while adding numerators.',
        'Convert an improper sum to a mixed number when useful.',
      ],
      explanations: [
        'After equivalent fractions share one denominator, add only their numerators. Reduce the final result, not an intermediate decimal.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Add panel layers',
          given: '3/32 inch + 1/64 inch',
          formula: 'Total = equivalent first layer + second layer',
          substitution: '6/64 + 1/64',
          solution: '7/64 inch',
          explanation: 'The shared denominator 64 represents equal-size parts.',
          aviationContext: true,
          correctionNote: 'The LCD is 64.',
        ),
        Module3WorkedExample(
          title: 'Add three unlike fractions',
          given: '2/3 + 3/5 + 4/7',
          formula: 'LCD = LCM(3, 5, 7) = 105',
          substitution: '70/105 + 63/105 + 60/105',
          solution: '193/105 = 1 88/105',
          explanation:
              'The improper exact result can also be shown as a mixed number.',
        ),
      ],
    ),
    Module3Lesson(
      id: 'm03_l04',
      title: 'Subtraction, tolerances, and multiplication',
      summary:
          'Calculate exact ranges and use cancellation before multiplying.',
      objectives: [
        'Subtract fractions with unlike denominators.',
        'Calculate minimum and maximum tolerance values.',
        'Multiply numerators and denominators with optional cancellation.',
      ],
      explanations: [
        'For a nominal value plus or minus a tolerance, subtract the tolerance for the minimum and add it for the maximum.',
        'Before multiplying, a numerator and a denominator in different factors may be divided by the same common factor. This cancellation keeps values smaller without changing the result.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Aileron travel tolerance',
          given: 'Nominal 7/8 inch; tolerance ±1/5 inch',
          formula:
              'Minimum = nominal − tolerance; maximum = nominal + tolerance',
          substitution: '35/40 − 8/40; 35/40 + 8/40',
          solution: 'Minimum 27/40 inch; maximum 43/40 = 1 3/40 inch',
          explanation:
              'Keep the exact denominator through both range calculations.',
          aviationContext: true,
        ),
        Module3WorkedExample(
          title: 'Cancel before multiplying',
          given: '14/15 × 3/2',
          formula: 'Cancel common factors, then multiply',
          substitution: '(7/5) × (1/1)',
          solution: '7/5 = 1 2/5',
          explanation: 'Cancel 14 with 2 by 2, and 3 with 15 by 3.',
        ),
      ],
    ),
    Module3Lesson(
      id: 'm03_l05',
      title: 'Dividing fractions',
      summary: 'Invert the second fraction, multiply, and reduce.',
      objectives: [
        'Identify the dividend and divisor fractions.',
        'Replace division with multiplication by the reciprocal.',
        'Reject division by a zero fraction.',
      ],
      explanations: [
        'To divide by a nonzero fraction, keep the first fraction, invert the second, and multiply. A zero fraction has no reciprocal.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Fraction division',
          given: '7/8 ÷ 4/3',
          formula: 'a/b ÷ c/d = a/b × d/c',
          substitution: '7/8 × 3/4',
          solution: '21/32',
          explanation: 'The result is already in lowest terms.',
        ),
      ],
    ),
    Module3Lesson(
      id: 'm03_l06',
      title: 'Lowest terms and maintenance applications',
      summary: 'Inspect common factors and report usable exact answers.',
      objectives: [
        'Reduce numerator and denominator by their greatest common divisor.',
        'Recognize an already-reduced result.',
        'Use improper and mixed forms in layout and travel examples.',
      ],
      explanations: [
        'A fraction is in lowest terms when numerator and denominator share no positive factor except 1.',
        'Exact fractions should remain exact through the solution. Convert to decimal only when a final presentation or approved measurement process requires it.',
      ],
      examples: [
        Module3WorkedExample(
          title: 'Hole-center layout',
          given: 'Layout distances 87/32 inch and 29/16 inch',
          formula:
              'whole = numerator ÷ denominator; remainder forms fractional part',
          substitution: '87 = 2 × 32 + 23; 29 = 1 × 16 + 13',
          solution: '2 23/32 inch and 1 13/16 inch',
          explanation: 'Both fractional remainders are already reduced.',
          aviationContext: true,
        ),
        Module3WorkedExample(
          title: 'Jackscrew travel',
          given: '13/16 inch − 7/16 inch',
          formula: 'Travel = final position − initial position',
          substitution: '6/16 inch',
          solution: '3/8 inch',
          explanation:
              'Divide numerator and denominator by the common factor 2.',
          aviationContext: true,
        ),
      ],
    ),
  ];

  static final practiceProblems = <Module3PracticeProblem>[
    Module3PracticeProblem(
      id: 'm03_q01',
      prompt: 'Add and reduce: 1/5 + 1/10.',
      expected: ExactFraction(3, 10),
      explanation: 'LCD 10: 2/10 + 1/10 = 3/10.',
    ),
    Module3PracticeProblem(
      id: 'm03_q02',
      prompt: 'Add: 2/3 + 3/5 + 4/7. Give an improper or mixed result.',
      expected: ExactFraction(193, 105),
      explanation: 'LCD 105: 70/105 + 63/105 + 60/105 = 193/105 = 1 88/105.',
    ),
    Module3PracticeProblem(
      id: 'm03_q03',
      prompt:
          'A panel has layers 3/32 inch and 1/64 inch. Find the total thickness.',
      expected: ExactFraction(7, 64),
      expectedUnit: 'in',
      explanation: 'Corrected LCD 64: 3/32 = 6/64, so the total is 7/64 inch.',
    ),
    Module3PracticeProblem(
      id: 'm03_q04',
      prompt: 'Find the minimum for 7/8 inch with a tolerance of ±1/5 inch.',
      expected: ExactFraction(27, 40),
      expectedUnit: 'in',
      explanation: '7/8 − 1/5 = 35/40 − 8/40 = 27/40 inch.',
    ),
    Module3PracticeProblem(
      id: 'm03_q05',
      prompt: 'Multiply and reduce: 3/5 × 7/8 × 1/2.',
      expected: ExactFraction(21, 80),
      explanation:
          'Multiply numerators and denominators: 21/80, already reduced.',
    ),
    Module3PracticeProblem(
      id: 'm03_q06',
      prompt: 'Use cancellation and multiply: 14/15 × 3/2.',
      expected: ExactFraction(7, 5),
      explanation: 'Cancel 14 with 2 and 3 with 15 to obtain 7/5 = 1 2/5.',
    ),
    Module3PracticeProblem(
      id: 'm03_q07',
      prompt: 'Divide and reduce: 7/8 ÷ 4/3.',
      expected: ExactFraction(21, 32),
      explanation: 'Invert the second fraction: 7/8 × 3/4 = 21/32.',
    ),
    Module3PracticeProblem(
      id: 'm03_q08',
      prompt: 'Convert the hole-center distance 87/32 inch to a mixed number.',
      expected: ExactFraction(87, 32),
      expectedUnit: 'in',
      explanation: '87 = 2 × 32 + 23, so 87/32 = 2 23/32 inches.',
    ),
    Module3PracticeProblem(
      id: 'm03_q09',
      prompt: 'Find the jackscrew travel: 13/16 inch − 7/16 inch.',
      expected: ExactFraction(3, 8),
      expectedUnit: 'in',
      explanation: '13/16 − 7/16 = 6/16, then reduce by 2 to 3/8 inch.',
    ),
  ];
}
