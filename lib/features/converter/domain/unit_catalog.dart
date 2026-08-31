import '../models/unit_category.dart';
import '../models/unit_definition.dart';
import '../models/unit_search_result.dart';

/// An immutable, searchable collection of unit categories.
final class UnitCatalog {
  UnitCatalog(Iterable<UnitCategory> categories)
    : categories = _validatedCategories(categories);

  final List<UnitCategory> categories;

  /// Finds a category by id using a case-insensitive comparison.
  UnitCategory? categoryById(String id) {
    final normalizedId = id.trim().toLowerCase();
    for (final category in categories) {
      if (category.id.toLowerCase() == normalizedId) {
        return category;
      }
    }
    return null;
  }

  /// Finds a category or throws when [id] is not in this catalog.
  UnitCategory requireCategoryById(String id) {
    final category = categoryById(id);
    if (category == null) {
      throw StateError('Unknown unit category "$id".');
    }
    return category;
  }

  /// Finds a unit within a category. Unknown category or unit ids return null.
  UnitDefinition? unitById({
    required String categoryId,
    required String unitId,
  }) {
    return categoryById(categoryId)?.unitById(unitId);
  }

  /// Searches category ids/names/aliases and unit ids/names/symbols/aliases.
  ///
  /// Matching is case-insensitive, trims the query, and uses substring
  /// matching. Results follow catalog and unit display order. An empty query
  /// intentionally has no detailed matches; use [searchCategories] to obtain
  /// all browseable categories.
  List<UnitSearchResult> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const <UnitSearchResult>[];
    }

    final results = <UnitSearchResult>[];
    for (final category in categories) {
      final categoryMatch = _matchCategory(category, normalizedQuery);
      if (categoryMatch != null) {
        results.add(
          UnitSearchResult.category(
            category: category,
            matchField: categoryMatch.field,
            matchedText: categoryMatch.text,
          ),
        );
      }

      for (final unit in category.units) {
        final unitMatch = _matchUnit(unit, normalizedQuery);
        if (unitMatch != null) {
          results.add(
            UnitSearchResult.unit(
              category: category,
              unit: unit,
              matchField: unitMatch.field,
              matchedText: unitMatch.text,
            ),
          );
        }
      }
    }
    return List<UnitSearchResult>.unmodifiable(results);
  }

  /// Returns categories whose own terms or any contained unit match [query].
  ///
  /// An empty query returns every category, which is convenient for filtering
  /// category cards as the user edits a search field.
  List<UnitCategory> searchCategories(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return categories;
    }

    final results = categories.where((category) {
      if (_matchCategory(category, normalizedQuery) != null) {
        return true;
      }
      return category.units.any(
        (unit) => _matchUnit(unit, normalizedQuery) != null,
      );
    });
    return List<UnitCategory>.unmodifiable(results);
  }

  /// Returns matching units, optionally restricted to one category id.
  ///
  /// An empty query returns all units in scope. An unknown [categoryId]
  /// returns an empty list.
  List<UnitDefinition> searchUnits(String query, {String? categoryId}) {
    final normalizedQuery = query.trim().toLowerCase();
    final scopedCategories = categoryId == null
        ? categories
        : <UnitCategory>[?categoryById(categoryId)];

    final units = <UnitDefinition>[];
    for (final category in scopedCategories) {
      for (final unit in category.units) {
        if (normalizedQuery.isEmpty ||
            _matchUnit(unit, normalizedQuery) != null) {
          units.add(unit);
        }
      }
    }
    return List<UnitDefinition>.unmodifiable(units);
  }

  static _SearchMatch? _matchCategory(UnitCategory category, String query) {
    if (category.id.toLowerCase().contains(query)) {
      return _SearchMatch(UnitSearchField.id, category.id);
    }
    if (category.name.toLowerCase().contains(query)) {
      return _SearchMatch(UnitSearchField.name, category.name);
    }
    for (final alias in category.aliases) {
      if (alias.toLowerCase().contains(query)) {
        return _SearchMatch(UnitSearchField.alias, alias);
      }
    }
    return null;
  }

  static _SearchMatch? _matchUnit(UnitDefinition unit, String query) {
    if (unit.id.toLowerCase().contains(query)) {
      return _SearchMatch(UnitSearchField.id, unit.id);
    }
    if (unit.name.toLowerCase().contains(query)) {
      return _SearchMatch(UnitSearchField.name, unit.name);
    }
    if (unit.symbol.toLowerCase().contains(query)) {
      return _SearchMatch(UnitSearchField.symbol, unit.symbol);
    }
    for (final alias in unit.aliases) {
      if (alias.toLowerCase().contains(query)) {
        return _SearchMatch(UnitSearchField.alias, alias);
      }
    }
    return null;
  }

  static List<UnitCategory> _validatedCategories(
    Iterable<UnitCategory> values,
  ) {
    final categories = List<UnitCategory>.unmodifiable(values);
    if (categories.isEmpty) {
      throw ArgumentError.value(values, 'categories', 'must not be empty');
    }

    final ids = <String>{};
    for (final category in categories) {
      if (!ids.add(category.id.toLowerCase())) {
        throw ArgumentError.value(
          category.id,
          'categories',
          'contains a duplicate category id',
        );
      }
    }
    return categories;
  }
}

final class _SearchMatch {
  const _SearchMatch(this.field, this.text);

  final UnitSearchField field;
  final String text;
}
