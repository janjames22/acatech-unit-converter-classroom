import 'package:flutter/material.dart';

import '../models/module_05_content.dart';
import 'repeating_decimal_text.dart';

class DecimalExampleViewer extends StatelessWidget {
  const DecimalExampleViewer({required this.example, super.key});

  final Module5WorkedExample example;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (example.aviationContext) ...[
              Row(
                children: [
                  Icon(Icons.flight_takeoff_rounded, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Aviation example',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text(
              example.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _Step(label: 'Given', value: example.given),
            _Step(label: 'Formula', value: example.formula),
            _Step(label: 'Substitute', value: example.substitution),
            _Step(label: 'Solve', value: example.solution, emphasized: true),
            if (example.repeatingDigits case final digits?) ...[
              const SizedBox(height: 4),
              RepeatingDecimalText(
                key: const ValueKey('module5-repeating-notation'),
                whole: '0',
                nonRepeating: '',
                repeating: digits,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
            const SizedBox(height: 8),
            Text(example.explanation),
            if (example.correctionNote case final note?) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_rounded, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(note)),
                    ],
                  ),
                ),
              ),
            ],
            if (example.aviationContext) ...[
              const SizedBox(height: 14),
              Text(
                'Educational example only. Use approved maintenance data for operational decisions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidget = Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          );
          final valueWidget = Text(
            value,
            style: emphasized
                ? Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)
                : Theme.of(context).textTheme.bodyMedium,
          );
          if (constraints.maxWidth < 430) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, const SizedBox(height: 2), valueWidget],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 92, child: labelWidget),
              Expanded(child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}
