import 'unit_definition.dart';

/// An immutable group of mutually convertible units.
final class UnitCategory {
  UnitCategory({
    required String id,
    required String name,
    required Iterable<UnitDefinition> units,
    Iterable<String> aliases = const <String>[],
  }) : id = _requireNonBlank(id, 'id'),
       name = _requireNonBlank(name, 'name'),
       aliases = _normalizedAliases(aliases),
       units = _validatedUnits(units);

  /// A stable, machine-readable catalog identifier.
  final String id;

  /// The category label shown to users.
  final String name;

  /// Alternate names used by catalog search.
  final List<String> aliases;

  /// Units in their intended display order. The first item is the base unit.
  final List<UnitDefinition> units;

  /// Returns the matching unit, comparing identifiers case-insensitively.
  UnitDefinition? unitById(String id) {
    final normalizedId = id.trim().toLowerCase();
    for (final unit in units) {
      if (unit.id.toLowerCase() == normalizedId) {
        return unit;
      }
    }
    return null;
  }

  /// Returns a matching unit or throws when the catalog identifier is invalid.
  UnitDefinition requireUnitById(String id) {
    final unit = unitById(id);
    if (unit == null) {
      throw StateError('Unknown unit "$id" in category "$this".');
    }
    return unit;
  }

  /// All searchable category values in deterministic match-priority order.
  Iterable<String> get searchTerms sync* {
    yield id;
    yield name;
    yield* aliases;
  }

  @override
  String toString() => name;

  static String _requireNonBlank(String value, String argumentName) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, argumentName, 'must not be blank');
    }
    return trimmed;
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

  static List<UnitDefinition> _validatedUnits(Iterable<UnitDefinition> values) {
    final units = List<UnitDefinition>.unmodifiable(values);
    if (units.isEmpty) {
      throw ArgumentError.value(values, 'units', 'must not be empty');
    }

    final ids = <String>{};
    for (final unit in units) {
      if (!ids.add(unit.id.toLowerCase())) {
        throw ArgumentError.value(
          unit.id,
          'units',
          'contains a duplicate unit id',
        );
      }
    }
    return units;
  }
}
