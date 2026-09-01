import 'package:flutter/material.dart';

import '../../models/calculator_angle_mode.dart';

class AngleModeSelector extends StatelessWidget {
  const AngleModeSelector({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final CalculatorAngleMode mode;
  final ValueChanged<CalculatorAngleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trigonometry angle mode',
      child: SegmentedButton<CalculatorAngleMode>(
        key: const ValueKey('calculator-angle-selector'),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: CalculatorAngleMode.degrees,
            label: Text('DEG'),
            tooltip: 'Degrees',
          ),
          ButtonSegment(
            value: CalculatorAngleMode.radians,
            label: Text('RAD'),
            tooltip: 'Radians',
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}
