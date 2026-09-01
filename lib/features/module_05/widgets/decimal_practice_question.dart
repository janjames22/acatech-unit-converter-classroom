import 'package:flutter/material.dart';

import '../../practice/widgets/practice_inputs.dart';
import '../models/module_05_content.dart';
import '../services/decimal_answer_validator.dart';

class DecimalPracticeQuestion extends StatelessWidget {
  const DecimalPracticeQuestion({
    required this.problem,
    required this.questionNumber,
    required this.questionCount,
    required this.answer,
    required this.unit,
    required this.onAnswerChanged,
    required this.onUnitChanged,
    required this.feedback,
    required this.onCheck,
    required this.onRetry,
    required this.onNext,
    super.key,
  });

  final Module5PracticeProblem problem;
  final int questionNumber;
  final int questionCount;
  final String answer;
  final String unit;
  final ValueChanged<String> onAnswerChanged;
  final ValueChanged<String> onUnitChanged;
  final DecimalValidation? feedback;
  final VoidCallback onCheck;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final result = feedback;
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('module5-practice-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question $questionNumber of $questionCount',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              problem.prompt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            KeyedSubtree(
              key: ValueKey('${problem.id}-controlled-input'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (problem.kind == DecimalAnswerKind.fraction)
                    FractionInput(
                      key: const ValueKey('module5-practice-input'),
                      value: answer,
                      onChanged: onAnswerChanged,
                      keyPrefix: 'module5',
                      enabled: result?.isCorrect != true,
                    )
                  else
                    DecimalInput(
                      key: const ValueKey('module5-practice-input'),
                      value: answer,
                      onChanged: onAnswerChanged,
                      keyPrefix: 'module5',
                      enabled: result?.isCorrect != true,
                      extraKeys: problem.kind == DecimalAnswerKind.repeating
                          ? const ['(', ')']
                          : const [],
                      label: problem.kind == DecimalAnswerKind.repeating
                          ? 'Repeating decimal'
                          : 'Decimal answer',
                      helperText: problem.kind == DecimalAnswerKind.repeating
                          ? 'Use parentheses around the repeating cycle.'
                          : 'Use the controlled keypad below.',
                    ),
                  if (problem.expectedUnit != null) ...[
                    const SizedBox(height: 14),
                    ControlledUnitInput(
                      key: const ValueKey('module5-practice-unit'),
                      value: unit,
                      options: const ['in', 'ft', 'Ω', 'W'],
                      onChanged: onUnitChanged,
                      keyPrefix: 'module5',
                      enabled: result?.isCorrect != true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (result == null)
              FilledButton.icon(
                key: const ValueKey('module5-check-answer'),
                onPressed: onCheck,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Check answer'),
              )
            else ...[
              Semantics(
                liveRegion: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: result.isCorrect
                        ? colors.primaryContainer
                        : colors.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.message,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(result.explanation),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (result.isCorrect)
                FilledButton.icon(
                  key: const ValueKey('module5-next-question'),
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    questionNumber == questionCount
                        ? 'Review from the start'
                        : 'Next question',
                  ),
                )
              else
                OutlinedButton.icon(
                  key: const ValueKey('module5-retry-answer'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
