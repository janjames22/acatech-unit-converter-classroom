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

void main() {
  testWidgets(
    'Module 5 hub, lesson, and calculator navigation create zero incidents',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final repository = InMemoryAssessmentRepository();
      final monitor = AssessmentMonitor(repository: repository);
      final assessmentController = AssessmentAppController(repository, monitor);
      await assessmentController.initialize();
      addTearDown(assessmentController.dispose);
      final module2Controller = Module2ProgressController(
        InMemoryModule2ProgressRepository(),
      );
      await module2Controller.initialize();
      addTearDown(module2Controller.dispose);
      final module3Controller = Module3ProgressController(
        InMemoryModule3ProgressRepository(),
      );
      await module3Controller.initialize();
      addTearDown(module3Controller.dispose);
      final module4Controller = Module4ProgressController(
        InMemoryModule4ProgressRepository(),
      );
      await module4Controller.initialize();
      addTearDown(module4Controller.dispose);
      final module5Controller = Module5ProgressController(
        InMemoryModule5ProgressRepository(),
      );
      await module5Controller.initialize();
      addTearDown(module5Controller.dispose);
      final installService = PwaInstallService.platform();
      await installService.initialize();
      addTearDown(installService.dispose);

      final session = AssessmentSession(
        id: 'module-5-active-session',
        studentName: 'Student',
        assessmentName: 'Seat Work 3',
        startedAt: DateTime.now().toUtc(),
        plannedDuration: const Duration(minutes: 30),
      );
      await monitor.startSession(session);
      await assessmentController.refreshReports();
      final originalMonitor = assessmentController.monitor;

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: UnitConverterShell(
            assessmentController: assessmentController,
            module2ProgressController: module2Controller,
            module3ProgressController: module3Controller,
            module4ProgressController: module4Controller,
            module5ProgressController: module5Controller,
            pinService: TeacherPinService(preferences),
            settingsController: AppSettingsController(preferences),
            pwaInstallService: installService,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      final hubScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('aviation-math-hub-scroll-view')),
            matching: find.byType(Scrollable),
          )
          .first;
      final module5Card = find.byKey(const ValueKey('open-module-05'));
      await tester.scrollUntilVisible(
        module5Card,
        450,
        scrollable: hubScrollable,
      );
      await tester.tap(module5Card);
      await tester.pumpAndSettle();
      expect(find.text(Module5Curriculum.title), findsOneWidget);

      final moduleScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('module5-scroll-view')),
            matching: find.byType(Scrollable),
          )
          .first;
      final firstLesson = find.byKey(const ValueKey('module5-lesson-m05_l01'));
      await tester.scrollUntilVisible(
        firstLesson,
        450,
        scrollable: moduleScrollable,
      );
      await tester.tap(firstLesson);
      await tester.pumpAndSettle();
      expect(find.text('Aviation example'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();

      final calculatorLauncher = find.byKey(
        const ValueKey('module5-open-calculator'),
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
      expect(await repository.loadPendingAbsence(), isNull);
      expect(await repository.loadIncidents(session.id), isEmpty);
    },
  );
}
