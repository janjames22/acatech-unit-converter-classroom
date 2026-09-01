import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/whole_number_models.dart';
import '../services/whole_numbers_engine.dart';

class WholeNumberLab extends StatefulWidget {
  const WholeNumberLab({this.engine = const WholeNumbersEngine(), super.key});

  final WholeNumbersEngine engine;

  @override
  State<WholeNumberLab> createState() => _WholeNumberLabState();
}

class _WholeNumberLabState extends State<WholeNumberLab> {
  final _first = TextEditingController(text: '3816');
  final _second = TextEditingController(text: '24');
  WholeNumberOperation _operation = WholeNumberOperation.division;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('module2-whole-number-lab'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Guided whole-number lab',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore place value, operations, factors, prime factors, and divisibility. This learning lab is separate from the general calculator.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 620;
                final fields = <Widget>[
                  TextField(
                    key: const ValueKey('module2-lab-first'),
                    controller: _first,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'First number',
                    ),
                  ),
                  DropdownButtonFormField<WholeNumberOperation>(
                    key: const ValueKey('module2-lab-operation'),
                    initialValue: _operation,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Operation'),
                    items: [
                      for (final operation in WholeNumberOperation.values)
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
                  TextField(
                    key: const ValueKey('module2-lab-second'),
                    controller: _second,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Second number',
                    ),
                  ),
                ];
                if (narrow) {
                  return Column(
                    children: [
                      for (var index = 0; index < fields.length; index++) ...[
                        fields[index],
                        if (index < fields.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (var index = 0; index < fields.length; index++) ...[
                      Expanded(child: fields[index]),
                      if (index < fields.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const ValueKey('module2-lab-explore'),
              onPressed: _explore,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Explore numbers'),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 14),
              Text(
                error,
                key: const ValueKey('module2-lab-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_result case final result?) ...[
              const SizedBox(height: 18),
              SelectableText(
                result,
                key: const ValueKey('module2-lab-result'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ..._detailsForFirstNumber(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _detailsForFirstNumber() {
    final first = int.parse(_first.text);
    if (first == 0) {
      return const [
        Text(
          'Zero has a ones-place digit of 0. Factors and prime factorization require a positive number.',
        ),
      ];
    }
    final factors = widget.engine.factors(first);
    final primeFactors = widget.engine.primeFactorization(first);
    final placeValues = widget.engine.placeValues(first);
    return [
      Text('Place value', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final row in placeValues)
            Chip(
              label: Text(
                '${row.digit} ${row.placeName} = ${row.contribution}',
              ),
            ),
        ],
      ),
      const SizedBox(height: 14),
      Text('Factors: ${factors.join(', ')}'),
      const SizedBox(height: 6),
      Text(
        first == 1
            ? 'Prime factors: 1 is neither prime nor composite.'
            : 'Prime factors: ${primeFactors.map((factor) => factor.toString()).join(' × ')}',
      ),
      const SizedBox(height: 14),
      Text(
        'Divisibility evidence',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      for (final rule in DivisibilityRule.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(widget.engine.checkDivisibility(first, rule).explanation),
        ),
    ];
  }

  void _explore() {
    final first = int.tryParse(_first.text);
    final second = int.tryParse(_second.text);
    if (first == null || second == null) {
      setState(() {
        _result = null;
        _error = 'Enter two whole numbers.';
      });
      return;
    }
    try {
      final result = switch (_operation) {
        WholeNumberOperation.addition =>
          '${widget.engine.add([first, second])}',
        WholeNumberOperation.subtraction =>
          '${widget.engine.subtract(first, second)}',
        WholeNumberOperation.multiplication =>
          '${widget.engine.multiply(first, second)}',
        WholeNumberOperation.division => _divisionText(
          widget.engine.divide(first, second),
        ),
      };
      setState(() {
        _result = '${_operationLabel(_operation)} result: $result';
        _error = null;
      });
    } on WholeNumberException catch (error) {
      setState(() {
        _result = null;
        _error = error.message;
      });
    }
  }

  static String _divisionText(DivisionResult result) => result.isExact
      ? '${result.quotient} (exact)'
      : '${result.quotient}, remainder ${result.remainder}';

  static String _operationLabel(WholeNumberOperation operation) =>
      switch (operation) {
        WholeNumberOperation.addition => 'Addition',
        WholeNumberOperation.subtraction => 'Subtraction',
        WholeNumberOperation.multiplication => 'Multiplication',
        WholeNumberOperation.division => 'Division',
      };
}
