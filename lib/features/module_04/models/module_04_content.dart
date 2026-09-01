import '../../module_03/models/fraction_models.dart';

final class Module4Lesson {
  const Module4Lesson({
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
  final List<Module4WorkedExample> examples;
}

final class Module4WorkedExample {
  const Module4WorkedExample({
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

final class MixedGiven {
  const MixedGiven({required this.id, required this.label});

  final String id;
  final String label;
}

final class Module4PracticeProblem {
  const Module4PracticeProblem({
    required this.id,
    required this.prompt,
    required this.expected,
    required this.explanation,
    this.expectedUnit,
    this.requireMixedForm = false,
    this.givens = const [],
    this.requiredGivenIds = const {},
  });

  final String id;
  final String prompt;
  final ExactFraction expected;
  final String explanation;
  final String? expectedUnit;
  final bool requireMixedForm;
  final List<MixedGiven> givens;
  final Set<String> requiredGivenIds;
}

abstract final class Module4Curriculum {
  static const title = 'Module 4 — Mixed Numbers';
  static const introduction =
      'Mixed numbers combine whole units with fractional parts—the form commonly '
      'read from steel rules, drawings, bolt dimensions, spacers, cables, and '
      'stringers. Exact conversion to improper fractions makes carrying, '
      'borrowing, multiplication, and division reliable.';

  static const objectives = <String>[
    'Convert mixed numbers to improper fractions and improper fractions back to mixed form.',
    'Add mixed numbers and carry an improper fractional sum into the whole-number part.',
    'Subtract mixed numbers by borrowing one whole when required.',
    'Select only the givens used by a formula and reject distracters.',
    'Multiply and divide mixed numbers after exact improper-fraction conversion.',
    'Reduce fractional parts and retain applicable aviation units.',
  ];

  static const lessons = <Module4Lesson>[
    Module4Lesson(
      id: 'm04_l01',
      title: 'Mixed and improper forms',
      summary:
          'Convert both directions with multiply-add and divide-remainder steps.',
      objectives: [
        'Recognize proper, improper, and mixed forms.',
        'Convert a mixed number with whole × denominator + numerator.',
        'Convert an improper fraction using quotient and remainder.',
      ],
      explanations: [
        'A mixed number contains a whole-number part and a proper fractional part. It represents one exact value, not two separate values.',
        'For improper form, multiply the whole by the denominator and add the numerator. Keep the denominator.',
        'For mixed form, divide the numerator by the denominator. The quotient is the whole; the remainder becomes the new numerator.',
      ],
      examples: [
        Module4WorkedExample(
          title: 'Steel-rule conversion',
          given: '5 7/16 inch',
          formula: 'Improper numerator = whole × denominator + numerator',
          substitution: '5 × 16 + 7 = 87',
          solution: '5 7/16 = 87/16 inch',
          explanation: 'The denominator remains 16.',
          aviationContext: true,
        ),
        Module4WorkedExample(
          title: 'Hole-center conversion',
          given: '87/32 inch',
          formula: 'numerator ÷ denominator = whole remainder numerator',
          substitution: '87 = 2 × 32 + 23',
          solution: '87/32 = 2 23/32 inch',
          explanation: 'The remainder 23 is already reduced against 32.',
          aviationContext: true,
        ),
      ],
    ),
    Module4Lesson(
      id: 'm04_l02',
      title: 'Addition and carrying',
      summary: 'Add exact parts and carry any complete fractional whole.',
      objectives: [
        'Find a common denominator for fractional parts.',
        'Add whole and fractional parts correctly.',
        'Carry an improper fraction into the final whole-number part.',
      ],
      explanations: [
        'Fractional parts need a common denominator before addition. If their sum is improper, divide it into a whole carry and a proper remainder.',
      ],
      examples: [
        Module4WorkedExample(
          title: 'Cargo length',
          given: '4 3/4 ft + 2 1/3 ft',
          formula: 'Convert or align fractions, add, carry, and reduce',
          substitution: '6 + 9/12 + 4/12 = 6 + 13/12',
          solution: '7 1/12 ft',
          explanation: 'Carry 12/12 as one whole; 1/12 remains.',
          aviationContext: true,
        ),
      ],
    ),
    Module4Lesson(
      id: 'm04_l03',
      title: 'Subtraction and borrowing',
      summary:
          'Borrow one whole as denominator/denominator when the top fraction is smaller.',
      objectives: [
        'Identify when borrowing is necessary.',
        'Replace one whole with denominator/denominator.',
        'Subtract and reduce the final fractional part.',
      ],
      explanations: [
        'When the minuend fractional part is smaller than the subtrahend fractional part, reduce its whole part by one and add one full denominator to its numerator.',
      ],
      examples: [
        Module4WorkedExample(
          title: 'Authoritative bolt-grip calculation',
          given: 'Shank 3 1/8 inch; threaded portion 1 5/16 inch',
          formula: 'Grip = shank length − threaded length',
          substitution: '3 2/16 − 1 5/16 = 2 18/16 − 1 5/16',
          solution: '1 13/16 inch',
          explanation: 'Borrow one whole as 16/16 before subtracting.',
          aviationContext: true,
          correctionNote:
              'Authoritative curriculum result: 1 13/16 inch. The overall-length value is a distracter.',
        ),
      ],
    ),
    Module4Lesson(
      id: 'm04_l04',
      title: 'Select givens and reject distracters',
      summary:
          'Let the formula determine which measurements belong in the calculation.',
      objectives: [
        'Identify the quantity requested by the problem.',
        'Select only values named by the formula.',
        'Explain why an extra measurement is a distracter.',
      ],
      explanations: [
        'A drawing or maintenance-style problem can contain more values than one formula needs. Select givens only after naming the requested result and formula.',
        'The bolt-grip formula uses shank length and threaded length. Overall length is not consumed by that formula and must be ignored.',
      ],
      examples: [
        Module4WorkedExample(
          title: 'Bolt measurement selection',
          given: 'Shank 3 1/8; threaded 1 5/16; overall length 4 inches',
          formula: 'Grip = shank − threaded portion',
          substitution: 'Use 3 1/8 and 1 5/16; ignore 4',
          solution: 'Selected givens produce 1 13/16 inch',
          explanation:
              'The overall-length distracter is not a term in the formula.',
          aviationContext: true,
        ),
      ],
    ),
    Module4Lesson(
      id: 'm04_l05',
      title: 'Multiplication, division, and cut planning',
      summary:
          'Convert first, operate exactly, then return to reduced mixed form.',
      objectives: [
        'Multiply mixed numbers using improper fractions.',
        'Divide mixed numbers using the reciprocal rule.',
        'Report complete pieces and leftover length for a cut plan.',
      ],
      explanations: [
        'Do not multiply whole and fractional parts separately. Convert each entire mixed number to one improper fraction first.',
        'For division, convert both values, invert the divisor, and multiply. Cut planning uses the whole quotient as the piece count and retains the exact remainder.',
      ],
      examples: [
        Module4WorkedExample(
          title: 'Spacer stack',
          given: '12 spacers × 1 3/8 inch each',
          formula: 'Total = count × thickness',
          substitution: '12 × 11/8 = 132/8',
          solution: '16 1/2 inches',
          explanation: 'Reduce 132/8 to 33/2, then convert to mixed form.',
          aviationContext: true,
        ),
        Module4WorkedExample(
          title: 'Control-cable cut count',
          given: '7 1/2 ft available; 1 1/4 ft per piece',
          formula: 'Pieces = total length ÷ length per piece',
          substitution: '15/2 ÷ 5/4 = 15/2 × 4/5',
          solution: '6 complete pieces',
          explanation: 'The division is exact, so no length remains.',
          aviationContext: true,
        ),
      ],
    ),
  ];

  static final practiceProblems = <Module4PracticeProblem>[
    Module4PracticeProblem(
      id: 'm04_q01',
      prompt: 'Convert 5 7/16 to an improper fraction.',
      expected: ExactFraction(87, 16),
      explanation: '5 × 16 + 7 = 87, so the result is 87/16.',
    ),
    Module4PracticeProblem(
      id: 'm04_q02',
      prompt: 'Convert 87/32 to a reduced mixed number.',
      expected: ExactFraction(87, 32),
      requireMixedForm: true,
      explanation: '87 = 2 × 32 + 23, so the result is 2 23/32.',
    ),
    Module4PracticeProblem(
      id: 'm04_q03',
      prompt: 'Find the cargo length: 4 3/4 ft + 2 1/3 ft.',
      expected: ExactFraction(85, 12),
      expectedUnit: 'ft',
      requireMixedForm: true,
      explanation: '4 3/4 + 2 1/3 = 6 + 13/12 = 7 1/12 ft.',
    ),
    Module4PracticeProblem(
      id: 'm04_q04',
      prompt:
          'Select the givens used by the bolt-grip formula, then calculate the grip.',
      expected: ExactFraction(29, 16),
      expectedUnit: 'in',
      requireMixedForm: true,
      givens: [
        MixedGiven(id: 'shank', label: 'Shank: 3 1/8 in'),
        MixedGiven(id: 'threaded', label: 'Threaded: 1 5/16 in'),
        MixedGiven(id: 'overall', label: 'Overall length: 4 in'),
      ],
      requiredGivenIds: {'shank', 'threaded'},
      explanation:
          'Use shank and threaded lengths only: 3 1/8 − 1 5/16 = 1 13/16 in.',
    ),
    Module4PracticeProblem(
      id: 'm04_q05',
      prompt: 'Multiply: 2 1/2 × 1 3/4. Give a reduced mixed answer.',
      expected: ExactFraction(35, 8),
      requireMixedForm: true,
      explanation:
          'Convert first: 5/2 × 7/4 = 35/8 = 4 3/8. Multiplying parts separately is invalid.',
    ),
    Module4PracticeProblem(
      id: 'm04_q06',
      prompt:
          'Twelve spacers are each 1 3/8 in thick. Find the stack thickness.',
      expected: ExactFraction(33, 2),
      expectedUnit: 'in',
      requireMixedForm: true,
      explanation: '12 × 11/8 = 132/8 = 33/2 = 16 1/2 in.',
    ),
    Module4PracticeProblem(
      id: 'm04_q07',
      prompt: 'How many 1 1/4 ft pieces fit exactly into 7 1/2 ft?',
      expected: ExactFraction(6, 1),
      expectedUnit: 'pieces',
      explanation: '15/2 ÷ 5/4 = 6 complete pieces.',
    ),
    Module4PracticeProblem(
      id: 'm04_q08',
      prompt:
          'Eight feet is cut into 1 1/2 ft pieces. What exact length remains?',
      expected: ExactFraction(1, 2),
      expectedUnit: 'ft',
      explanation: 'Five pieces use 7 1/2 ft, leaving 1/2 ft.',
    ),
  ];
}
