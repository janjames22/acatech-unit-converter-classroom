import 'package:flutter/material.dart';

import '../../practice/widgets/numeric_input.dart';
import '../models/module_02_content.dart';
import '../services/whole_number_answer_validator.dart';

class PracticeQuestion extends StatelessWidget {
  const PracticeQuestion({
    required this.problem,
    required this.questionNumber,
    required this.questionCount,
    required this.answer,
    required this.onAnswerChanged,
    required this.feedback,
    required this.onCheck,
    required this.onRetry,
    required this.onNext,
    super.key,
  });

  final Module2PracticeProblem problem;
  final int questionNumber;
  final int questionCount;
  final String answer;
  final ValueChanged<String> onAnswerChanged;
  final AnswerValidation? feedback;
  final VoidCallback onCheck;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final result = feedback;
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: const ValueKey('module2-practice-card'),
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
              child: NumericInput(
                key: const ValueKey('module2-practice-input'),
                value: answer,
                onChanged: onAnswerChanged,
                label: problem.answerLabel,
                keyPrefix: 'module2',
                enabled: result?.isCorrect != true,
                allowDecimal: false,
                extraKeys: switch (problem.id) {
                  'm02_q04' => const ['R'],
                  'm02_q05' => const ['^', '×'],
                  'm02_q07' => const [','],
                  _ => const [],
                },
                suffix: problem.unit,
                helperText:
                    'Use only the controlled keypad and available math symbols.',
              ),
            ),
            const SizedBox(height: 14),
            if (result == null)
              FilledButton.icon(
                key: const ValueKey('module2-check-answer'),
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
                        Row(
                          children: [
                            Icon(
                              result.isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.message,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
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
                  key: const ValueKey('module2-next-question'),
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
                  key: const ValueKey('module2-retry-answer'),
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
