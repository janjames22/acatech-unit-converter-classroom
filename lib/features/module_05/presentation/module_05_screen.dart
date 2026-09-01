import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../models/module_05_content.dart';
import '../services/decimal_answer_validator.dart';
import '../services/module_05_progress_controller.dart';
import '../widgets/decimal_calculator_launcher.dart';
import '../widgets/decimal_example_viewer.dart';
import '../widgets/decimal_lab.dart';
import '../widgets/decimal_lesson_card.dart';
import '../widgets/decimal_practice_question.dart';
import '../widgets/decimal_progress_tracker.dart';

class Module5Screen extends StatefulWidget {
  const Module5Screen({
    required this.progressController,
    required this.onOpenCalculator,
    this.answerValidator = const DecimalAnswerValidator(),
    super.key,
  });

  final Module5ProgressController progressController;
  final VoidCallback onOpenCalculator;
  final DecimalAnswerValidator answerValidator;

  @override
  State<Module5Screen> createState() => _Module5ScreenState();
}

class _Module5ScreenState extends State<Module5Screen> {
  String _answer = '';
  String _unit = '';
  int _questionIndex = 0;
  DecimalValidation? _feedback;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progressController,
      builder: (context, _) {
        if (!widget.progressController.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress = widget.progressController.progress;
        return SingleChildScrollView(
          key: const ValueKey('module5-scroll-view'),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModuleHeader(onOpenCalculator: widget.onOpenCalculator),
                  const SizedBox(height: 20),
                  if (widget.progressController.errorMessage
                      case final error?) ...[
                    _StorageNotice(message: error),
                    const SizedBox(height: 16),
                  ],
                  DecimalProgressTracker(
                    progress: progress,
                    lessonCount: Module5Curriculum.lessons.length,
                    questionCount: Module5Curriculum.practiceProblems.length,
                  ),
                  const SizedBox(height: 24),
                  const _Introduction(),
                  const SizedBox(height: 28),
                  const _SectionHeading(
                    title: 'Lessons',
                    subtitle:
                        'Open each lesson to record it as viewed on this device.',
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760 ? 2 : 1;
                      final cardWidth =
                          (constraints.maxWidth - (columns - 1) * 16) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (
                            var index = 0;
                            index < Module5Curriculum.lessons.length;
                            index++
                          )
                            SizedBox(
                              width: cardWidth,
                              child: DecimalLessonCard(
                                lesson: Module5Curriculum.lessons[index],
                                index: index,
                                viewed: progress.viewedLessonIds.contains(
                                  Module5Curriculum.lessons[index].id,
                                ),
                                onTap: () => _openLesson(
                                  Module5Curriculum.lessons[index],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Exact decimal learning lab',
                    subtitle:
                        'Inspect place values, operations, retained digits, exact fractions, repeating cycles, and shop 64ths.',
                  ),
                  const SizedBox(height: 14),
                  const DecimalLab(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Practice & Seat Work 3',
                    subtitle:
                        'The validator checks exact value, specified precision, lowest terms, repeating notation, and units separately.',
                  ),
                  const SizedBox(height: 14),
                  DecimalPracticeQuestion(
                    problem: Module5Curriculum.practiceProblems[_questionIndex],
                    questionNumber: _questionIndex + 1,
                    questionCount: Module5Curriculum.practiceProblems.length,
                    answer: _answer,
                    unit: _unit,
                    onAnswerChanged: (value) => setState(() {
                      _answer = value;
                      _feedback = null;
                    }),
                    onUnitChanged: (value) => setState(() {
                      _unit = value;
                      _feedback = null;
                    }),
                    feedback: _feedback,
                    onCheck: _checkAnswer,
                    onRetry: _retry,
                    onNext: _nextQuestion,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seat Work 3 combines Modules 4–5. Learning attempts remain separate from presence and incident reports.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkAnswer() {
    final problem = Module5Curriculum.practiceProblems[_questionIndex];
    final result = widget.answerValidator.validate(
      response: _answer,
      unit: _unit,
      problem: problem,
    );
    setState(() => _feedback = result);
    if (result.recordsAttempt) {
      unawaited(
        widget.progressController.recordPracticeAttempt(
          problem.id,
          mastered: result.isCorrect,
        ),
      );
    }
  }

  void _retry() => setState(() => _feedback = null);

  void _nextQuestion() {
    setState(() {
      _answer = '';
      _unit = '';
      _feedback = null;
      _questionIndex =
          (_questionIndex + 1) % Module5Curriculum.practiceProblems.length;
    });
  }

  void _openLesson(Module5Lesson lesson) {
    unawaited(widget.progressController.markLessonViewed(lesson.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Module5LessonScreen(lesson: lesson),
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.onOpenCalculator});

  final VoidCallback onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AMT 111 · Phase A',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Module5Curriculum.title,
              key: const ValueKey('module5-title'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Use exact base-ten arithmetic for aircraft dimensions, circuits, drill and reamer selection, and final-step rounding.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        );
        final launcher = DecimalCalculatorLauncher(
          onOpenCalculator: onOpenCalculator,
        );
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [text, const SizedBox(height: 16), launcher],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: text),
            const SizedBox(width: 24),
            launcher,
          ],
        );
      },
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Module introduction',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(Module5Curriculum.introduction),
            const SizedBox(height: 20),
            Text(
              'Learning objectives',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final objective in Module5Curriculum.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_outline_rounded, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(objective)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StorageNotice extends StatelessWidget {
  const _StorageNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.storage_rounded),
      actions: const [SizedBox.shrink()],
    );
  }
}

class Module5LessonScreen extends StatelessWidget {
  const Module5LessonScreen({required this.lesson, super.key});

  final Module5Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        key: const ValueKey('module5-lesson-scroll-view'),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.title,
                  key: ValueKey('module5-lesson-title-${lesson.id}'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                const _LessonHeading(title: 'Objectives'),
                const SizedBox(height: 10),
                for (final objective in lesson.objectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $objective'),
                  ),
                const SizedBox(height: 18),
                const _LessonHeading(title: 'Explanation'),
                const SizedBox(height: 10),
                for (final paragraph in lesson.explanations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(paragraph),
                  ),
                const SizedBox(height: 10),
                const _LessonHeading(title: 'Worked examples'),
                const SizedBox(height: 12),
                for (
                  var index = 0;
                  index < lesson.examples.length;
                  index++
                ) ...[
                  DecimalExampleViewer(example: lesson.examples[index]),
                  if (index < lesson.examples.length - 1)
                    const SizedBox(height: 14),
                ],
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Study rule: keep decimal work exact, show Given, Formula, Substitute, and Solve, retain units, and round only at the requested final place.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonHeading extends StatelessWidget {
  const _LessonHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
