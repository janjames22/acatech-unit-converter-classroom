import 'package:flutter/material.dart';

import 'numeric_input.dart';

class DecimalInput extends StatelessWidget {
  const DecimalInput({
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    this.enabled = true,
    this.extraKeys = const <String>[],
    this.label = 'Decimal answer',
    this.helperText,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String keyPrefix;
  final bool enabled;
  final List<String> extraKeys;
  final String label;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return NumericInput(
      value: value,
      onChanged: onChanged,
      label: label,
      keyPrefix: keyPrefix,
      enabled: enabled,
      allowDecimal: true,
      extraKeys: extraKeys,
      helperText: helperText,
    );
  }
}
