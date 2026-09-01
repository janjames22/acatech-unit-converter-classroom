import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../application/calculator_controller.dart';
import 'widgets/angle_mode_selector.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keyboard.dart';
import 'widgets/history_panel.dart';
import 'widgets/scientific_buttons.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({required this.controller, super.key});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= AppBreakpoints.expanded;
            final horizontalPadding = constraints.maxWidth < 430 ? 16.0 : 24.0;
            final content = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _CalculatorContent(
                            controller: controller,
                            showHistoryButton: false,
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 370,
                          child: HistoryPanel(
                            history: controller.state.history,
                            onReuse: controller.reuseHistory,
                            onClear: controller.clearHistory,
                            embedded: true,
                          ),
                        ),
                      ],
                    )
                  : _CalculatorContent(
                      controller: controller,
                      showHistoryButton: true,
                    ),
            );

            if (desktop) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    24,
                  ),
                  child: content,
                ),
              );
            }
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: content,
              ),
            );
          },
        );
      },
    );
  }
}

class _CalculatorContent extends StatelessWidget {
  const _CalculatorContent({
    required this.controller,
    required this.showHistoryButton,
  });

  final CalculatorController controller;
  final bool showHistoryButton;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return SingleChildScrollView(
      key: const ValueKey('calculator-scroll-view'),
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 36),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scientific Calculator',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Basic, scientific, and engineering calculations.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showHistoryButton) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  key: const ValueKey('calculator-open-history'),
                  tooltip: 'Open calculation history',
                  onPressed: () => _showHistory(context),
                  icon: Badge(
                    isLabelVisible: !state.history.isEmpty,
                    label: Text('${state.history.entries.length}'),
                    child: const Icon(Icons.history_rounded),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          CalculatorDisplay(state: state),
          const SizedBox(height: 16),
          _ModeAndMemory(controller: controller),
          const SizedBox(height: 20),
          ScientificButtons(controller: controller),
          const SizedBox(height: 20),
          Text(
            'Keyboard',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          CalculatorKeyboard(controller: controller),
        ],
      ),
    );
  }

  Future<void> _showHistory(BuildContext context) async {
    final compact = MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
    final history = AnimatedBuilder(
      animation: controller,
      builder: (context, _) => HistoryPanel(
        history: controller.state.history,
        onReuse: (entry) {
          controller.reuseHistory(entry);
          Navigator.of(context).pop();
        },
        onClear: controller.clearHistory,
      ),
    );
    if (compact) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) =>
            FractionallySizedBox(heightFactor: 0.78, child: history),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) =>
          Dialog(child: SizedBox(width: 560, height: 650, child: history)),
    );
  }
}

class _ModeAndMemory extends StatelessWidget {
  const _ModeAndMemory({required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;
            final memory = _MemoryControls(controller: controller);
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AngleModeSelector(
                      mode: state.angleMode,
                      onChanged: controller.setAngleMode,
                    ),
                  ),
                  const SizedBox(height: 12),
                  memory,
                ],
              );
            }
            return Row(
              children: [
                AngleModeSelector(
                  mode: state.angleMode,
                  onChanged: controller.setAngleMode,
                ),
                const SizedBox(width: 16),
                Expanded(child: memory),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemoryControls extends StatelessWidget {
  const _MemoryControls({required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Row(
      children: [
        if (state.hasMemory)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Tooltip(
              message: 'Memory contains ${state.memoryValue}',
              child: const Icon(Icons.memory_rounded, size: 20),
            ),
          ),
        for (final button
            in <({String label, String tooltip, VoidCallback? action})>[
              (
                label: 'MC',
                tooltip: 'Clear memory',
                action: state.hasMemory ? controller.memoryClear : null,
              ),
              (
                label: 'MR',
                tooltip: 'Recall memory',
                action: state.hasMemory ? controller.memoryRecall : null,
              ),
              (
                label: 'M+',
                tooltip: 'Add result to memory',
                action: state.lastValue == null ? null : controller.memoryAdd,
              ),
              (
                label: 'M−',
                tooltip: 'Subtract result from memory',
                action: state.lastValue == null
                    ? null
                    : controller.memorySubtract,
              ),
            ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Tooltip(
                message: button.tooltip,
                child: OutlinedButton(
                  onPressed: button.action,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(button.label),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
