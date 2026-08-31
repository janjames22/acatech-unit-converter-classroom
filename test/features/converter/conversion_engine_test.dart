import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/converter/converter.dart';

void main() {
  UnitDefinition unit(String categoryId, String unitId) {
    return builtInUnitCatalog
        .requireCategoryById(categoryId)
        .requireUnitById(unitId);
  }

  double convert(double value, String categoryId, String fromId, String toId) {
    return ConversionEngine.convert(
      value: value,
      from: unit(categoryId, fromId),
      to: unit(categoryId, toId),
    );
  }

  group('ConversionEngine', () {
    test('converts representative linear units', () {
      expect(convert(1, 'length', 'kilometer', 'meter'), 1000);
      expect(
        convert(1, 'length', 'mile', 'kilometer'),
        closeTo(1.609344, 1e-12),
      );
      expect(
        convert(1, 'area', 'acre', 'square_meter'),
        closeTo(4046.8564224, 1e-9),
      );
      expect(
        convert(1, 'mass', 'pound', 'kilogram'),
        closeTo(0.45359237, 1e-12),
      );
      expect(
        convert(36, 'speed', 'kilometer_per_hour', 'meter_per_second'),
        10,
      );
      expect(
        convert(1, 'volume', 'us_gallon', 'liter'),
        closeTo(3.785411784, 1e-12),
      );
      expect(convert(1, 'time', 'day', 'hour'), 24);
      expect(convert(1, 'digital_storage', 'kibibyte', 'byte'), 1024);
      expect(convert(1, 'digital_storage', 'byte', 'bit'), 8);
      expect(convert(1, 'pressure', 'atmosphere', 'pascal'), 101325);
    });

    test('handles affine temperature conversions', () {
      expect(convert(0, 'temperature', 'celsius', 'fahrenheit'), 32);
      expect(
        convert(100, 'temperature', 'celsius', 'fahrenheit'),
        closeTo(212, 1e-12),
      );
      expect(convert(212, 'temperature', 'fahrenheit', 'celsius'), 100);
      expect(
        convert(273.15, 'temperature', 'kelvin', 'celsius'),
        closeTo(0, 1e-12),
      );
      expect(
        convert(491.67, 'temperature', 'rankine', 'fahrenheit'),
        closeTo(32, 1e-10),
      );
    });

    test('identity conversions preserve a value', () {
      final meter = unit('length', 'meter');
      expect(
        ConversionEngine.convert(value: -123.456, from: meter, to: meter),
        -123.456,
      );
    });

    test('every catalog unit round-trips through its category base unit', () {
      const samples = <double>[-123.456, 0, 0.125, 987654.321];

      for (final category in builtInUnitCatalog.categories) {
        final base = category.units.first;
        for (final candidate in category.units) {
          for (final sample in samples) {
            final baseValue = ConversionEngine.convert(
              value: sample,
              from: candidate,
              to: base,
            );
            final result = ConversionEngine.convert(
              value: baseValue,
              from: base,
              to: candidate,
            );
            final tolerance = math.max(1e-9, sample.abs() * 1e-11);
            expect(
              result,
              closeTo(sample, tolerance),
              reason: '${category.id}/${candidate.id} failed for $sample',
            );
          }
        }
      }
    });
  });
}
