import 'package:flutter/material.dart';

import 'numeric_input.dart';
import 'numeric_keypad.dart';

enum _MixedPart { whole, numerator, denominator }

class MixedNumberInput extends StatefulWidget {
  const MixedNumberInput({
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
  State<MixedNumberInput> createState() => _MixedNumberInputState();
}

class _MixedNumberInputState extends State<MixedNumberInput> {
  _MixedPart _active = _MixedPart.whole;

  @override
  Widget build(BuildContext context) {
    final parts = _parts(widget.value);
    final activeValue = switch (_active) {
      _MixedPart.whole => parts.$1,
      _MixedPart.numerator => parts.$2,
      _MixedPart.denominator => parts.$3,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Whole, fraction, or mixed-number answer',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ControlledDisplay(
                key: ValueKey('${widget.keyPrefix}-whole'),
                label: 'Whole',
                value: parts.$1,
                active: _active == _MixedPart.whole,
                onTap: widget.enabled
                    ? () => setState(() => _active = _MixedPart.whole)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ControlledDisplay(
                key: ValueKey('${widget.keyPrefix}-numerator'),
                label: 'Numerator',
                value: parts.$2,
                active: _active == _MixedPart.numerator,
                onTap: widget.enabled
                    ? () => setState(() => _active = _MixedPart.numerator)
                    : null,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                '⁄',
                semanticsLabel: 'divided by',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: ControlledDisplay(
                key: ValueKey('${widget.keyPrefix}-denominator'),
                label: 'Denominator',
                value: parts.$3,
                active: _active == _MixedPart.denominator,
                onTap: widget.enabled
                    ? () => setState(() => _active = _MixedPart.denominator)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NumericKeypad(
          value: activeValue,
          onChanged: (value) {
            final next = switch (_active) {
              _MixedPart.whole => (value, parts.$2, parts.$3),
              _MixedPart.numerator => (parts.$1, value, parts.$3),
              _MixedPart.denominator => (parts.$1, parts.$2, value),
            };
            widget.onChanged(_compose(next.$1, next.$2, next.$3));
          },
          keyPrefix: widget.keyPrefix,
          enabled: widget.enabled,
          allowDecimal: false,
        ),
      ],
    );
  }

  static (String, String, String) _parts(String value) {
    final normalized = value.trim();
    final mixed = RegExp(r'^(\d+)\s+(\d*)\s*/\s*(\d*)$').firstMatch(normalized);
    if (mixed != null) {
      return (mixed.group(1)!, mixed.group(2)!, mixed.group(3)!);
    }
    final fraction = RegExp(r'^(\d*)\s*/\s*(\d*)$').firstMatch(normalized);
    if (fraction != null) {
      return ('', fraction.group(1)!, fraction.group(2)!);
    }
    return (normalized, '', '');
  }

  static String _compose(String whole, String numerator, String denominator) {
    if (numerator.isEmpty && denominator.isEmpty) {
      return whole;
    }
    final fraction = '$numerator/$denominator';
    return whole.isEmpty ? fraction : '$whole $fraction';
  }
}
