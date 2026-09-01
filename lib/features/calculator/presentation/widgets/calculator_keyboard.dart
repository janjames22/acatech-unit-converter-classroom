import 'package:flutter/material.dart';

import '../../application/calculator_controller.dart';

enum CalculatorKeyEmphasis { standard, secondary, operator, equals }

class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({required this.controller, super.key});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final keys = <_CalculatorKeyData>[
      _CalculatorKeyData(
        'AC',
        'Clear calculator',
        controller.clear,
        keyName: 'clear',
        emphasis: CalculatorKeyEmphasis.secondary,
      ),
      _CalculatorKeyData(
        '⌫',
        'Delete last character',
        controller.backspace,
        keyName: 'backspace',
        emphasis: CalculatorKeyEmphasis.secondary,
      ),
      _CalculatorKeyData(
        '(',
        'Open parenthesis',
        () => controller.inputParenthesis('('),
        keyName: 'open-parenthesis',
        emphasis: CalculatorKeyEmphasis.secondary,
      ),
      _CalculatorKeyData(
        ')',
        'Close parenthesis',
        () => controller.inputParenthesis(')'),
        keyName: 'close-parenthesis',
        emphasis: CalculatorKeyEmphasis.secondary,
      ),
      _CalculatorKeyData(
        '7',
        'Digit 7',
        () => controller.inputDigit('7'),
        keyName: 'digit-7',
      ),
      _CalculatorKeyData(
        '8',
        'Digit 8',
        () => controller.inputDigit('8'),
        keyName: 'digit-8',
      ),
      _CalculatorKeyData(
        '9',
        'Digit 9',
        () => controller.inputDigit('9'),
        keyName: 'digit-9',
      ),
      _CalculatorKeyData(
        '÷',
        'Divide',
        () => controller.inputOperator('÷'),
        keyName: 'divide',
        emphasis: CalculatorKeyEmphasis.operator,
      ),
      _CalculatorKeyData(
        '4',
        'Digit 4',
        () => controller.inputDigit('4'),
        keyName: 'digit-4',
      ),
      _CalculatorKeyData(
        '5',
        'Digit 5',
        () => controller.inputDigit('5'),
        keyName: 'digit-5',
      ),
      _CalculatorKeyData(
        '6',
        'Digit 6',
        () => controller.inputDigit('6'),
        keyName: 'digit-6',
      ),
      _CalculatorKeyData(
        '×',
        'Multiply',
        () => controller.inputOperator('×'),
        keyName: 'multiply',
        emphasis: CalculatorKeyEmphasis.operator,
      ),
      _CalculatorKeyData(
        '1',
        'Digit 1',
        () => controller.inputDigit('1'),
        keyName: 'digit-1',
      ),
      _CalculatorKeyData(
        '2',
        'Digit 2',
        () => controller.inputDigit('2'),
        keyName: 'digit-2',
      ),
      _CalculatorKeyData(
        '3',
        'Digit 3',
        () => controller.inputDigit('3'),
        keyName: 'digit-3',
      ),
      _CalculatorKeyData(
        '−',
        'Subtract',
        () => controller.inputOperator('−'),
        keyName: 'subtract',
        emphasis: CalculatorKeyEmphasis.operator,
      ),
      _CalculatorKeyData(
        '0',
        'Digit 0',
        () => controller.inputDigit('0'),
        keyName: 'digit-0',
      ),
      _CalculatorKeyData(
        '.',
        'Decimal point',
        controller.inputDecimal,
        keyName: 'decimal',
      ),
      _CalculatorKeyData(
        '=',
        'Calculate result',
        controller.evaluate,
        keyName: 'equals',
        emphasis: CalculatorKeyEmphasis.equals,
      ),
      _CalculatorKeyData(
        '+',
        'Add',
        () => controller.inputOperator('+'),
        keyName: 'add',
        emphasis: CalculatorKeyEmphasis.operator,
      ),
    ];

    return GridView.builder(
      key: const ValueKey('calculator-keyboard'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 58,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final data = keys[index];
        return CalculatorKeyButton(
          key: ValueKey('calculator-key-${data.keyName}'),
          label: data.label,
          semanticLabel: data.semanticLabel,
          emphasis: data.emphasis,
          onPressed: data.onPressed,
        );
      },
    );
  }
}

class CalculatorKeyButton extends StatelessWidget {
  const CalculatorKeyButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.emphasis = CalculatorKeyEmphasis.standard,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final CalculatorKeyEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style =
        switch (emphasis) {
          CalculatorKeyEmphasis.standard => OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            backgroundColor: colorScheme.surfaceContainerLowest,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          CalculatorKeyEmphasis.secondary => FilledButton.styleFrom(
            foregroundColor: colorScheme.onSecondaryContainer,
            backgroundColor: colorScheme.secondaryContainer,
          ),
          CalculatorKeyEmphasis.operator => FilledButton.styleFrom(
            foregroundColor: colorScheme.onPrimaryContainer,
            backgroundColor: colorScheme.primaryContainer,
          ),
          CalculatorKeyEmphasis.equals => FilledButton.styleFrom(
            foregroundColor: colorScheme.onPrimary,
            backgroundColor: colorScheme.primary,
          ),
        }.copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: WidgetStatePropertyAll(
            Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: FilledButton(
          style: style,
          onPressed: onPressed,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}

final class _CalculatorKeyData {
  const _CalculatorKeyData(
    this.label,
    this.semanticLabel,
    this.onPressed, {
    required this.keyName,
    this.emphasis = CalculatorKeyEmphasis.standard,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final String keyName;
  final CalculatorKeyEmphasis emphasis;
}
