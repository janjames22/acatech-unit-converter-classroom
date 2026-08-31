import '../domain/unit_catalog.dart';
import '../models/unit_category.dart';
import '../models/unit_definition.dart';

/// The application's canonical, local-only unit catalog.
final UnitCatalog builtInUnitCatalog = UnitCatalog(<UnitCategory>[
  UnitCategory(
    id: 'length',
    name: 'Length',
    aliases: const <String>['distance'],
    units: <UnitDefinition>[
      _unit('meter', 'Meter', 'm', 1, <String>['meters', 'metre', 'metres']),
      _unit('kilometer', 'Kilometer', 'km', 1000, <String>[
        'kilometers',
        'kilometre',
        'kilometres',
      ]),
      _unit('centimeter', 'Centimeter', 'cm', 0.01, <String>[
        'centimeters',
        'centimetre',
        'centimetres',
      ]),
      _unit('millimeter', 'Millimeter', 'mm', 0.001, <String>[
        'millimeters',
        'millimetre',
        'millimetres',
      ]),
      _unit('micrometer', 'Micrometer', 'µm', 1e-6, <String>[
        'micrometers',
        'micrometre',
        'micron',
        'um',
      ]),
      _unit('nanometer', 'Nanometer', 'nm', 1e-9, <String>[
        'nanometers',
        'nanometre',
      ]),
      _unit('mile', 'Mile', 'mi', 1609.344, <String>['miles']),
      _unit('yard', 'Yard', 'yd', 0.9144, <String>['yards']),
      _unit('foot', 'Foot', 'ft', 0.3048, <String>['feet']),
      _unit('inch', 'Inch', 'in', 0.0254, <String>['inches']),
      _unit('nautical_mile', 'Nautical mile', 'nmi', 1852, <String>[
        'nautical miles',
      ]),
    ],
  ),
  UnitCategory(
    id: 'area',
    name: 'Area',
    aliases: const <String>['surface'],
    units: <UnitDefinition>[
      _unit('square_meter', 'Square meter', 'm²', 1, <String>[
        'square meters',
        'square metre',
        'sqm',
        'm2',
      ]),
      _unit('square_kilometer', 'Square kilometer', 'km²', 1e6, <String>[
        'square kilometers',
        'square kilometre',
        'sq km',
        'km2',
      ]),
      _unit('square_centimeter', 'Square centimeter', 'cm²', 1e-4, <String>[
        'square centimeters',
        'square centimetre',
        'sq cm',
        'cm2',
      ]),
      _unit('square_millimeter', 'Square millimeter', 'mm²', 1e-6, <String>[
        'square millimeters',
        'square millimetre',
        'sq mm',
        'mm2',
      ]),
      _unit('hectare', 'Hectare', 'ha', 10000, <String>['hectares']),
      _unit('acre', 'Acre', 'ac', 4046.8564224, <String>['acres']),
      _unit('square_mile', 'Square mile', 'mi²', 2589988.110336, <String>[
        'square miles',
        'sq mi',
        'mi2',
      ]),
      _unit('square_yard', 'Square yard', 'yd²', 0.83612736, <String>[
        'square yards',
        'sq yd',
        'yd2',
      ]),
      _unit('square_foot', 'Square foot', 'ft²', 0.09290304, <String>[
        'square feet',
        'sq ft',
        'ft2',
      ]),
      _unit('square_inch', 'Square inch', 'in²', 0.00064516, <String>[
        'square inches',
        'sq in',
        'in2',
      ]),
    ],
  ),
  UnitCategory(
    id: 'mass',
    name: 'Mass',
    aliases: const <String>['weight'],
    units: <UnitDefinition>[
      _unit('kilogram', 'Kilogram', 'kg', 1, <String>['kilograms', 'kilo']),
      _unit('gram', 'Gram', 'g', 0.001, <String>['grams']),
      _unit('milligram', 'Milligram', 'mg', 1e-6, <String>['milligrams']),
      _unit('microgram', 'Microgram', 'µg', 1e-9, <String>[
        'micrograms',
        'mcg',
        'ug',
      ]),
      _unit('metric_tonne', 'Metric tonne', 't', 1000, <String>[
        'metric ton',
        'tonne',
        'tonnes',
      ]),
      _unit('pound', 'Pound', 'lb', 0.45359237, <String>['pounds', 'lbs']),
      _unit('ounce', 'Ounce', 'oz', 0.028349523125, <String>['ounces']),
      _unit('stone', 'Stone', 'st', 6.35029318, <String>['stones']),
      _unit('short_ton', 'US short ton', 'US ton', 907.18474, <String>[
        'short ton',
        'short tons',
      ]),
    ],
  ),
  UnitCategory(
    id: 'temperature',
    name: 'Temperature',
    aliases: const <String>['temp', 'heat'],
    units: <UnitDefinition>[
      _unit('celsius', 'Celsius', '°C', 1, <String>[
        'centigrade',
        'degree celsius',
        'degrees celsius',
        'c',
      ]),
      _unit('fahrenheit', 'Fahrenheit', '°F', 5 / 9, <String>[
        'degree fahrenheit',
        'degrees fahrenheit',
        'f',
      ], offset: -160 / 9),
      _unit('kelvin', 'Kelvin', 'K', 1, <String>[
        'kelvins',
        'degree kelvin',
      ], offset: -273.15),
      _unit('rankine', 'Rankine', '°R', 5 / 9, <String>[
        'degree rankine',
        'degrees rankine',
      ], offset: -273.15),
    ],
  ),
  UnitCategory(
    id: 'speed',
    name: 'Speed',
    aliases: const <String>['velocity', 'pace'],
    units: <UnitDefinition>[
      _unit('meter_per_second', 'Meter per second', 'm/s', 1, <String>[
        'meters per second',
        'metres per second',
        'mps',
      ]),
      _unit(
        'kilometer_per_hour',
        'Kilometer per hour',
        'km/h',
        1 / 3.6,
        <String>['kilometers per hour', 'kilometres per hour', 'kph', 'kmph'],
      ),
      _unit('mile_per_hour', 'Mile per hour', 'mph', 0.44704, <String>[
        'miles per hour',
      ]),
      _unit('foot_per_second', 'Foot per second', 'ft/s', 0.3048, <String>[
        'feet per second',
        'fps',
      ]),
      _unit('knot', 'Knot', 'kn', 1852 / 3600, <String>[
        'knots',
        'nautical mile per hour',
      ]),
      _unit(
        'centimeter_per_second',
        'Centimeter per second',
        'cm/s',
        0.01,
        <String>['centimeters per second', 'centimetres per second'],
      ),
    ],
  ),
  UnitCategory(
    id: 'volume',
    name: 'Volume',
    aliases: const <String>['capacity', 'liquid'],
    units: <UnitDefinition>[
      _unit('liter', 'Liter', 'L', 1, <String>['liters', 'litre', 'litres']),
      _unit('milliliter', 'Milliliter', 'mL', 0.001, <String>[
        'milliliters',
        'millilitre',
        'millilitres',
      ]),
      _unit('cubic_meter', 'Cubic meter', 'm³', 1000, <String>[
        'cubic meters',
        'cubic metre',
        'm3',
      ]),
      _unit('cubic_centimeter', 'Cubic centimeter', 'cm³', 0.001, <String>[
        'cubic centimeters',
        'cubic centimetre',
        'cc',
        'cm3',
      ]),
      _unit('cubic_inch', 'Cubic inch', 'in³', 0.016387064, <String>[
        'cubic inches',
        'cu in',
        'in3',
      ]),
      _unit('cubic_foot', 'Cubic foot', 'ft³', 28.316846592, <String>[
        'cubic feet',
        'cu ft',
        'ft3',
      ]),
      _unit('us_gallon', 'US gallon', 'US gal', 3.785411784, <String>[
        'us gallons',
        'gallon',
        'gallons',
      ]),
      _unit('imperial_gallon', 'Imperial gallon', 'imp gal', 4.54609, <String>[
        'imperial gallons',
        'uk gallon',
      ]),
      _unit('us_quart', 'US quart', 'US qt', 0.946352946, <String>[
        'us quarts',
        'quart',
        'quarts',
      ]),
      _unit('us_pint', 'US pint', 'US pt', 0.473176473, <String>[
        'us pints',
        'pint',
        'pints',
      ]),
      _unit('us_cup', 'US cup', 'cup', 0.2365882365, <String>['cups']),
      _unit(
        'us_fluid_ounce',
        'US fluid ounce',
        'US fl oz',
        0.0295735295625,
        <String>['fluid ounce', 'fluid ounces', 'fl oz'],
      ),
      _unit(
        'us_tablespoon',
        'US tablespoon',
        'tbsp',
        0.01478676478125,
        <String>['tablespoon', 'tablespoons'],
      ),
      _unit('us_teaspoon', 'US teaspoon', 'tsp', 0.00492892159375, <String>[
        'teaspoon',
        'teaspoons',
      ]),
    ],
  ),
  UnitCategory(
    id: 'time',
    name: 'Time',
    aliases: const <String>['duration'],
    units: <UnitDefinition>[
      _unit('second', 'Second', 's', 1, <String>['seconds', 'sec']),
      _unit('millisecond', 'Millisecond', 'ms', 0.001, <String>[
        'milliseconds',
      ]),
      _unit('microsecond', 'Microsecond', 'µs', 1e-6, <String>[
        'microseconds',
        'us',
      ]),
      _unit('nanosecond', 'Nanosecond', 'ns', 1e-9, <String>['nanoseconds']),
      _unit('minute', 'Minute', 'min', 60, <String>['minutes', 'mins']),
      _unit('hour', 'Hour', 'h', 3600, <String>['hours', 'hr', 'hrs']),
      _unit('day', 'Day', 'd', 86400, <String>['days']),
      _unit('week', 'Week', 'wk', 604800, <String>['weeks', 'wks']),
      _unit('month', 'Average Gregorian month', 'mo', 2629746, <String>[
        'month',
        'months',
        'average month',
      ]),
      _unit('year', 'Average Gregorian year', 'yr', 31556952, <String>[
        'year',
        'years',
        'average year',
      ]),
    ],
  ),
  UnitCategory(
    id: 'digital_storage',
    name: 'Digital storage',
    aliases: const <String>['data', 'file size', 'memory', 'storage'],
    units: <UnitDefinition>[
      _unit('byte', 'Byte', 'B', 1, <String>['bytes', 'octet']),
      _unit('bit', 'Bit', 'bit', 0.125, <String>['bits']),
      _unit('kilobyte', 'Kilobyte', 'kB', 1e3, <String>[
        'kilobytes',
        'decimal kilobyte',
      ]),
      _unit('megabyte', 'Megabyte', 'MB', 1e6, <String>[
        'megabytes',
        'decimal megabyte',
      ]),
      _unit('gigabyte', 'Gigabyte', 'GB', 1e9, <String>[
        'gigabytes',
        'decimal gigabyte',
      ]),
      _unit('terabyte', 'Terabyte', 'TB', 1e12, <String>[
        'terabytes',
        'decimal terabyte',
      ]),
      _unit('petabyte', 'Petabyte', 'PB', 1e15, <String>[
        'petabytes',
        'decimal petabyte',
      ]),
      _unit('kibibyte', 'Kibibyte', 'KiB', 1024, <String>[
        'kibibytes',
        'binary kilobyte',
      ]),
      _unit('mebibyte', 'Mebibyte', 'MiB', 1048576, <String>[
        'mebibytes',
        'binary megabyte',
      ]),
      _unit('gibibyte', 'Gibibyte', 'GiB', 1073741824, <String>[
        'gibibytes',
        'binary gigabyte',
      ]),
      _unit('tebibyte', 'Tebibyte', 'TiB', 1099511627776, <String>[
        'tebibytes',
        'binary terabyte',
      ]),
      _unit('pebibyte', 'Pebibyte', 'PiB', 1125899906842624, <String>[
        'pebibytes',
        'binary petabyte',
      ]),
    ],
  ),
  UnitCategory(
    id: 'pressure',
    name: 'Pressure',
    aliases: const <String>['stress'],
    units: <UnitDefinition>[
      _unit('pascal', 'Pascal', 'Pa', 1, <String>['pascals']),
      _unit('kilopascal', 'Kilopascal', 'kPa', 1000, <String>['kilopascals']),
      _unit('megapascal', 'Megapascal', 'MPa', 1e6, <String>['megapascals']),
      _unit('bar', 'Bar', 'bar', 100000, <String>['bars']),
      _unit('millibar', 'Millibar', 'mbar', 100, <String>['millibars']),
      _unit('atmosphere', 'Standard atmosphere', 'atm', 101325, <String>[
        'atmospheres',
        'standard atmosphere',
      ]),
      _unit('torr', 'Torr', 'Torr', 101325 / 760, <String>['torrs']),
      _unit('psi', 'Pound per square inch', 'psi', 6894.757293168, <String>[
        'pounds per square inch',
      ]),
      _unit(
        'millimeter_of_mercury',
        'Millimeter of mercury',
        'mmHg',
        133.322387415,
        <String>['millimeters of mercury', 'mm hg'],
      ),
      _unit('inch_of_mercury', 'Inch of mercury', 'inHg', 3386.389, <String>[
        'inches of mercury',
        'in hg',
      ]),
    ],
  ),
]);

/// Static access for call sites that prefer a named catalog namespace.
abstract final class BuiltInUnitCatalog {
  static UnitCatalog get instance => builtInUnitCatalog;
  static List<UnitCategory> get categories => instance.categories;
}

UnitDefinition _unit(
  String id,
  String name,
  String symbol,
  double scale,
  List<String> aliases, {
  double offset = 0,
}) {
  return UnitDefinition(
    id: id,
    name: name,
    symbol: symbol,
    scale: scale,
    offset: offset,
    aliases: aliases,
  );
}
