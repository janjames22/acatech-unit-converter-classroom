import '../models/whole_number_models.dart';

final class WholeNumbersEngine {
  const WholeNumbersEngine();

  int add(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) {
      throw const WholeNumberException('Enter at least one whole number.');
    }
    _requireWholeNumbers(list);
    return list.fold(0, (total, value) => total + value);
  }

  int subtract(int minuend, int subtrahend) {
    _requireWholeNumbers([minuend, subtrahend]);
    if (subtrahend > minuend) {
      throw const WholeNumberException(
        'This result is negative and belongs to Module 9.',
      );
    }
    return minuend - subtrahend;
  }

  int multiply(int left, int right) {
    _requireWholeNumbers([left, right]);
    return left * right;
  }

  DivisionResult divide(int dividend, int divisor) {
    _requireWholeNumbers([dividend, divisor]);
    if (divisor == 0) {
      throw const WholeNumberException('Division by zero is undefined.');
    }
    return DivisionResult(
      quotient: dividend ~/ divisor,
      remainder: dividend.remainder(divisor),
    );
  }

  List<int> factors(int value) {
    _requirePositive(value, name: 'Number');
    final lower = <int>[];
    final upper = <int>[];
    for (var candidate = 1; candidate * candidate <= value; candidate++) {
      if (value % candidate != 0) {
        continue;
      }
      lower.add(candidate);
      final pair = value ~/ candidate;
      if (pair != candidate) {
        upper.add(pair);
      }
    }
    return [...lower, ...upper.reversed];
  }

  List<PrimeFactor> primeFactorization(int value) {
    _requirePositive(value, name: 'Number');
    if (value == 1) {
      return const [];
    }
    var remaining = value;
    var candidate = 2;
    final result = <PrimeFactor>[];
    while (candidate * candidate <= remaining) {
      var exponent = 0;
      while (remaining % candidate == 0) {
        remaining ~/= candidate;
        exponent++;
      }
      if (exponent > 0) {
        result.add(PrimeFactor(base: candidate, exponent: exponent));
      }
      candidate = candidate == 2 ? 3 : candidate + 2;
    }
    if (remaining > 1) {
      result.add(PrimeFactor(base: remaining, exponent: 1));
    }
    return List.unmodifiable(result);
  }

  List<int> multiples(int value, {int count = 10}) {
    _requirePositive(value, name: 'Number');
    if (count <= 0) {
      throw const WholeNumberException('Multiple count must be positive.');
    }
    return List.generate(count, (index) => value * (index + 1));
  }

  int greatestCommonDivisor(int left, int right) {
    _requirePositive(left, name: 'First number');
    _requirePositive(right, name: 'Second number');
    var a = left;
    var b = right;
    while (b != 0) {
      final remainder = a % b;
      a = b;
      b = remainder;
    }
    return a;
  }

  int leastCommonMultiple(int left, int right) {
    _requirePositive(left, name: 'First number');
    _requirePositive(right, name: 'Second number');
    return (left ~/ greatestCommonDivisor(left, right)) * right;
  }

  List<PlaceValueRow> placeValues(int number) {
    _requireWholeNumbers([number]);
    if (number == 0) {
      return const [PlaceValueRow(digit: 0, placeName: 'ones', placeValue: 1)];
    }
    const names = <String>[
      'ones',
      'tens',
      'hundreds',
      'thousands',
      'ten-thousands',
      'hundred-thousands',
      'millions',
      'ten-millions',
      'hundred-millions',
      'billions',
    ];
    var remaining = number;
    var place = 1;
    var index = 0;
    final rows = <PlaceValueRow>[];
    while (remaining > 0) {
      rows.add(
        PlaceValueRow(
          digit: remaining % 10,
          placeName: index < names.length ? names[index] : '10^$index place',
          placeValue: place,
        ),
      );
      remaining ~/= 10;
      place *= 10;
      index++;
    }
    return rows.reversed.toList(growable: false);
  }

  DivisibilityResult checkDivisibility(int number, DivisibilityRule rule) {
    _requireWholeNumbers([number]);
    final digits = number.toString();
    final digitSum = digits.codeUnits.fold<int>(
      0,
      (sum, codeUnit) => sum + codeUnit - 0x30,
    );
    final lastTwo = number % 100;
    final lastThree = number % 1000;
    final divisible = number % rule.divisor == 0;
    final evidence = switch (rule) {
      DivisibilityRule.by2 =>
        'the last digit ${number % 10} is ${divisible ? 'even' : 'not even'}',
      DivisibilityRule.by3 =>
        'the digit sum is $digitSum, which is ${divisible ? '' : 'not '}divisible by 3',
      DivisibilityRule.by4 =>
        'the last two digits form $lastTwo, which is ${divisible ? '' : 'not '}divisible by 4',
      DivisibilityRule.by5 =>
        'the last digit ${number % 10} is ${divisible ? '0 or 5' : 'neither 0 nor 5'}',
      DivisibilityRule.by6 =>
        'the number is ${divisible ? '' : 'not '}divisible by both 2 and 3',
      DivisibilityRule.by8 =>
        'the last three digits form $lastThree, which is ${divisible ? '' : 'not '}divisible by 8',
      DivisibilityRule.by9 =>
        'the digit sum is $digitSum, which is ${divisible ? '' : 'not '}divisible by 9',
      DivisibilityRule.by10 =>
        'the last digit ${number % 10} is ${divisible ? '0' : 'not 0'}',
    };
    return DivisibilityResult(
      number: number,
      rule: rule,
      isDivisible: divisible,
      explanation:
          '$number is ${divisible ? '' : 'not '}divisible by ${rule.divisor} because $evidence.',
    );
  }

  static void _requireWholeNumbers(Iterable<int> values) {
    if (values.any((value) => value < 0)) {
      throw const WholeNumberException(
        'Whole numbers in Module 2 cannot be negative.',
      );
    }
  }

  static void _requirePositive(int value, {required String name}) {
    if (value <= 0) {
      throw WholeNumberException('$name must be greater than zero.');
    }
  }
}
