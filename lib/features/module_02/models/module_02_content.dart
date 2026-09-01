final class Module2Lesson {
  const Module2Lesson({
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
  final List<Module2WorkedExample> examples;
}

final class Module2WorkedExample {
  const Module2WorkedExample({
    required this.title,
    required this.given,
    required this.formula,
    required this.substitution,
    required this.solution,
    required this.explanation,
    this.aviationContext = false,
  });

  final String title;
  final String given;
  final String formula;
  final String substitution;
  final String solution;
  final String explanation;
  final bool aviationContext;
}

final class Module2PracticeProblem {
  const Module2PracticeProblem({
    required this.id,
    required this.prompt,
    required this.acceptedAnswers,
    required this.explanation,
    required this.answerLabel,
    this.unit,
  });

  final String id;
  final String prompt;
  final List<String> acceptedAnswers;
  final String explanation;
  final String answerLabel;
  final String? unit;
}

abstract final class Module2Curriculum {
  static const title = 'Module 2 — Whole Numbers';
  static const introduction =
      'Whole numbers describe complete quantities: aircraft parts in stock, '
      'completed flight hours, fasteners in a package, and technicians assigned '
      'to a task. This module builds the exact arithmetic needed for later '
      'fraction and measurement work.';

  static const objectives = <String>[
    'Read whole numbers by place value and use operation vocabulary correctly.',
    'Add, subtract, multiply, and divide whole numbers, including a remainder.',
    'Identify factors, multiples, prime factors, greatest common divisors, and least common multiples.',
    'Apply and explain divisibility tests for 2, 3, 4, 5, 6, 8, 9, and 10.',
    'Organize aviation mathematics using Given, Formula, Substitute, and Solve.',
  ];

  static const lessons = <Module2Lesson>[
    Module2Lesson(
      id: 'm02_l01',
      title: 'Whole numbers and place value',
      summary: 'Read digits according to their position and learn key terms.',
      objectives: [
        'Distinguish whole numbers from negative numbers and fractions.',
        'Name ones, tens, hundreds, thousands, and larger places.',
        'Identify addends, sums, minuends, subtrahends, and differences.',
      ],
      explanations: [
        'Whole numbers are 0, 1, 2, 3, and so on. They contain no fractional or decimal part and are never negative.',
        'A digit’s value depends on its position. In 93,132, the 9 represents 90,000 while the 3 represents 3,000.',
        'Addition combines quantities. Subtraction finds a difference. A subtraction that would produce a negative result is outside this module and is introduced in Module 9.',
      ],
      examples: [
        Module2WorkedExample(
          title: 'Read an inventory number',
          given: 'Inventory count = 93,132 rivets',
          formula: 'Value = Σ(digit × place value)',
          substitution: '90,000 + 3,000 + 100 + 30 + 2',
          solution: '93,132 rivets',
          explanation: 'Each digit contributes according to its column.',
          aviationContext: true,
        ),
      ],
    ),
    Module2Lesson(
      id: 'm02_l02',
      title: 'Addition and subtraction',
      summary: 'Align place-value columns before combining or subtracting.',
      objectives: [
        'Add several whole-number quantities accurately.',
        'Subtract a smaller whole number from a larger one.',
        'Check addition with subtraction and preserve applicable units.',
      ],
      explanations: [
        'Write ones below ones, tens below tens, and so on. Regroup only within the same place-value system.',
        'For subtraction, the minuend is the starting quantity and the subtrahend is the quantity removed.',
      ],
      examples: [
        Module2WorkedExample(
          title: 'Combine stores inventory',
          given: '4,314 + 122 + 93,132 + 10 rivets',
          formula: 'Total = sum of all inventory counts',
          substitution: '4,314 + 122 + 93,132 + 10',
          solution: '97,578 rivets',
          explanation: 'Align every value at the ones column before adding.',
          aviationContext: true,
        ),
        Module2WorkedExample(
          title: 'Flight-hour difference',
          given: 'Current total 97,564 h; earlier total 3,461 h',
          formula: 'Difference = current − earlier',
          substitution: '97,564 − 3,461',
          solution: '94,103 h',
          explanation: 'The larger recorded total is the minuend.',
          aviationContext: true,
        ),
      ],
    ),
    Module2Lesson(
      id: 'm02_l03',
      title: 'Multiplication and division',
      summary: 'Use repeated groups and interpret quotients and remainders.',
      objectives: [
        'Connect multiplication with equal repeated groups.',
        'Name dividend, divisor, quotient, and remainder.',
        'Interpret a remainder without discarding it.',
      ],
      explanations: [
        'Multiplication finds the total in equal groups. Its inputs are factors and its answer is the product.',
        'Division separates a dividend into groups defined by the divisor. The quotient counts complete groups; the remainder is what is left.',
      ],
      examples: [
        Module2WorkedExample(
          title: 'Fasteners in boxes',
          given: '35 fasteners per box × 18 boxes',
          formula: 'Total = quantity per box × number of boxes',
          substitution: '35 × 18',
          solution: '630 fasteners',
          explanation: 'The product represents all equal groups together.',
          aviationContext: true,
        ),
        Module2WorkedExample(
          title: 'Allocate parts to technicians',
          given: '218 parts; 7 technicians',
          formula: 'Parts ÷ technicians = quotient with remainder',
          substitution: '218 ÷ 7',
          solution: '31 parts each, remainder 1 part',
          explanation: 'Seven groups of 31 use 217 parts, leaving one.',
          aviationContext: true,
        ),
      ],
    ),
    Module2Lesson(
      id: 'm02_l04',
      title: 'Factors, multiples, and primes',
      summary: 'Break quantities into exact groups and compare cycles.',
      objectives: [
        'List factor pairs and recognize prime numbers.',
        'Write a number as a product of prime factors.',
        'Find greatest common divisors and least common multiples.',
      ],
      explanations: [
        'A factor divides a number with no remainder. A multiple is produced by multiplying a number by a whole number.',
        'A prime number greater than 1 has exactly two factors: 1 and itself. The number 1 is neither prime nor composite.',
        'Prime factorization records repeated factors with exponents. It supports later least-common-denominator work.',
      ],
      examples: [
        Module2WorkedExample(
          title: 'Prime-factor inspection',
          given: 'Number = 60',
          formula: 'Divide repeatedly by the smallest prime factor',
          substitution: '60 = 2 × 30 = 2 × 2 × 15 = 2 × 2 × 3 × 5',
          solution: '60 = 2² × 3 × 5',
          explanation: 'The exponent 2 records that factor 2 occurs twice.',
        ),
        Module2WorkedExample(
          title: 'Match inspection cycles',
          given: 'Cycles repeat every 16 and 24 units',
          formula: 'First shared positive multiple = LCM(16, 24)',
          substitution: '16: 16, 32, 48; 24: 24, 48',
          solution: 'LCM = 48 units',
          explanation:
              'Forty-eight is the first positive multiple in both lists.',
          aviationContext: true,
        ),
      ],
    ),
    Module2Lesson(
      id: 'm02_l05',
      title: 'Tests for divisibility',
      summary: 'Decide quickly whether division will be exact—and explain why.',
      objectives: [
        'Apply divisibility tests for 2, 3, 4, 5, 6, 8, 9, and 10.',
        'Explain the evidence used by each test.',
        'Use divisibility to prepare factors and denominators.',
      ],
      explanations: [
        'Divisibility tests inspect selected digits or digit sums. They predict an exact quotient without performing long division.',
        'A number is divisible by 6 only when it is divisible by both 2 and 3.',
      ],
      examples: [
        Module2WorkedExample(
          title: 'Check 3,816',
          given: 'Whole number = 3,816',
          formula: 'Apply the tests for 3, 4, 8, and 9',
          substitution:
              'Digit sum 18; last two digits 16; last three digits 816',
          solution: 'Divisible by 3, 4, 8, and 9',
          explanation: '18 is divisible by 3 and 9, 16 by 4, and 816 by 8.',
        ),
      ],
    ),
  ];

  static const practiceProblems = <Module2PracticeProblem>[
    Module2PracticeProblem(
      id: 'm02_q01',
      prompt:
          'A stores count combines 4,314, 122, 93,132, and 10 rivets. What is the total?',
      acceptedAnswers: ['97578', '97,578'],
      explanation:
          'Align the ones columns, then add: 4,314 + 122 + 93,132 + 10 = 97,578.',
      answerLabel: 'Total rivets',
      unit: 'rivets',
    ),
    Module2PracticeProblem(
      id: 'm02_q02',
      prompt: 'Find the difference: 97,564 − 3,461.',
      acceptedAnswers: ['94103', '94,103'],
      explanation: 'Subtract by aligned place value: 97,564 − 3,461 = 94,103.',
      answerLabel: 'Difference',
    ),
    Module2PracticeProblem(
      id: 'm02_q03',
      prompt:
          'There are 35 fasteners in each of 18 boxes. How many fasteners are there?',
      acceptedAnswers: ['630'],
      explanation: 'Use equal groups: 35 × 18 = 630 fasteners.',
      answerLabel: 'Total fasteners',
      unit: 'fasteners',
    ),
    Module2PracticeProblem(
      id: 'm02_q04',
      prompt:
          'Divide 218 parts among 7 technicians. Give the quotient and remainder.',
      acceptedAnswers: ['31 r 1', '31 remainder 1', '31 r1'],
      explanation:
          '218 = (7 × 31) + 1, so the quotient is 31 and the remainder is 1.',
      answerLabel: 'Quotient and remainder',
    ),
    Module2PracticeProblem(
      id: 'm02_q05',
      prompt: 'Write the prime factorization of 60 using exponents.',
      acceptedAnswers: ['2^2 x 3 x 5', '2² × 3 × 5', '2^2*3*5'],
      explanation: '60 = 2 × 2 × 3 × 5 = 2² × 3 × 5.',
      answerLabel: 'Prime factorization',
    ),
    Module2PracticeProblem(
      id: 'm02_q06',
      prompt: 'What is the least common multiple of 16 and 24?',
      acceptedAnswers: ['48'],
      explanation: 'The first shared positive multiple is 48.',
      answerLabel: 'LCM',
    ),
    Module2PracticeProblem(
      id: 'm02_q07',
      prompt:
          'Using only the listed tests 3, 4, 8, and 9, list those that divide 3,816 exactly.',
      acceptedAnswers: ['3 4 8 9', '3,4,8,9', '3, 4, 8, 9'],
      explanation:
          'The digit sum is 18, the last two digits are 16, and the last three are 816; all four tests pass.',
      answerLabel: 'Divisors',
    ),
  ];
}
