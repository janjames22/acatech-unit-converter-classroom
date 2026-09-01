import 'package:flutter/material.dart';

class ControlledUnitInput extends StatelessWidget {
  const ControlledUnitInput({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.keyPrefix,
    this.enabled = true,
    super.key,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String keyPrefix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                key: ValueKey('$keyPrefix-unit-${_id(option)}'),
                label: Text(option),
                selected: value == option,
                onSelected: enabled
                    ? (selected) => onChanged(selected ? option : '')
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  static String _id(String value) => switch (value) {
    'Ω' => 'ohm',
    _ => value.toLowerCase(),
  };
}
