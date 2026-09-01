import 'package:flutter/material.dart';

import '../models/decimal_models.dart';
import '../services/decimal_engine.dart';
import 'repeating_decimal_text.dart';

enum DecimalLabOperation {
  add,
  subtract,
  multiply,
  divide,
  round,
  decimalToFraction,
  fractionToDecimal,
  shopSixtyFourths,
  drillReam,
}

class DecimalLab extends StatefulWidget {
  const DecimalLab({
    this.engine = const DecimalEngine(),
    this.fractions = const FractionDecimalEngine(),
    this.shop = const ShopSixtyFourthsEngine(),
    super.key,
  });

  final DecimalEngine engine;
  final FractionDecimalEngine fractions;
  final ShopSixtyFourthsEngine shop;

  @override
  State<DecimalLab> createState() => _DecimalLabState();
}

class _DecimalLabState extends State<DecimalLab> {
  final _leftController = TextEditingController(text: '37.272');
  final _rightController = TextEditingController(text: '14.88');
  DecimalLabOperation _operation = DecimalLabOperation.subtract;
  int _roundingPlaces = 2;
  String? _result;
  String? _details;
  RepeatingDecimal? _repeating;
  String? _error;

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usesRight = {
      DecimalLabOperation.add,
      DecimalLabOperation.subtract,
      DecimalLabOperation.multiply,
      DecimalLabOperation.divide,
    }.contains(_operation);
    return Card(
      key: const ValueKey('module5-decimal-lab'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exact decimal lab',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore place value, decimal-safe operations, half-up rounding, exact fraction conversion, repeating cycles, and shop 64ths.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<DecimalLabOperation>(
              key: const ValueKey('module5-lab-operation'),
              initialValue: _operation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Learning tool'),
              items: [
                for (final operation in DecimalLabOperation.values)
                  DropdownMenuItem(
                    value: operation,
                    child: Text(_operationLabel(operation)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _operation = value;
                    _result = null;
                    _error = null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final left = TextField(
                  key: const ValueKey('module5-lab-left'),
                  controller: _leftController,
                  decoration: InputDecoration(
                    labelText:
                        _operation == DecimalLabOperation.fractionToDecimal
                        ? 'Fraction'
                        : 'First decimal',
                    helperText:
                        _operation == DecimalLabOperation.fractionToDecimal
                        ? 'Example: 1/3'
                        : 'Example: 37.272',
                  ),
                );
                final right = TextField(
                  key: const ValueKey('module5-lab-right'),
                  controller: _rightController,
                  decoration: const InputDecoration(
                    labelText: 'Second decimal',
                    helperText: 'Example: 14.88',
                  ),
                );
                if (!usesRight) {
                  return left;
                }
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [left, const SizedBox(height: 12), right],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 12),
                    Expanded(child: right),
                  ],
                );
              },
            ),
            if (_operation == DecimalLabOperation.round) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: const ValueKey('module5-lab-precision'),
                initialValue: _roundingPlaces,
                decoration: const InputDecoration(labelText: 'Round to'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Tenths')),
                  DropdownMenuItem(value: 2, child: Text('Hundredths')),
                  DropdownMenuItem(value: 3, child: Text('Thousandths')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _roundingPlaces = value);
                  }
                },
              ),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const ValueKey('module5-lab-explore'),
              onPressed: _explore,
              icon: const Icon(Icons.functions_rounded),
              label: const Text('Explore exact decimal'),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 14),
              Text(
                error,
                key: const ValueKey('module5-lab-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 18),
              SelectableText(
                result,
                key: const ValueKey('module5-lab-result'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (_repeating case final repeating?) ...[
                const SizedBox(height: 8),
                RepeatingDecimalText(
                  whole: repeating.whole,
                  nonRepeating: repeating.nonRepeating,
                  repeating: repeating.repeating,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
              const SizedBox(height: 8),
              Text(_details!),
            ],
          ],
        ),
      ),
    );
  }

  void _explore() {
    try {
      final output = switch (_operation) {
        DecimalLabOperation.add => _binary(
          (left, right) => widget.engine.add(left, right),
        ),
        DecimalLabOperation.subtract => _binary(
          (left, right) => widget.engine.subtract(left, right),
        ),
        DecimalLabOperation.multiply => _binary(
          (left, right) => widget.engine.multiply(left, right),
        ),
        DecimalLabOperation.divide => _divide(),
        DecimalLabOperation.round => _round(),
        DecimalLabOperation.decimalToFraction => _decimalToFraction(),
        DecimalLabOperation.fractionToDecimal => _fractionToDecimal(),
        DecimalLabOperation.shopSixtyFourths => _shopSixtyFourths(),
        DecimalLabOperation.drillReam => _drillReam(),
      };
      setState(() {
        _result = output.$1;
        _details = output.$2;
        _repeating = output.$3;
        _error = null;
      });
    } on Object catch (error) {
      final message = switch (error) {
        final DecimalException value => value.message,
        _ => error.toString(),
      };
      setState(() {
        _error = message;
        _result = null;
        _repeating = null;
      });
    }
  }

  (String, String, RepeatingDecimal?) _binary(
    DecimalOperationResult Function(DecimalQuantity, DecimalQuantity) action,
  ) {
    final left = widget.engine.parse(_leftController.text);
    final right = widget.engine.parse(_rightController.text);
    final result = action(left, right);
    final places = widget.engine
        .placeValues(left)
        .map((place) => '${place.digit} ${place.name}')
        .join(', ');
    return (
      '${_operationLabel(_operation)} result: ${result.result.text}',
      '${result.explanation} First value reads “${widget.engine.read(left)}”; places: $places.',
      null,
    );
  }

  (String, String, RepeatingDecimal?) _divide() {
    final left = widget.engine.parse(_leftController.text);
    final right = widget.engine.parse(_rightController.text);
    final division = widget.engine.divide(left, right);
    return (
      'Division result: ${division.expansion.plainText}',
      'Exact fraction ${division.exactFraction.text}. The decimal point is cleared in both values before long division.',
      division.expansion.isTerminating ? null : division.expansion,
    );
  }

  (String, String, RepeatingDecimal?) _round() {
    final value = widget.engine.parse(_leftController.text);
    final rounded = widget.engine.roundHalfUp(value, _roundingPlaces);
    return (
      'Rounded result: ${rounded.displayText}',
      'Retain digit ${rounded.retainedDigit}; inspect ${rounded.inspectionDigit}. ${rounded.roundedUp ? 'The inspection digit is 5 or greater, so round up.' : 'The inspection digit is below 5, so keep the retained digit.'}',
      null,
    );
  }

  (String, String, RepeatingDecimal?) _decimalToFraction() {
    final value = widget.engine.parse(_leftController.text);
    final fraction = widget.fractions.decimalToFraction(value);
    return (
      'Exact fraction: ${fraction.text}',
      '${value.text} = ${value.coefficient}/${BigInt.from(10).pow(value.scale)}, reduced to ${fraction.text}.',
      null,
    );
  }

  (String, String, RepeatingDecimal?) _fractionToDecimal() {
    final match = RegExp(
      r'^\s*(\d+)\s*/\s*(\d+)\s*$',
    ).firstMatch(_leftController.text);
    if (match == null) {
      throw const DecimalException('Enter a fraction such as 1/3.');
    }
    final fraction = BigDecimalFraction(
      BigInt.parse(match.group(1)!),
      BigInt.parse(match.group(2)!),
    );
    final expansion = widget.fractions.expand(fraction);
    return (
      'Decimal expansion: ${expansion.plainText}',
      expansion.isTerminating
          ? 'Long division reaches a zero remainder.'
          : 'A repeated remainder marks the overlined repeating cycle.',
      expansion.isTerminating ? null : expansion,
    );
  }

  (String, String, RepeatingDecimal?) _shopSixtyFourths() {
    final value = widget.engine.parse(_leftController.text);
    final result = widget.shop.convert(value);
    return (
      'Shop fraction: ${result.reduced.text}',
      '${value.text} × 64 = ${result.timesSixtyFour.text}; half-up to ${result.roundedNumerator}; ${result.unreducedText} reduces to ${result.reduced.text}.',
      null,
    );
  }

  (String, String, RepeatingDecimal?) _drillReam() {
    final value = widget.engine.parse(_leftController.text);
    final result = widget.shop.drillForReamedSize(value);
    return (
      'Drill fraction: ${result.drillFraction.text}',
      'Reamed ${value.text} inch → ${result.reamedFraction.text}; subtract ${result.undersize.text} inch exactly.',
      null,
    );
  }

  static String _operationLabel(DecimalLabOperation operation) =>
      switch (operation) {
        DecimalLabOperation.add => 'Addition',
        DecimalLabOperation.subtract => 'Subtraction',
        DecimalLabOperation.multiply => 'Multiplication',
        DecimalLabOperation.divide => 'Division',
        DecimalLabOperation.round => 'Half-up rounding',
        DecimalLabOperation.decimalToFraction => 'Decimal to exact fraction',
        DecimalLabOperation.fractionToDecimal => 'Fraction to decimal',
        DecimalLabOperation.shopSixtyFourths => 'Shop 64ths',
        DecimalLabOperation.drillReam => 'Drill and ream planner',
      };
}
