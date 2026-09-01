import 'package:flutter/material.dart';

import '../models/module_05_progress.dart';

class DecimalProgressTracker extends StatelessWidget {
  const DecimalProgressTracker({
    required this.progress,
    required this.lessonCount,
    required this.questionCount,
    super.key,
  });

  final Module5Progress progress;
  final int lessonCount;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final total = lessonCount + questionCount;
    final completed = progress.viewedLessonIds.length + progress.score;
    final fraction = total == 0 ? 0.0 : completed / total;
    final status = progress.completionStatus(
      lessonCount: lessonCount,
      questionCount: questionCount,
    );
    final statusLabel = switch (status) {
      Module5CompletionStatus.notStarted => 'Not started',
      Module5CompletionStatus.inProgress => 'In progress',
      Module5CompletionStatus.complete => 'Complete',
    };
    return Card(
      key: const ValueKey('module5-progress'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your local progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: '${(fraction * 100).round()} percent complete',
              child: LinearProgressIndicator(value: fraction),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  '${progress.viewedLessonIds.length}/$lessonCount lessons viewed',
                ),
                Text('${progress.score}/$questionCount score'),
                Text('${progress.totalAttempts} attempts'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Saved only on this device.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
