import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/layout/app_breakpoints.dart';
import '../models/module_02_content.dart';
import '../services/module_02_progress_controller.dart';
import '../services/whole_number_answer_validator.dart';
import '../widgets/calculator_launcher.dart';
import '../widgets/example_viewer.dart';
import '../widgets/formula_card.dart';
import '../widgets/lesson_card.dart';
import '../widgets/practice_question.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/whole_number_lab.dart';

class Module2Screen extends StatefulWidget {
  const Module2Screen({
    required this.progressController,
    required this.onOpenCalculator,
    this.answerValidator = const WholeNumberAnswerValidator(),
    super.key,
  });

  final Module2ProgressController progressController;
  final VoidCallback onOpenCalculator;
  final WholeNumberAnswerValidator answerValidator;

  @override
  State<Module2Screen> createState() => _Module2ScreenState();
}

class _Module2ScreenState extends State<Module2Screen> {
  String _answer = '';
  int _questionIndex = 0;
  AnswerValidation? _feedback;

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
          key: const ValueKey('module2-scroll-view'),
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
                  ProgressTracker(
                    progress: progress,
                    lessonCount: Module2Curriculum.lessons.length,
                    questionCount: Module2Curriculum.practiceProblems.length,
                  ),
                  const SizedBox(height: 24),
                  const _Introduction(),
                  const SizedBox(height: 28),
                  _SectionHeading(
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
                            index < Module2Curriculum.lessons.length;
                            index++
                          )
                            SizedBox(
                              width: cardWidth,
                              child: LessonCard(
                                lesson: Module2Curriculum.lessons[index],
                                index: index,
                                viewed: progress.viewedLessonIds.contains(
                                  Module2Curriculum.lessons[index].id,
                                ),
                                onTap: () => _openLesson(
                                  Module2Curriculum.lessons[index],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Whole-number lab',
                    subtitle:
                        'Explore exact arithmetic and the evidence behind each result.',
                  ),
                  const SizedBox(height: 14),
                  const WholeNumberLab(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    title: 'Practice & Module 2 Quiz',
                    subtitle:
                        'Master every question. Incorrect answers can be reviewed and retried.',
                  ),
                  const SizedBox(height: 14),
                  PracticeQuestion(
                    problem: Module2Curriculum.practiceProblems[_questionIndex],
                    questionNumber: _questionIndex + 1,
                    questionCount: Module2Curriculum.practiceProblems.length,
                    answer: _answer,
                    onAnswerChanged: (value) => setState(() {
                      _answer = value;
                      _feedback = null;
                    }),
                    feedback: _feedback,
                    onCheck: _checkAnswer,
                    onRetry: _retry,
                    onNext: _nextQuestion,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz coverage: four operations, vocabulary, factors, multiples, prime factorization, LCM, and divisibility. Learning results stay local and separate from presence reports.',
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
    final problem = Module2Curriculum.practiceProblems[_questionIndex];
    final result = widget.answerValidator.validate(_answer, problem);
    setState(() => _feedback = result);
    if (result.isCorrect) {
      unawaited(widget.progressController.markQuestionMastered(problem.id));
    }
  }

  void _retry() {
    setState(() {
      _answer = '';
      _feedback = null;
    });
  }

  void _nextQuestion() {
    setState(() {
      _answer = '';
      _feedback = null;
      _questionIndex =
          (_questionIndex + 1) % Module2Curriculum.practiceProblems.length;
    });
  }

  void _openLesson(Module2Lesson lesson) {
    unawaited(widget.progressController.markLessonViewed(lesson.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Module2LessonScreen(lesson: lesson),
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
              Module2Curriculum.title,
              key: const ValueKey('module2-title'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Build exact arithmetic for aviation stores, logs, inventory, and later fraction work.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        );
        final launcher = CalculatorLauncher(onOpenCalculator: onOpenCalculator);
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
            const Text(Module2Curriculum.introduction),
            const SizedBox(height: 20),
            Text(
              'Learning objectives',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final objective in Module2Curriculum.objectives)
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

class Module2LessonScreen extends StatelessWidget {
  const Module2LessonScreen({required this.lesson, super.key});

  final Module2Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        key: const ValueKey('module2-lesson-scroll-view'),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.title,
                  key: ValueKey('module2-lesson-title-${lesson.id}'),
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
                Text(
                  'Objectives',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final objective in lesson.objectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $objective'),
                  ),
                const SizedBox(height: 18),
                Text(
                  'Explanation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final paragraph in lesson.explanations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(paragraph),
                  ),
                const SizedBox(height: 10),
                if (lesson.id == 'm02_l05') ...[
                  const FormulaCard(
                    label: 'Divisibility by 6',
                    formula: 'divisible by 2 AND divisible by 3',
                    note:
                        'Both conditions are required. Passing only one test is not enough.',
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Worked examples',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                for (
                  var index = 0;
                  index < lesson.examples.length;
                  index++
                ) ...[
                  ExampleViewer(example: lesson.examples[index]),
                  if (index < lesson.examples.length - 1)
                    const SizedBox(height: 14),
                ],
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Study rule: organize applicable problems as Given, Formula, Substitute, and Solve. Keep units visible and check the final result.',
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
