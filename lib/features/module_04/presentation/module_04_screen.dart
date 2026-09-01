import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../models/module_04_content.dart';
import '../services/mixed_number_answer_validator.dart';
import '../services/module_04_progress_controller.dart';
import '../widgets/mixed_calculator_launcher.dart';
import '../widgets/mixed_example_viewer.dart';
import '../widgets/mixed_lesson_card.dart';
import '../widgets/mixed_number_lab.dart';
import '../widgets/mixed_practice_question.dart';
import '../widgets/mixed_progress_tracker.dart';

class Module4Screen extends StatefulWidget {
  const Module4Screen({
    required this.progressController,
    required this.onOpenCalculator,
    this.answerValidator = const MixedNumberAnswerValidator(),
    super.key,
  });

  final Module4ProgressController progressController;
  final VoidCallback onOpenCalculator;
  final MixedNumberAnswerValidator answerValidator;

  @override
  State<Module4Screen> createState() => _Module4ScreenState();
}

class _Module4ScreenState extends State<Module4Screen> {
  String _answer = '';
  String _unit = '';
  final Set<String> _selectedGivenIds = {};
  int _questionIndex = 0;
  MixedNumberValidation? _feedback;

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
          key: const ValueKey('module4-scroll-view'),
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
                  MixedProgressTracker(
                    progress: progress,
                    lessonCount: Module4Curriculum.lessons.length,
                    questionCount: Module4Curriculum.practiceProblems.length,
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
                            index < Module4Curriculum.lessons.length;
                            index++
                          )
                            SizedBox(
                              width: cardWidth,
                              child: MixedLessonCard(
                                lesson: Module4Curriculum.lessons[index],
                                index: index,
                                viewed: progress.viewedLessonIds.contains(
                                  Module4Curriculum.lessons[index].id,
                                ),
                                onTap: () => _openLesson(
                                  Module4Curriculum.lessons[index],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Mixed-number learning lab',
                    subtitle:
                        'Inspect improper conversion, exact arithmetic, carrying, borrowing, and final reduction.',
                  ),
                  const SizedBox(height: 14),
                  const MixedNumberLab(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Practice & Seat Work 3 preparation',
                    subtitle:
                        'The validator checks exact value, mixed form, lowest terms, units, and selected givens separately.',
                  ),
                  const SizedBox(height: 14),
                  MixedPracticeQuestion(
                    problem: Module4Curriculum.practiceProblems[_questionIndex],
                    questionNumber: _questionIndex + 1,
                    questionCount: Module4Curriculum.practiceProblems.length,
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
                    selectedGivenIds: _selectedGivenIds,
                    feedback: _feedback,
                    onGivenChanged: _changeGiven,
                    onCheck: _checkAnswer,
                    onRetry: _retry,
                    onNext: _nextQuestion,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Module 4 prepares mixed-number methods for Seat Work 3 and Major Quiz 1. Learning attempts remain separate from presence and incident reports.',
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

  void _changeGiven(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedGivenIds.add(id);
      } else {
        _selectedGivenIds.remove(id);
      }
      _feedback = null;
    });
  }

  void _checkAnswer() {
    final problem = Module4Curriculum.practiceProblems[_questionIndex];
    final result = widget.answerValidator.validate(
      response: _answer,
      unit: _unit,
      selectedGivenIds: _selectedGivenIds,
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
      _selectedGivenIds.clear();
      _feedback = null;
      _questionIndex =
          (_questionIndex + 1) % Module4Curriculum.practiceProblems.length;
    });
  }

  void _openLesson(Module4Lesson lesson) {
    unawaited(widget.progressController.markLessonViewed(lesson.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Module4LessonScreen(lesson: lesson),
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
              Module4Curriculum.title,
              key: const ValueKey('module4-title'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Apply exact mixed-number methods to rules, drawings, bolt grip, spacers, cable, cargo, and cut planning.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        );
        final launcher = MixedCalculatorLauncher(
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
            const Text(Module4Curriculum.introduction),
            const SizedBox(height: 20),
            Text(
              'Learning objectives',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final objective in Module4Curriculum.objectives)
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

class Module4LessonScreen extends StatelessWidget {
  const Module4LessonScreen({required this.lesson, super.key});

  final Module4Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        key: const ValueKey('module4-lesson-scroll-view'),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.title,
                  key: ValueKey('module4-lesson-title-${lesson.id}'),
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
                  MixedExampleViewer(example: lesson.examples[index]),
                  if (index < lesson.examples.length - 1)
                    const SizedBox(height: 14),
                ],
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Study rule: convert complete mixed values, show Given, Formula, Substitute, and Solve, retain units, and reduce the final fraction.',
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
