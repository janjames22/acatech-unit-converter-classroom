import 'decimal_models.dart';

final class Module5Lesson {
  const Module5Lesson({
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
  final List<Module5WorkedExample> examples;
}

final class Module5WorkedExample {
  const Module5WorkedExample({
    required this.title,
    required this.given,
    required this.formula,
    required this.substitution,
    required this.solution,
    required this.explanation,
    this.aviationContext = false,
    this.correctionNote,
    this.repeatingDigits,
  });

  final String title;
  final String given;
  final String formula;
  final String substitution;
  final String solution;
  final String explanation;
  final bool aviationContext;
  final String? correctionNote;
  final String? repeatingDigits;
}

enum DecimalAnswerKind { decimal, fraction, repeating }

final class Module5PracticeProblem {
  const Module5PracticeProblem._({
    required this.id,
    required this.prompt,
    required this.kind,
    required this.explanation,
    this.expectedDecimal,
    this.expectedFraction,
    this.expectedRepeating,
    this.expectedUnit,
    this.requiredDecimalPlaces,
  });

  factory Module5PracticeProblem.decimal({
    required String id,
    required String prompt,
    required String expected,
    required String explanation,
    String? expectedUnit,
    int? requiredDecimalPlaces,
  }) => Module5PracticeProblem._(
    id: id,
    prompt: prompt,
    kind: DecimalAnswerKind.decimal,
    expectedDecimal: DecimalQuantity.parse(expected),
    explanation: explanation,
    expectedUnit: expectedUnit,
    requiredDecimalPlaces: requiredDecimalPlaces,
  );

  factory Module5PracticeProblem.fraction({
    required String id,
    required String prompt,
    required BigDecimalFraction expected,
    required String explanation,
    String? expectedUnit,
  }) => Module5PracticeProblem._(
    id: id,
    prompt: prompt,
    kind: DecimalAnswerKind.fraction,
    expectedFraction: expected,
    explanation: explanation,
    expectedUnit: expectedUnit,
  );

  factory Module5PracticeProblem.repeating({
    required String id,
    required String prompt,
    required String expected,
    required String explanation,
  }) => Module5PracticeProblem._(
    id: id,
    prompt: prompt,
    kind: DecimalAnswerKind.repeating,
    expectedRepeating: expected,
    explanation: explanation,
  );

  final String id;
  final String prompt;
  final DecimalAnswerKind kind;
  final DecimalQuantity? expectedDecimal;
  final BigDecimalFraction? expectedFraction;
  final String? expectedRepeating;
  final String explanation;
  final String? expectedUnit;
  final int? requiredDecimalPlaces;
}

abstract final class Module5Curriculum {
  static const title = 'Module 5 — The Decimal Number System';
  static const introduction =
      'Decimals express base-ten parts used throughout aircraft measurements, '
      'electrical work, drill and reamer selection, dimensions, and calculated '
      'results. This module keeps decimal arithmetic exact and delays rounding '
      'until the specified final step.';

  static const objectives = <String>[
    'Identify, read, and compare decimal place values on both sides of the point.',
    'Add and subtract decimals by aligning decimal points.',
    'Multiply decimals by counting places and divide by clearing the divisor point.',
    'Apply the curriculum half-up rule only at the requested final place.',
    'Convert decimals to exact fractions and fractions to terminating or repeating decimals.',
    'Use the shop 64ths method and select a drill 1/64 inch below a reamed size.',
  ];

  static const lessons = <Module5Lesson>[
    Module5Lesson(
      id: 'm05_l01',
      title: 'Base ten, place value, reading, and comparison',
      summary:
          'Locate every digit and compare exact decimal quantities safely.',
      objectives: [
        'Name whole-number and fractional decimal places.',
        'Read a decimal as whole units and a base-ten fractional group.',
        'Compare decimals after aligning equivalent place values.',
      ],
      explanations: [
        'Each move left multiplies a place value by ten; each move right divides it by ten. The first three fractional places are tenths, hundredths, and thousandths.',
        'Leading zeros locate a fractional digit and cannot be discarded carelessly. Trailing zeros do not change value: 0.50 and 0.5 are equal.',
        'Compare aligned digits from left to right. Do not compare the visible digit counts as whole numbers.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Reading a reamed dimension',
          given: '0.763 inch',
          formula: 'Read the fractional group using its final place',
          substitution: '763 occupies the thousandths group',
          solution: 'zero and 763 thousandths inch',
          explanation:
              'The 7 is tenths, 6 is hundredths, and 3 is thousandths.',
          aviationContext: true,
        ),
        Module5WorkedExample(
          title: 'Compare two dimensions',
          given: '0.763 inch and 0.736 inch',
          formula: 'Compare tenths, then hundredths, then thousandths',
          substitution: '7 tenths = 7 tenths; 6 hundredths > 3 hundredths',
          solution: '0.763 inch > 0.736 inch',
          explanation: 'The first unequal aligned digit determines the result.',
          aviationContext: true,
        ),
      ],
    ),
    Module5Lesson(
      id: 'm05_l02',
      title: 'Addition and subtraction',
      summary: 'Align decimal points before operating column by column.',
      objectives: [
        'Add zeros as alignment placeholders without changing value.',
        'Add several decimal quantities exactly.',
        'Subtract aligned quantities and preserve the correct scale.',
      ],
      explanations: [
        'Decimal points must align because each column represents the same place value. Placeholder zeros make the alignment visible.',
        'Do not round intermediate values unless the problem explicitly requires it.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Series resistance',
          given: '2.34 Ω + 37.5 Ω + 0.09 Ω',
          formula: 'R total = R1 + R2 + R3',
          substitution: '2.34 + 37.50 + 0.09',
          solution: '39.93 Ω',
          explanation: 'Align the decimal points and add hundredths columns.',
          aviationContext: true,
        ),
        Module5WorkedExample(
          title: 'Remaining material',
          given: '37.272 in − 14.88 in',
          formula: 'Remaining = original − used',
          substitution: '37.272 − 14.880',
          solution: '22.392 in',
          explanation: 'The placeholder zero preserves thousandths alignment.',
          aviationContext: true,
        ),
      ],
    ),
    Module5Lesson(
      id: 'm05_l03',
      title: 'Multiplication and division',
      summary:
          'Count product places and clear the divisor decimal before division.',
      objectives: [
        'Place the decimal in a product from the combined fractional digits.',
        'Move both decimal points equally to make a whole-number divisor.',
        'Recognize terminating and repeating quotients.',
      ],
      explanations: [
        'For multiplication, multiply coefficients first and place the total number of fractional digits in the product.',
        'For division, multiplying dividend and divisor by the same power of ten preserves the quotient. A quotient may terminate or repeat.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Electrical power',
          given: '9.45 A × 120 V',
          formula: 'P = I × V',
          substitution: '945 × 120 with two product decimal places',
          solution: '1,134 W',
          explanation:
              'The exact product is a whole number; no early rounding occurs.',
          aviationContext: true,
        ),
        Module5WorkedExample(
          title: 'Wing dimension quotient',
          given: '262.6 ft ÷ 40.4',
          formula: 'Quotient = dividend ÷ divisor',
          substitution: '2626 ÷ 404',
          solution: '6.5 ft',
          explanation:
              'Move both points one place; the exact quotient terminates.',
          aviationContext: true,
        ),
      ],
    ),
    Module5Lesson(
      id: 'm05_l04',
      title: 'Final-step half-up rounding',
      summary:
          'Retain the requested place and inspect exactly one following digit.',
      objectives: [
        'Identify retained and inspection digits.',
        'Round an inspection digit of 5 or greater upward.',
        'Keep full precision through intermediate calculations.',
      ],
      explanations: [
        'The curriculum uses half-up rounding: inspect the first digit after the retained place. If it is 5 or greater, increase the retained digit by one.',
        'Rounding changes a value and must occur only at the place and step requested by the problem.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Three precision requests',
          given: '2.1938; 3.1648; 3.7487',
          formula: 'Retain requested place; inspect next digit',
          substitution:
              'tenths inspect 9; hundredths inspect 4; thousandths inspect 7',
          solution: '2.2; 3.16; 3.749',
          explanation: 'Only the requested final result is rounded.',
        ),
      ],
    ),
    Module5Lesson(
      id: 'm05_l05',
      title: 'Decimal-to-fraction shop 64ths',
      summary: 'Multiply by 64, round once, place over 64, and reduce.',
      objectives: [
        'Convert a decimal dimension to a practical 64ths fraction.',
        'Apply half-up rounding only to the numerator step.',
        'Choose a drill 1/64 inch below the reamed fraction.',
      ],
      explanations: [
        'The curriculum shop method multiplies the decimal by 64, rounds the result to a whole numerator, places it over 64, then reduces.',
        'For drill/ream planning, first convert the reamed size. Then subtract exactly 1/64 inch from that fraction.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Shop 64ths conversion',
          given: '0.3123 inch',
          formula: 'decimal × 64 → rounded numerator/64 → reduce',
          substitution: '0.3123 × 64 = 19.9872 → 20/64',
          solution: '5/16 inch',
          explanation: 'Round only 19.9872 to 20, then reduce 20/64.',
          aviationContext: true,
        ),
        Module5WorkedExample(
          title: 'Drill before reaming',
          given: 'Reamed diameter 0.763 inch',
          formula: 'reamed 64ths − 1/64 inch',
          substitution: '0.763 × 64 = 48.832 → 49/64; 49/64 − 1/64',
          solution: '3/4 inch drill',
          explanation:
              'The reamed fraction is 49/64; the drill is 48/64 = 3/4.',
          aviationContext: true,
        ),
      ],
    ),
    Module5Lesson(
      id: 'm05_l06',
      title: 'Fraction-to-decimal and repeating notation',
      summary:
          'Use exact long division and display repeating cycles explicitly.',
      objectives: [
        'Convert terminating fractions to exact decimals.',
        'Detect a repeated remainder during long division.',
        'Display repeating digits with an explicit bar and preserve the corrected 9/16 chart row.',
      ],
      explanations: [
        'A fraction terminates when long division reaches a zero remainder. If a remainder repeats, the digits generated from that remainder repeat forever.',
        'Repeating digits must be visibly marked; silently truncating them creates a different value.',
      ],
      examples: [
        Module5WorkedExample(
          title: 'Terminating examples',
          given: '1/2 and 3/8',
          formula: 'numerator ÷ denominator',
          substitution: '1 ÷ 2; 3 ÷ 8',
          solution: '0.5 and 0.375',
          explanation: 'Both divisions reach a zero remainder.',
        ),
        Module5WorkedExample(
          title: 'Repeating thirds',
          given: '1/3',
          formula: '1 ÷ 3',
          substitution: 'Remainder 1 repeats after every digit 3',
          solution: '0.3 with a bar over 3',
          explanation: 'The bar means the marked digit repeats without ending.',
          repeatingDigits: '3',
        ),
        Module5WorkedExample(
          title: 'Corrected decimal-equivalent chart row',
          given: '9/16 inch',
          formula: '9 ÷ 16',
          substitution: '9/16 = 0.5625 inch',
          solution: '0.5625 inch = 14.2875 mm',
          explanation:
              'The displayed decimal and millimetre values belong to 9/16.',
          correctionNote:
              'Curriculum erratum: the corrupted row label “39341” is 9/16.',
          aviationContext: true,
        ),
      ],
    ),
  ];

  static final practiceProblems = <Module5PracticeProblem>[
    Module5PracticeProblem.decimal(
      id: 'm05_q01',
      prompt: 'Write “37 and 5 thousandths” as a decimal.',
      expected: '37.005',
      explanation: 'Five thousandths occupies the third place: 37.005.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q02',
      prompt: 'Enter the greater dimension: 0.763 or 0.736.',
      expected: '0.763',
      expectedUnit: 'in',
      explanation:
          'The tenths match; 6 hundredths is greater than 3 hundredths.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q03',
      prompt: 'Find the total resistance: 2.34 Ω + 37.5 Ω + 0.09 Ω.',
      expected: '39.93',
      expectedUnit: 'Ω',
      explanation: '2.34 + 37.50 + 0.09 = 39.93 Ω.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q04',
      prompt: 'Subtract: 37.272 in − 14.88 in.',
      expected: '22.392',
      expectedUnit: 'in',
      explanation: '37.272 − 14.880 = 22.392 in.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q05',
      prompt: 'Calculate power: 9.45 A × 120 V.',
      expected: '1134',
      expectedUnit: 'W',
      explanation: '9.45 × 120 = 1,134 W exactly.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q06',
      prompt: 'Divide: 262.6 ft ÷ 40.4.',
      expected: '6.5',
      expectedUnit: 'ft',
      explanation: '2626 ÷ 404 reduces to 13/2 = 6.5 ft.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q07',
      prompt: 'Round 2.1938 to the nearest tenth.',
      expected: '2.2',
      requiredDecimalPlaces: 1,
      explanation:
          'Retain 1 and inspect 9, so the retained digit rounds up to 2.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q08',
      prompt: 'Round 3.1648 to the nearest hundredth.',
      expected: '3.16',
      requiredDecimalPlaces: 2,
      explanation: 'Retain 6 and inspect 4, so the retained digit stays 6.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q09',
      prompt: 'Round 3.7487 to the nearest thousandth.',
      expected: '3.749',
      requiredDecimalPlaces: 3,
      explanation: 'Retain 8 and inspect 7, so 8 rounds upward to 9.',
    ),
    Module5PracticeProblem.fraction(
      id: 'm05_q10',
      prompt: 'Use the shop 64ths method to convert 0.3123 inch. Reduce.',
      expected: BigDecimalFraction(BigInt.from(5), BigInt.from(16)),
      expectedUnit: 'in',
      explanation: '0.3123 × 64 = 19.9872 → 20/64 = 5/16 inch.',
    ),
    Module5PracticeProblem.fraction(
      id: 'm05_q11',
      prompt:
          'A hole will be reamed to 0.763 inch. Select the drill 1/64 inch smaller.',
      expected: BigDecimalFraction(BigInt.from(3), BigInt.from(4)),
      expectedUnit: 'in',
      explanation: '0.763 → 49/64; subtract 1/64 to obtain 48/64 = 3/4 inch.',
    ),
    Module5PracticeProblem.decimal(
      id: 'm05_q12',
      prompt: 'Convert 3/8 to an exact decimal.',
      expected: '0.375',
      explanation: '3 ÷ 8 terminates at 0.375.',
    ),
    Module5PracticeProblem.repeating(
      id: 'm05_q13',
      prompt: 'Convert 1/3 using parenthesized repeating notation.',
      expected: '0.(3)',
      explanation: 'The remainder repeats, so 0.(3) marks 3 as recurring.',
    ),
  ];
}
