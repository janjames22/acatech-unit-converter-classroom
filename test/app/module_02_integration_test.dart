import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/app/app.dart';
import 'package:unit_converter/app/app_settings_controller.dart';
import 'package:unit_converter/core/security/teacher_pin_service.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/presentation/assessment_app_controller.dart';
import 'package:unit_converter/features/calculator/calculator.dart';
import 'package:unit_converter/features/module_02/module_02.dart';
import 'package:unit_converter/features/module_03/module_03.dart';
import 'package:unit_converter/features/module_04/module_04.dart';
import 'package:unit_converter/features/module_05/module_05.dart';
import 'package:unit_converter/features/pwa_install/pwa_install.dart';

import '../helpers/practice_input_test_helpers.dart';

void main() {
  testWidgets(
    'Module 2 navigation and calculator use create no assessment incident',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final repository = InMemoryAssessmentRepository();
      final monitor = AssessmentMonitor(repository: repository);
      final assessmentController = AssessmentAppController(repository, monitor);
      await assessmentController.initialize();
      addTearDown(assessmentController.dispose);
      final progressController = Module2ProgressController(
        InMemoryModule2ProgressRepository(),
      );
      await progressController.initialize();
      addTearDown(progressController.dispose);
      final module3ProgressController = Module3ProgressController(
        InMemoryModule3ProgressRepository(),
      );
      await module3ProgressController.initialize();
      addTearDown(module3ProgressController.dispose);
      final module4ProgressController = Module4ProgressController(
        InMemoryModule4ProgressRepository(),
      );
      await module4ProgressController.initialize();
      addTearDown(module4ProgressController.dispose);
      final module5ProgressController = Module5ProgressController(
        InMemoryModule5ProgressRepository(),
      );
      await module5ProgressController.initialize();
      addTearDown(module5ProgressController.dispose);
      final installService = PwaInstallService.platform();
      await installService.initialize();
      addTearDown(installService.dispose);

      final now = DateTime.now().toUtc();
      await monitor.startSession(
        AssessmentSession(
          id: 'module-2-active-session',
          studentName: 'Student',
          assessmentName: 'Module 2 Quiz',
          startedAt: now,
          plannedDuration: const Duration(minutes: 30),
        ),
      );
      await assessmentController.refreshReports();
      final originalMonitor = assessmentController.monitor;

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: UnitConverterShell(
            assessmentController: assessmentController,
            module2ProgressController: progressController,
            module3ProgressController: module3ProgressController,
            module4ProgressController: module4ProgressController,
            module5ProgressController: module5ProgressController,
            pinService: TeacherPinService(preferences),
            settingsController: AppSettingsController(preferences),
            pwaInstallService: installService,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-module-02')));
      await tester.pumpAndSettle();
      expect(find.text(Module2Curriculum.title), findsOneWidget);

      final moduleScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('module2-scroll-view')),
            matching: find.byType(Scrollable),
          )
          .first;
      final firstLesson = find.byKey(const ValueKey('module2-lesson-m02_l01'));
      await tester.scrollUntilVisible(
        firstLesson,
        400,
        scrollable: moduleScrollable,
      );
      await tester.tap(firstLesson);
      await tester.pumpAndSettle();
      expect(find.text('Aviation example'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      final practiceInput = find.byKey(
        const ValueKey('module2-practice-input'),
      );
      await tester.scrollUntilVisible(
        practiceInput,
        700,
        scrollable: moduleScrollable,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('module2-practice-card')),
          matching: find.byType(EditableText),
        ),
        findsNothing,
      );
      await tapPracticeKeys(tester, 'module2', ['9', '7', '5', '7', '8']);
      await tapPracticeControl(tester, 'module2-check-answer');
      expect(find.textContaining('Correct.'), findsOneWidget);
      expect(monitor.pendingAbsence, isNull);
      expect(
        await repository.loadIncidents('module-2-active-session'),
        isEmpty,
      );

      final calculatorLauncher = find.byKey(
        const ValueKey('module2-open-calculator'),
      );
      await tester.scrollUntilVisible(
        calculatorLauncher,
        -500,
        scrollable: moduleScrollable,
      );
      await tester.tap(calculatorLauncher);
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorScreen), findsOneWidget);

      expect(identical(assessmentController.monitor, originalMonitor), isTrue);
      expect(monitor.pendingAbsence, isNull);
      expect(
        await repository.loadIncidents('module-2-active-session'),
        isEmpty,
      );
    },
  );
}
