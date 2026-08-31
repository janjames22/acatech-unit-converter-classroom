import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../converter.dart';
import 'category_icon.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({
    required this.category,
    required this.onBack,
    this.initialUnit,
    super.key,
  });

  final UnitCategory category;
  final UnitDefinition? initialUnit;
  final VoidCallback onBack;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late final TextEditingController _inputController;
  late UnitDefinition _fromUnit;
  late UnitDefinition _toUnit;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: '1');
    _resetUnits();
  }

  @override
  void didUpdateWidget(covariant ConverterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id ||
        oldWidget.initialUnit?.id != widget.initialUnit?.id) {
      _resetUnits();
      _inputController.text = '1';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _resetUnits() {
    _fromUnit = widget.initialUnit ?? widget.category.units.first;
    _toUnit = widget.category.units.firstWhere(
      (unit) => unit.id != _fromUnit.id,
      orElse: () => _fromUnit,
    );
  }

  double? get _input => double.tryParse(_inputController.text.trim());

  double? get _result {
    final input = _input;
    if (input == null || !input.isFinite) {
      return null;
    }
    final result = ConversionEngine.convert(
      value: input,
      from: _fromUnit,
      to: _toUnit,
    );
    return result.isFinite ? result : null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 820;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('All categories'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox.square(
                          dimension: 58,
                          child: Icon(
                            iconForCategory(widget.category.id),
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.category.name} converter',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Enter a value and choose two units.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: horizontal
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildInput()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildUnitPicker(true)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    4,
                                    12,
                                    0,
                                  ),
                                  child: _buildSwapButton(),
                                ),
                                Expanded(child: _buildUnitPicker(false)),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildInput(),
                                const SizedBox(height: 16),
                                _buildUnitPicker(true),
                                const SizedBox(height: 12),
                                Align(child: _buildSwapButton()),
                                const SizedBox(height: 12),
                                _buildUnitPicker(false),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ResultCard(
                    input: _input,
                    result: _result,
                    fromUnit: _fromUnit,
                    toUnit: _toUnit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return TextField(
      key: const ValueKey('conversion-input'),
      controller: _inputController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Value',
        hintText: 'Enter a number',
        errorText: _inputController.text.isNotEmpty && _input == null
            ? 'Enter a valid number'
            : null,
        suffixIcon: _inputController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear value',
                onPressed: () {
                  _inputController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildUnitPicker(bool from) {
    final value = from ? _fromUnit : _toUnit;
    return DropdownButtonFormField<UnitDefinition>(
      key: ValueKey(from ? 'from-unit' : 'to-unit'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: from ? 'From unit' : 'To unit'),
      items: [
        for (final unit in widget.category.units)
          DropdownMenuItem(
            value: unit,
            child: Text(
              '${unit.name} (${unit.symbol})',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (unit) {
        if (unit == null) {
          return;
        }
        setState(() {
          if (from) {
            _fromUnit = unit;
          } else {
            _toUnit = unit;
          }
        });
      },
    );
  }

  Widget _buildSwapButton() {
    return IconButton.filledTonal(
      key: const ValueKey('swap-units'),
      tooltip: 'Swap units',
      onPressed: () {
        setState(() {
          final previousFrom = _fromUnit;
          _fromUnit = _toUnit;
          _toUnit = previousFrom;
        });
      },
      icon: const Icon(Icons.swap_horiz_rounded),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.input,
    required this.result,
    required this.fromUnit,
    required this.toUnit,
  });

  final double? input;
  final double? result;
  final UnitDefinition fromUnit;
  final UnitDefinition toUnit;

  @override
  Widget build(BuildContext context) {
    final formatted = result == null
        ? null
        : ConversionNumberFormatter.format(result!);
    final inputText = input == null
        ? null
        : ConversionNumberFormatter.format(input!);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      label: formatted == null
          ? 'Conversion result unavailable'
          : 'Conversion result: $formatted ${toUnit.name}',
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      formatted == null ? '—' : '$formatted ${toUnit.symbol}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (inputText != null && formatted != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$inputText ${fromUnit.symbol} = $formatted ${toUnit.symbol}',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: formatted == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: '$formatted ${toUnit.symbol}'),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Result copied')),
                          );
                        }
                      },
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
