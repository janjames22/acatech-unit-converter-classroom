import 'package:flutter/material.dart';

import '../../application/calculator_controller.dart';
import 'calculator_keyboard.dart';

class ScientificButtons extends StatelessWidget {
  const ScientificButtons({required this.controller, super.key});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final keys = <_ScientificKeyData>[
      _ScientificKeyData(
        '√',
        'Square root',
        () => controller.inputFunction('sqrt'),
        'sqrt',
      ),
      _ScientificKeyData('x²', 'Square', controller.inputSquare, 'square'),
      _ScientificKeyData(
        'xʸ',
        'Power',
        () => controller.inputOperator('^'),
        'power',
      ),
      _ScientificKeyData(
        '1/x',
        'Reciprocal',
        () => controller.inputFunction('recip'),
        'reciprocal',
      ),
      _ScientificKeyData(
        'sin',
        'Sine',
        () => controller.inputFunction('sin'),
        'sin',
      ),
      _ScientificKeyData(
        'cos',
        'Cosine',
        () => controller.inputFunction('cos'),
        'cos',
      ),
      _ScientificKeyData(
        'tan',
        'Tangent',
        () => controller.inputFunction('tan'),
        'tan',
      ),
      _ScientificKeyData(
        'exp',
        'Exponential',
        () => controller.inputFunction('exp'),
        'exp',
      ),
      _ScientificKeyData(
        'log',
        'Base 10 logarithm',
        () => controller.inputFunction('log'),
        'log',
      ),
      _ScientificKeyData(
        'ln',
        'Natural logarithm',
        () => controller.inputFunction('ln'),
        'ln',
      ),
      _ScientificKeyData(
        'π',
        'Pi constant',
        () => controller.inputConstant('π'),
        'pi',
      ),
      _ScientificKeyData(
        'e',
        'Euler constant',
        () => controller.inputConstant('e'),
        'e',
      ),
      _ScientificKeyData('%', 'Percent', controller.inputPercent, 'percent'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Scientific',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          key: const ValueKey('calculator-scientific-buttons'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 52,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final data = keys[index];
            return CalculatorKeyButton(
              key: ValueKey('calculator-key-${data.keyName}'),
              label: data.label,
              semanticLabel: data.semanticLabel,
              onPressed: data.onPressed,
            );
          },
        ),
      ],
    );
  }
}

final class _ScientificKeyData {
  const _ScientificKeyData(
    this.label,
    this.semanticLabel,
    this.onPressed,
    this.keyName,
  );

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final String keyName;
}
