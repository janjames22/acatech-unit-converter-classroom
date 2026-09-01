final class CalculatorHistoryEntry {
  const CalculatorHistoryEntry({
    required this.expression,
    required this.result,
    required this.value,
    required this.calculatedAt,
  });

  final String expression;
  final String result;
  final double value;
  final DateTime calculatedAt;
}

final class CalculatorHistory {
  CalculatorHistory({
    Iterable<CalculatorHistoryEntry> entries = const [],
    this.maxEntries = 50,
  }) : entries = List.unmodifiable(entries) {
    if (maxEntries < 1) {
      throw ArgumentError.value(maxEntries, 'maxEntries', 'Must be positive.');
    }
    if (this.entries.length > maxEntries) {
      throw ArgumentError.value(
        this.entries.length,
        'entries',
        'Must not exceed maxEntries.',
      );
    }
  }

  final List<CalculatorHistoryEntry> entries;
  final int maxEntries;

  bool get isEmpty => entries.isEmpty;

  CalculatorHistory add(CalculatorHistoryEntry entry) {
    final updated = <CalculatorHistoryEntry>[entry, ...entries];
    return CalculatorHistory(
      entries: updated.take(maxEntries),
      maxEntries: maxEntries,
    );
  }

  CalculatorHistory clear() => CalculatorHistory(maxEntries: maxEntries);
}
