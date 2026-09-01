import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/mixed_number_models.dart';
import '../services/mixed_number_engine.dart';

enum MixedLabOperation { add, subtract, multiply, divide }

class MixedNumberLab extends StatefulWidget {
  const MixedNumberLab({this.engine = const MixedNumberEngine(), super.key});

  final MixedNumberEngine engine;

  @override
  State<MixedNumberLab> createState() => _MixedNumberLabState();
}

class _MixedNumberLabState extends State<MixedNumberLab> {
  final _leftWhole = TextEditingController(text: '3');
  final _leftNumerator = TextEditingController(text: '1');
  final _leftDenominator = TextEditingController(text: '8');
  final _rightWhole = TextEditingController(text: '1');
  final _rightNumerator = TextEditingController(text: '5');
  final _rightDenominator = TextEditingController(text: '16');
  MixedLabOperation _operation = MixedLabOperation.subtract;
  String? _result;
  String? _details;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _leftWhole,
      _leftNumerator,
      _leftDenominator,
      _rightWhole,
      _rightNumerator,
      _rightDenominator,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('module4-mixed-lab'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mixed-number lab',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Build two mixed numbers and inspect improper conversion, carrying, borrowing, and the reduced result.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final left = _MixedFields(
                  label: 'First mixed number',
                  whole: _leftWhole,
                  numerator: _leftNumerator,
                  denominator: _leftDenominator,
                  keyPrefix: 'module4-lab-left',
                );
                final right = _MixedFields(
                  label: 'Second mixed number',
                  whole: _rightWhole,
                  numerator: _rightNumerator,
                  denominator: _rightDenominator,
                  keyPrefix: 'module4-lab-right',
                );
                if (constraints.maxWidth < 720) {
                  return Column(
                    children: [left, const SizedBox(height: 14), right],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 20),
                    Expanded(child: right),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<MixedLabOperation>(
              key: const ValueKey('module4-lab-operation'),
              initialValue: _operation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Operation'),
              items: [
                for (final operation in MixedLabOperation.values)
                  DropdownMenuItem(
                    value: operation,
                    child: Text(_operationLabel(operation)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _operation = value);
                }
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const ValueKey('module4-lab-explore'),
              onPressed: _explore,
              icon: const Icon(Icons.functions_rounded),
              label: const Text('Explore mixed numbers'),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 14),
              Text(
                error,
                key: const ValueKey('module4-lab-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 18),
              SelectableText(
                result,
                key: const ValueKey('module4-lab-result'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(_details!),
            ],
          ],
        ),
      ),
    );
  }

  void _explore() {
    final values = [
      int.tryParse(_leftWhole.text),
      int.tryParse(_leftNumerator.text),
      int.tryParse(_leftDenominator.text),
      int.tryParse(_rightWhole.text),
      int.tryParse(_rightNumerator.text),
      int.tryParse(_rightDenominator.text),
    ];
    if (values.any((value) => value == null)) {
      setState(() {
        _error =
            'Enter a whole number, numerator, and denominator for both values.';
        _result = null;
      });
      return;
    }
    try {
      final left = widget.engine.create(values[0]!, values[1]!, values[2]!);
      final right = widget.engine.create(values[3]!, values[4]!, values[5]!);
      final result = switch (_operation) {
        MixedLabOperation.add => widget.engine.add(left, right),
        MixedLabOperation.subtract => widget.engine.subtract(left, right),
        MixedLabOperation.multiply => widget.engine.multiply(left, right),
        MixedLabOperation.divide => widget.engine.divide(left, right),
      };
      final evidence = <String>[
        '${left.text} = ${result.leftImproper.fractionText}',
        '${right.text} = ${result.rightImproper.fractionText}',
        if (result.carryStep case final carry?) carry.explanation,
        if (result.borrowStep case final borrow?) borrow.explanation,
        'Exact improper result ${result.exactResult.fractionText}; reduced mixed result ${result.value.text}.',
      ];
      setState(() {
        _result = '${_operationLabel(_operation)} result: ${result.value.text}';
        _details = evidence.join(' ');
        _error = null;
      });
    } on Object catch (error) {
      final message = switch (error) {
        final MixedNumberException value => value.message,
        _ => error.toString(),
      };
      setState(() {
        _error = message;
        _result = null;
      });
    }
  }

  static String _operationLabel(MixedLabOperation operation) =>
      switch (operation) {
        MixedLabOperation.add => 'Addition',
        MixedLabOperation.subtract => 'Subtraction',
        MixedLabOperation.multiply => 'Multiplication',
        MixedLabOperation.divide => 'Division',
      };
}

class _MixedFields extends StatelessWidget {
  const _MixedFields({
    required this.label,
    required this.whole,
    required this.numerator,
    required this.denominator,
    required this.keyPrefix,
  });

  final String label;
  final TextEditingController whole;
  final TextEditingController numerator;
  final TextEditingController denominator;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label with whole, numerator, and denominator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = <Widget>[
                _NumberField(
                  key: ValueKey('$keyPrefix-whole'),
                  controller: whole,
                  label: 'Whole',
                ),
                _NumberField(
                  key: ValueKey('$keyPrefix-numerator'),
                  controller: numerator,
                  label: 'Numerator',
                ),
                _NumberField(
                  key: ValueKey('$keyPrefix-denominator'),
                  controller: denominator,
                  label: 'Denominator',
                ),
              ];
              if (constraints.maxWidth < 360) {
                return Column(
                  children: [
                    for (var index = 0; index < fields.length; index++) ...[
                      fields[index],
                      if (index < fields.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var index = 0; index < fields.length; index++) ...[
                    Expanded(child: fields[index]),
                    if (index < fields.length - 1) const SizedBox(width: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    super.key,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
    );
  }
}
