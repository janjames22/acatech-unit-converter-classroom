import 'package:flutter/material.dart';

import '../../models/calculator_history.dart';

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    required this.history,
    required this.onReuse,
    required this.onClear,
    this.embedded = false,
    super.key,
  });

  final CalculatorHistory history;
  final ValueChanged<CalculatorHistoryEntry> onReuse;
  final VoidCallback onClear;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Calculations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Stored on this device for this app session.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('calculator-clear-history'),
                tooltip: 'Clear calculation history',
                onPressed: history.isEmpty ? null : onClear,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: history.isEmpty
              ? const _EmptyHistory()
              : ListView.separated(
                  key: const ValueKey('calculator-history-list'),
                  padding: const EdgeInsets.all(12),
                  itemCount: history.entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = history.entries[index];
                    return _HistoryTile(
                      entry: entry,
                      onTap: () => onReuse(entry),
                    );
                  },
                ),
        ),
      ],
    );

    if (embedded) {
      return Card(
        key: const ValueKey('calculator-history-panel'),
        child: content,
      );
    }
    return Material(
      key: const ValueKey('calculator-history-panel'),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(top: false, child: content),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onTap});

  final CalculatorHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.expression,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '= ${entry.result}',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No calculations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Successful results will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
