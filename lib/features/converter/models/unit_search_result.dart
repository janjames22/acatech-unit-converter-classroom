import 'unit_category.dart';
import 'unit_definition.dart';

/// The field which satisfied a catalog search.
enum UnitSearchField { id, name, symbol, alias }

/// A category or unit matched by a catalog search.
final class UnitSearchResult {
  const UnitSearchResult.category({
    required this.category,
    required this.matchField,
    required this.matchedText,
  }) : unit = null;

  const UnitSearchResult.unit({
    required this.category,
    required UnitDefinition this.unit,
    required this.matchField,
    required this.matchedText,
  });

  final UnitCategory category;
  final UnitDefinition? unit;
  final UnitSearchField matchField;
  final String matchedText;

  bool get isCategory => unit == null;
  bool get isUnit => unit != null;

  String get label => unit?.name ?? category.name;
}
