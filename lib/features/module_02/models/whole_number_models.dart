enum WholeNumberOperation { addition, subtraction, multiplication, division }

final class DivisionResult {
  const DivisionResult({required this.quotient, required this.remainder});

  final int quotient;
  final int remainder;

  bool get isExact => remainder == 0;

  @override
  bool operator ==(Object other) =>
      other is DivisionResult &&
      quotient == other.quotient &&
      remainder == other.remainder;

  @override
  int get hashCode => Object.hash(quotient, remainder);
}

final class PrimeFactor {
  const PrimeFactor({required this.base, required this.exponent});

  final int base;
  final int exponent;

  @override
  String toString() => exponent == 1 ? '$base' : '$base^$exponent';

  @override
  bool operator ==(Object other) =>
      other is PrimeFactor && base == other.base && exponent == other.exponent;

  @override
  int get hashCode => Object.hash(base, exponent);
}

enum DivisibilityRule {
  by2(2),
  by3(3),
  by4(4),
  by5(5),
  by6(6),
  by8(8),
  by9(9),
  by10(10);

  const DivisibilityRule(this.divisor);

  final int divisor;
}

final class DivisibilityResult {
  const DivisibilityResult({
    required this.number,
    required this.rule,
    required this.isDivisible,
    required this.explanation,
  });

  final int number;
  final DivisibilityRule rule;
  final bool isDivisible;
  final String explanation;
}

final class PlaceValueRow {
  const PlaceValueRow({
    required this.digit,
    required this.placeName,
    required this.placeValue,
  });

  final int digit;
  final String placeName;
  final int placeValue;

  int get contribution => digit * placeValue;
}

final class WholeNumberException implements Exception {
  const WholeNumberException(this.message);

  final String message;

  @override
  String toString() => message;
}
