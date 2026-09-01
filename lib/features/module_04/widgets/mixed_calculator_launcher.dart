import 'package:flutter/material.dart';

class MixedCalculatorLauncher extends StatelessWidget {
  const MixedCalculatorLauncher({required this.onOpenCalculator, super.key});

  final VoidCallback onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      key: const ValueKey('module4-open-calculator'),
      onPressed: onOpenCalculator,
      icon: const Icon(Icons.calculate_outlined),
      label: const Text('Open calculator'),
    );
  }
}
