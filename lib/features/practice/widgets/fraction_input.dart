import 'package:flutter/material.dart';

import 'numeric_input.dart';
import 'numeric_keypad.dart';

enum _FractionPart { numerator, denominator }

class FractionInput extends StatefulWidget {
  const FractionInput({
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    this.enabled = true,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String keyPrefix;
  final bool enabled;

  @override
  State<FractionInput> createState() => _FractionInputState();
}

class _FractionInputState extends State<FractionInput> {
  _FractionPart _active = _FractionPart.numerator;

  @override
  Widget build(BuildContext context) {
    final parts = _parts(widget.value);
    final activeValue = _active == _FractionPart.numerator
        ? parts.$1
        : parts.$2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fraction answer',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ControlledDisplay(
                key: ValueKey('${widget.keyPrefix}-numerator'),
                label: 'Numerator',
                value: parts.$1,
                active: _active == _FractionPart.numerator,
                onTap: widget.enabled
                    ? () => setState(() => _active = _FractionPart.numerator)
                    : null,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '⁄',
                semanticsLabel: 'divided by',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: ControlledDisplay(
                key: ValueKey('${widget.keyPrefix}-denominator'),
                label: 'Denominator',
                value: parts.$2,
                active: _active == _FractionPart.denominator,
                onTap: widget.enabled
                    ? () => setState(() => _active = _FractionPart.denominator)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NumericKeypad(
          value: activeValue,
          onChanged: (value) {
            widget.onChanged(
              _active == _FractionPart.numerator
                  ? _compose(value, parts.$2)
                  : _compose(parts.$1, value),
            );
          },
          keyPrefix: widget.keyPrefix,
          enabled: widget.enabled,
          allowDecimal: false,
        ),
      ],
    );
  }

  static (String, String) _parts(String value) {
    final split = value.trim().split('/');
    return split.length == 2 ? (split[0].trim(), split[1].trim()) : ('', '');
  }

  static String _compose(String numerator, String denominator) {
    if (numerator.isEmpty && denominator.isEmpty) {
      return '';
    }
    return '$numerator/$denominator';
  }
}
