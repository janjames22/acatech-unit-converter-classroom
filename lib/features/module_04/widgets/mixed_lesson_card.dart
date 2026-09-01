import 'package:flutter/material.dart';

import '../models/module_04_content.dart';

class MixedLessonCard extends StatelessWidget {
  const MixedLessonCard({
    required this.lesson,
    required this.index,
    required this.viewed,
    required this.onTap,
    super.key,
  });

  final Module4Lesson lesson;
  final int index;
  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        key: ValueKey('module4-lesson-${lesson.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    foregroundColor: colors.onSecondaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  const Spacer(),
                  Icon(
                    viewed
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: viewed ? colors.primary : colors.onSurfaceVariant,
                    semanticLabel: viewed ? 'Lesson viewed' : 'Open lesson',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                lesson.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                lesson.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
