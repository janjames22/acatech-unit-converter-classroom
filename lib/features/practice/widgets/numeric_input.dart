import 'package:flutter/material.dart';

import 'numeric_keypad.dart';

class NumericInput extends StatelessWidget {
  const NumericInput({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.keyPrefix,
    this.enabled = true,
    this.allowDecimal = false,
    this.extraKeys = const <String>[],
    this.suffix,
    this.helperText,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final String keyPrefix;
  final bool enabled;
  final bool allowDecimal;
  final List<String> extraKeys;
  final String? suffix;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ControlledDisplay(
          value: value,
          label: label,
          suffix: suffix,
          helperText: helperText,
        ),
        const SizedBox(height: 12),
        NumericKeypad(
          value: value,
          onChanged: onChanged,
          keyPrefix: keyPrefix,
          enabled: enabled,
          allowDecimal: allowDecimal,
          extraKeys: extraKeys,
        ),
      ],
    );
  }
}

class ControlledDisplay extends StatelessWidget {
  const ControlledDisplay({
    required this.value,
    required this.label,
    this.active = false,
    this.onTap,
    super.key,
  });

  final String value;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label, ${value.isEmpty ? 'empty' : value}',
      readOnly: true,
      button: onTap != null,
      child: Material(
        color: active ? colors.primaryContainer : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: active ? colors.primary : colors.outlineVariant,
            width: active ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '—' : value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlledDisplay extends StatelessWidget {
  const _ControlledDisplay({
    required this.value,
    required this.label,
    this.suffix,
    this.helperText,
  });

  final String value;
  final String label;
  final String? suffix;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: value.isEmpty,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        helperText: helperText,
      ),
      child: Semantics(
        readOnly: true,
        label: '$label answer, ${value.isEmpty ? 'empty' : value}',
        child: Text(
          value.isEmpty ? 'Use the keypad below' : value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
