import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/fraction_models.dart';
import '../services/fraction_engine.dart';

enum FractionLabOperation { add, subtract, multiply, divide, compare }

class FractionLab extends StatefulWidget {
  const FractionLab({this.engine = const FractionEngine(), super.key});

  final FractionEngine engine;

  @override
  State<FractionLab> createState() => _FractionLabState();
}

class _FractionLabState extends State<FractionLab> {
  final _leftNumerator = TextEditingController(text: '3');
  final _leftDenominator = TextEditingController(text: '32');
  final _rightNumerator = TextEditingController(text: '1');
  final _rightDenominator = TextEditingController(text: '64');
  FractionLabOperation _operation = FractionLabOperation.add;
  CommonDenominatorMethod _method = CommonDenominatorMethod.leastCommonMultiple;
  String? _result;
  String? _details;
  String? _error;

  @override
  void dispose() {
    _leftNumerator.dispose();
    _leftDenominator.dispose();
    _rightNumerator.dispose();
    _rightDenominator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('module3-fraction-lab'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exact fraction lab',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Build two fractions, choose an operation, and inspect exact equivalents and reduction.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final left = _FractionFields(
                  label: 'First fraction',
                  numerator: _leftNumerator,
                  denominator: _leftDenominator,
                  keyPrefix: 'module3-lab-left',
                );
                final right = _FractionFields(
                  label: 'Second fraction',
                  numerator: _rightNumerator,
                  denominator: _rightDenominator,
                  keyPrefix: 'module3-lab-right',
                );
                if (constraints.maxWidth < 700) {
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
            LayoutBuilder(
              builder: (context, constraints) {
                final operation = DropdownButtonFormField<FractionLabOperation>(
                  key: const ValueKey('module3-lab-operation'),
                  initialValue: _operation,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Operation'),
                  items: [
                    for (final value in FractionLabOperation.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_operationLabel(value)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _operation = value);
                    }
                  },
                );
                final method = DropdownButtonFormField<CommonDenominatorMethod>(
                  key: const ValueKey('module3-lab-lcd-method'),
                  initialValue: _method,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'LCD method'),
                  items: const [
                    DropdownMenuItem(
                      value: CommonDenominatorMethod.leastCommonMultiple,
                      child: Text('Least shared multiple'),
                    ),
                    DropdownMenuItem(
                      value: CommonDenominatorMethod.productOfDenominators,
                      child: Text('Product of denominators'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _method = value);
                    }
                  },
                );
                if (constraints.maxWidth < 620) {
                  return Column(
                    children: [operation, const SizedBox(height: 12), method],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: operation),
                    const SizedBox(width: 12),
                    Expanded(child: method),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const ValueKey('module3-lab-explore'),
              onPressed: _explore,
              icon: const Icon(Icons.functions_rounded),
              label: const Text('Explore fractions'),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 14),
              Text(
                error,
                key: const ValueKey('module3-lab-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 18),
              SelectableText(
                result,
                key: const ValueKey('module3-lab-result'),
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
      int.tryParse(_leftNumerator.text),
      int.tryParse(_leftDenominator.text),
      int.tryParse(_rightNumerator.text),
      int.tryParse(_rightDenominator.text),
    ];
    if (values.any((value) => value == null)) {
      setState(() {
        _error = 'Enter an integer in every numerator and denominator field.';
        _result = null;
      });
      return;
    }
    try {
      final left = widget.engine.create(values[0]!, values[1]!);
      final right = widget.engine.create(values[2]!, values[3]!);
      final common = widget.engine.commonDenominator(
        left,
        right,
        method: _method,
      );
      final result = switch (_operation) {
        FractionLabOperation.add => widget.engine.add([left, right]),
        FractionLabOperation.subtract => widget.engine.subtract(left, right),
        FractionLabOperation.multiply => widget.engine.multiply([left, right]),
        FractionLabOperation.divide => widget.engine.divide(left, right),
        FractionLabOperation.compare => null,
      };
      final resultText = result == null
          ? '${left.fractionText} ${_comparisonSymbol(widget.engine.compare(left, right))} ${right.fractionText}'
          : '${_operationLabel(_operation)} result: ${result.fractionText}'
                '${result.classification == FractionClassification.improper ? ' = ${result.mixedNumberText}' : ''}';
      setState(() {
        _result = resultText;
        _details =
            'Common denominator ${common.denominator}: '
            '${common.leftStep.original.fractionText} = '
            '${common.leftStep.fractionText}; '
            '${common.rightStep.original.fractionText} = '
            '${common.rightStep.fractionText}. '
            'Every displayed result is normalized to lowest terms.';
        _error = null;
      });
    } on FractionException catch (error) {
      setState(() {
        _error = error.message;
        _result = null;
      });
    }
  }

  static String _operationLabel(FractionLabOperation operation) =>
      switch (operation) {
        FractionLabOperation.add => 'Addition',
        FractionLabOperation.subtract => 'Subtraction',
        FractionLabOperation.multiply => 'Multiplication',
        FractionLabOperation.divide => 'Division',
        FractionLabOperation.compare => 'Comparison',
      };

  static String _comparisonSymbol(int result) => result < 0
      ? '<'
      : result > 0
      ? '>'
      : '=';
}

class _FractionFields extends StatelessWidget {
  const _FractionFields({
    required this.label,
    required this.numerator,
    required this.denominator,
    required this.keyPrefix,
  });

  final String label;
  final TextEditingController numerator;
  final TextEditingController denominator;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label with numerator over denominator',
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('$keyPrefix-numerator'),
                  controller: numerator,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  decoration: const InputDecoration(labelText: 'Numerator'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('/', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: TextField(
                  key: ValueKey('$keyPrefix-denominator'),
                  controller: denominator,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  decoration: const InputDecoration(labelText: 'Denominator'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
