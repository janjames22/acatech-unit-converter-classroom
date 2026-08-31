import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/converter/converter.dart';

void main() {
  group('built-in unit catalog', () {
    test('contains all required categories in stable display order', () {
      expect(
        builtInUnitCatalog.categories.map((category) => category.id),
        <String>[
          'length',
          'area',
          'mass',
          'temperature',
          'speed',
          'volume',
          'time',
          'digital_storage',
          'pressure',
        ],
      );
      expect(BuiltInUnitCatalog.instance, same(builtInUnitCatalog));
      expect(
        BuiltInUnitCatalog.categories,
        same(builtInUnitCatalog.categories),
      );
    });

    test('uses a scale-one base unit first in every category', () {
      for (final category in builtInUnitCatalog.categories) {
        expect(category.units.first.scale, 1, reason: category.id);
        expect(category.units.first.offset, 0, reason: category.id);
      }
    });

    test('catalog collections and identifiers are immutable and unique', () {
      expect(
        () => builtInUnitCatalog.categories.clear(),
        throwsUnsupportedError,
      );

      final categoryIds = <String>{};
      for (final category in builtInUnitCatalog.categories) {
        expect(categoryIds.add(category.id.toLowerCase()), isTrue);
        final unitIds = <String>{};
        for (final unit in category.units) {
          expect(unitIds.add(unit.id.toLowerCase()), isTrue);
        }
      }
    });

    test('looks up categories and units case-insensitively', () {
      expect(builtInUnitCatalog.categoryById(' LENGTH ')?.name, 'Length');
      expect(
        builtInUnitCatalog
            .unitById(categoryId: 'MASS', unitId: ' POUND ')
            ?.symbol,
        'lb',
      );
      expect(builtInUnitCatalog.categoryById('unknown'), isNull);
      expect(
        builtInUnitCatalog.unitById(categoryId: 'length', unitId: 'unknown'),
        isNull,
      );
      expect(
        () => builtInUnitCatalog.requireCategoryById('unknown'),
        throwsStateError,
      );
    });
  });

  group('catalog search', () {
    test('matches category names and aliases case-insensitively', () {
      final nameResults = builtInUnitCatalog.search('TEMPERATURE');
      expect(
        nameResults.where((result) => result.isCategory).single.category.id,
        'temperature',
      );

      final aliasResults = builtInUnitCatalog.search('DISTANCE');
      final aliasResult = aliasResults.single;
      expect(aliasResult.category.id, 'length');
      expect(aliasResult.matchField, UnitSearchField.alias);
      expect(aliasResult.matchedText, 'distance');
    });

    test('matches unit names, symbols, and aliases case-insensitively', () {
      final name = builtInUnitCatalog.search('FAHRENHEIT').single;
      expect(name.unit?.id, 'fahrenheit');
      expect(name.matchField, UnitSearchField.id);

      final symbol = builtInUnitCatalog.search('MMHG').single;
      expect(symbol.unit?.id, 'millimeter_of_mercury');
      expect(symbol.matchField, UnitSearchField.symbol);

      final alias = builtInUnitCatalog.search('LBS').single;
      expect(alias.unit?.id, 'pound');
      expect(alias.matchField, UnitSearchField.alias);
    });

    test(
      'category filtering includes categories matched through their units',
      () {
        expect(
          builtInUnitCatalog
              .searchCategories('gibibyte')
              .map((category) => category.id),
          <String>['digital_storage'],
        );
        expect(
          builtInUnitCatalog.searchCategories(''),
          same(builtInUnitCatalog.categories),
        );
        expect(builtInUnitCatalog.searchCategories('not-a-unit'), isEmpty);
      },
    );

    test('unit filtering supports an optional category scope', () {
      expect(
        builtInUnitCatalog
            .searchUnits('gallon', categoryId: 'volume')
            .map((unit) => unit.id),
        <String>['us_gallon', 'imperial_gallon'],
      );
      expect(
        builtInUnitCatalog.searchUnits('', categoryId: 'temperature').length,
        4,
      );
      expect(
        builtInUnitCatalog.searchUnits('', categoryId: 'missing'),
        isEmpty,
      );
      expect(
        () => builtInUnitCatalog.searchUnits('').clear(),
        throwsUnsupportedError,
      );
    });

    test('blank detailed searches return an immutable empty list', () {
      final results = builtInUnitCatalog.search('   ');
      expect(results, isEmpty);
      expect(() => results.add(_fakeResult()), throwsUnsupportedError);
    });
  });

  group('UnitCatalog validation', () {
    UnitCategory category(String id) {
      return UnitCategory(
        id: id,
        name: id,
        units: <UnitDefinition>[
          UnitDefinition(id: 'base', name: 'Base', symbol: 'b', scale: 1),
        ],
      );
    }

    test('requires categories with unique case-insensitive ids', () {
      expect(() => UnitCatalog(const []), throwsArgumentError);
      expect(
        () =>
            UnitCatalog(<UnitCategory>[category('sample'), category('SAMPLE')]),
        throwsArgumentError,
      );
    });
  });
}

UnitSearchResult _fakeResult() {
  final category = builtInUnitCatalog.categories.first;
  return UnitSearchResult.category(
    category: category,
    matchField: UnitSearchField.name,
    matchedText: category.name,
  );
}
