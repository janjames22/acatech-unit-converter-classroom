import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/converter/converter.dart';

void main() {
  group('UnitDefinition', () {
    test('normalizes metadata and exposes an immutable alias list', () {
      final unit = UnitDefinition(
        id: ' meter ',
        name: ' Meter ',
        symbol: ' m ',
        scale: 1,
        aliases: const <String>[' metre ', 'METRE', '', 'meters'],
      );

      expect(unit.id, 'meter');
      expect(unit.name, 'Meter');
      expect(unit.symbol, 'm');
      expect(unit.aliases, <String>['metre', 'meters']);
      expect(() => unit.aliases.add('m'), throwsUnsupportedError);
      expect(unit.toString(), 'Meter (m)');
    });

    test('rejects invalid identifiers and affine values', () {
      expect(
        () => UnitDefinition(id: '', name: 'Unit', symbol: 'u', scale: 1),
        throwsArgumentError,
      );
      expect(
        () => UnitDefinition(id: 'u', name: ' ', symbol: 'u', scale: 1),
        throwsArgumentError,
      );
      expect(
        () => UnitDefinition(id: 'u', name: 'Unit', symbol: '', scale: 1),
        throwsArgumentError,
      );
      expect(
        () => UnitDefinition(id: 'u', name: 'Unit', symbol: 'u', scale: 0),
        throwsArgumentError,
      );
      expect(
        () => UnitDefinition(
          id: 'u',
          name: 'Unit',
          symbol: 'u',
          scale: double.infinity,
        ),
        throwsArgumentError,
      );
      expect(
        () => UnitDefinition(
          id: 'u',
          name: 'Unit',
          symbol: 'u',
          scale: 1,
          offset: double.nan,
        ),
        throwsArgumentError,
      );
    });

    test('applies scale and offset in both directions', () {
      final unit = UnitDefinition(
        id: 'affine',
        name: 'Affine',
        symbol: 'a',
        scale: 2,
        offset: 3,
      );

      expect(unit.toBase(4), 11);
      expect(unit.fromBase(11), 4);
      expect(unit.searchTerms, <String>['affine', 'Affine', 'a']);
    });
  });

  group('UnitCategory', () {
    late UnitDefinition baseUnit;

    setUp(() {
      baseUnit = UnitDefinition(
        id: 'base',
        name: 'Base',
        symbol: 'b',
        scale: 1,
      );
    });

    test('is immutable and resolves ids case-insensitively', () {
      final category = UnitCategory(
        id: ' sample ',
        name: ' Sample ',
        aliases: const <String>[' example ', 'EXAMPLE'],
        units: <UnitDefinition>[baseUnit],
      );

      expect(category.id, 'sample');
      expect(category.name, 'Sample');
      expect(category.aliases, <String>['example']);
      expect(category.unitById(' BASE '), same(baseUnit));
      expect(category.unitById('missing'), isNull);
      expect(category.requireUnitById('base'), same(baseUnit));
      expect(() => category.requireUnitById('missing'), throwsStateError);
      expect(() => category.units.clear(), throwsUnsupportedError);
      expect(() => category.aliases.clear(), throwsUnsupportedError);
    });

    test('requires at least one unit with a unique id', () {
      expect(
        () => UnitCategory(id: 'empty', name: 'Empty', units: const []),
        throwsArgumentError,
      );
      expect(
        () => UnitCategory(
          id: 'duplicate',
          name: 'Duplicate',
          units: <UnitDefinition>[
            baseUnit,
            UnitDefinition(id: 'BASE', name: 'Other', symbol: 'o', scale: 2),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
