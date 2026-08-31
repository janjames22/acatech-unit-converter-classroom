import '../models/unit_definition.dart';

/// Stateless affine conversion between units in the same category.
abstract final class ConversionEngine {
  /// Converts [value] from [from] into [to].
  ///
  /// Callers are responsible for choosing units from the same category. The
  /// engine intentionally has no catalog dependency, which keeps conversion
  /// deterministic and easy to test.
  static double convert({
    required double value,
    required UnitDefinition from,
    required UnitDefinition to,
  }) {
    return to.fromBase(from.toBase(value));
  }
}
