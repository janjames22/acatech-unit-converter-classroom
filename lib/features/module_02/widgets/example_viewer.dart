import 'package:flutter/material.dart';

import '../models/module_02_content.dart';
import 'aviation_example_card.dart';

class ExampleViewer extends StatelessWidget {
  const ExampleViewer({required this.example, super.key});

  final Module2WorkedExample example;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 8),
        Text(example.explanation),
      ],
    );
    if (example.aviationContext) {
      return AviationExampleCard(child: content);
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: content),
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
          final narrow = constraints.maxWidth < 430;
          final labelWidget = Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          );
          final value = Text(
            this.value,
            style: emphasized
                ? Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)
                : Theme.of(context).textTheme.bodyMedium,
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, const SizedBox(height: 2), value],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 92, child: labelWidget),
              Expanded(child: value),
            ],
          );
        },
      ),
    );
  }
}
