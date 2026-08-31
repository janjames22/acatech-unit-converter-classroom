/// An immutable description of a unit and its relationship to a category's
/// base unit.
///
/// Conversion uses the affine formula:
///
/// ```text
/// baseValue = value * scale + offset
/// ```
///
/// Linear units use an [offset] of zero. Affine units such as Fahrenheit use
/// both values.
final class UnitDefinition {
  UnitDefinition({
    required String id,
    required String name,
    required String symbol,
    required double scale,
    double offset = 0,
    Iterable<String> aliases = const <String>[],
  }) : id = _requireNonBlank(id, 'id'),
       name = _requireNonBlank(name, 'name'),
       symbol = _requireNonBlank(symbol, 'symbol'),
       scale = _requirePositiveFinite(scale, 'scale'),
       offset = _requireFinite(offset, 'offset'),
       aliases = _normalizedAliases(aliases);

  /// A stable, machine-readable identifier unique within its category.
  final String id;

  /// The full, human-readable unit name.
  final String name;

  /// The conventional short representation shown beside values.
  final String symbol;

  /// The multiplicative part of the conversion to the category base unit.
  final double scale;

  /// The additive part of the conversion to the category base unit.
  final double offset;

  /// Alternate names and abbreviations used by catalog search.
  final List<String> aliases;

  /// Converts [value] from this unit into the category base unit.
  double toBase(double value) => value * scale + offset;

  /// Converts a category [baseValue] into this unit.
  double fromBase(double baseValue) => (baseValue - offset) / scale;

  /// All searchable values in deterministic match-priority order.
  Iterable<String> get searchTerms sync* {
    yield id;
    yield name;
    yield symbol;
    yield* aliases;
  }

  @override
  String toString() => '$name ($symbol)';

  static String _requireNonBlank(String value, String argumentName) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, argumentName, 'must not be blank');
    }
    return trimmed;
  }

  static double _requirePositiveFinite(double value, String argumentName) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        argumentName,
        'must be finite and greater than zero',
      );
    }
    return value;
  }

  static double _requireFinite(double value, String argumentName) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, argumentName, 'must be finite');
    }
    return value;
  }

  static List<String> _normalizedAliases(Iterable<String> values) {
    final aliases = <String>[];
    final normalized = <String>{};

    for (final value in values) {
      final alias = value.trim();
      if (alias.isEmpty) {
        continue;
      }
      if (normalized.add(alias.toLowerCase())) {
        aliases.add(alias);
      }
    }

    return List<String>.unmodifiable(aliases);
  }
}
