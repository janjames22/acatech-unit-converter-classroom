import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/app/app.dart';
import 'package:unit_converter/app/app_settings_controller.dart';
import 'package:unit_converter/app/presentation/install_app_action.dart';
import 'package:unit_converter/core/security/teacher_pin_service.dart';
import 'package:unit_converter/features/assessment/application/assessment_monitor.dart';
import 'package:unit_converter/features/assessment/data/in_memory_assessment_repository.dart';
import 'package:unit_converter/features/assessment/domain/models/assessment_session.dart';
import 'package:unit_converter/features/assessment/presentation/assessment_app_controller.dart';
import 'package:unit_converter/features/calculator/calculator.dart';
import 'package:unit_converter/features/pwa_install/pwa_install.dart';

void main() {
  late SharedPreferences preferences;
  late InMemoryAssessmentRepository repository;
  late AssessmentMonitor monitor;
  late AssessmentAppController controller;
  late _FakePwaInstallBridge installBridge;
  late PwaInstallService installService;

  Future<void> initializeDependencies({
    PwaInstallSnapshot installSnapshot = const PwaInstallSnapshot(
      isInstalled: false,
      isIos: false,
      canPrompt: true,
    ),
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    repository = InMemoryAssessmentRepository();
    monitor = AssessmentMonitor(repository: repository);
    controller = AssessmentAppController(repository, monitor);
    await controller.initialize();
    installBridge = _FakePwaInstallBridge(installSnapshot);
    installService = PwaInstallService(bridge: installBridge);
    await installService.initialize();
    addTearDown(installService.dispose);
  }

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UnitConverterShell(
          assessmentController: controller,
          pinService: TeacherPinService(preferences),
          settingsController: AppSettingsController(preferences),
          pwaInstallService: installService,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('adapts navigation and install action across target widths', (
    tester,
  ) async {
    await initializeDependencies();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const widths = <double>[320, 360, 390, 430, 768, 1024, 1366, 1920, 2560];
    tester.view.physicalSize = const Size(320, 900);
    await pumpShell(tester);

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pump();

      final compact = width < 600;
      final expanded = width >= 1024;
      expect(
        find.byType(NavigationBar),
        compact ? findsOneWidget : findsNothing,
        reason: 'navigation bar at ${width}px',
      );
      expect(
        find.byType(NavigationRail),
        compact ? findsNothing : findsOneWidget,
        reason: 'navigation rail at ${width}px',
      );
      if (!compact) {
        expect(
          tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
          expanded,
          reason: 'extended rail at ${width}px',
        );
      }
      expect(
        find.byKey(InstallAppAction.compactButtonKey),
        compact ? findsOneWidget : findsNothing,
        reason: 'compact install affordance at ${width}px',
      );
      expect(
        find.byKey(InstallAppAction.labeledButtonKey),
        compact ? findsNothing : findsOneWidget,
        reason: 'labeled install affordance at ${width}px',
      );
      expect(tester.takeException(), isNull, reason: 'layout at ${width}px');
    }
  });

  testWidgets(
    'internal tools and overlays keep monitor and create no incident',
    (tester) async {
      await initializeDependencies();
      final now = DateTime.now().toUtc();
      await monitor.startSession(
        AssessmentSession(
          id: 'active-session',
          studentName: 'Student',
          assessmentName: 'Quiz',
          startedAt: now,
          plannedDuration: const Duration(minutes: 30),
        ),
      );
      await controller.refreshReports();
      final originalMonitor = controller.monitor;

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await pumpShell(tester);

      await tester.tap(find.text('Assessment').last);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Calculator').last);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CalculatorScreen), findsOneWidget);

      final calculatorScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('calculator-scroll-view')),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final keyName in ['digit-2', 'add', 'digit-2', 'equals']) {
        final key = find.byKey(ValueKey('calculator-key-$keyName'));
        await tester.scrollUntilVisible(
          key,
          400,
          scrollable: calculatorScrollable,
        );
        await tester.tap(key);
        await tester.pump();
      }
      final history = find.byKey(const ValueKey('calculator-open-history'));
      await tester.scrollUntilVisible(
        history,
        -400,
        scrollable: calculatorScrollable,
      );
      await tester.tap(history);
      await tester.pumpAndSettle();
      expect(find.text('Previous Calculations'), findsOneWidget);
      expect(find.text('= 4'), findsOneWidget);
      await tester.tapAt(const Offset(8, 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home').last);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Length'));
      await tester.pumpAndSettle();
      final input = find.byKey(const ValueKey('conversion-input'));
      await tester.tap(input);
      await tester.showKeyboard(input);
      await tester.enterText(input, '12.5');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('from-unit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kilometer (km)').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reports').last);
      await tester.pumpAndSettle();
      expect(find.text('Create teacher PIN'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Toggle light or dark theme'));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('open-about')));
      await tester.pumpAndSettle();
      expect(find.text('About ACATECH'), findsOneWidget);
      expect(find.byKey(const ValueKey('acatech-full-logo')), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(identical(controller.monitor, originalMonitor), isTrue);
      expect(await repository.loadIncidents('active-session'), isEmpty);
    },
  );

  testWidgets('teacher PIN gates assessment start, reports, and end', (
    tester,
  ) async {
    await initializeDependencies();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpShell(tester);

    await tester.tap(find.text('Assessment').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('student-name')),
      'Student 1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('assessment-name')),
      'Integration Quiz',
    );
    final start = find.byKey(const ValueKey('start-assessment'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();

    expect(find.text('Create teacher PIN'), findsOneWidget);
    final setupPinFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(setupPinFields, findsNWidgets(2));
    await tester.enterText(setupPinFields.at(0), '2468');
    await tester.enterText(setupPinFields.at(1), '2468');
    await tester.tap(find.text('Create PIN'));
    await tester.pumpAndSettle();

    expect(controller.activeSession?.assessmentName, 'Integration Quiz');
    expect(find.text('ASSESSMENT ACTIVE'), findsOneWidget);

    await tester.tap(find.text('Reports').last);
    await tester.pumpAndSettle();
    expect(find.text('Teacher authorization'), findsOneWidget);
    final reportPinField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(reportPinField, '2468');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Local assessment reports'), findsOneWidget);
    expect(find.text('Integration Quiz'), findsOneWidget);

    await tester.tap(find.text('Assessment').last);
    await tester.pumpAndSettle();
    final end = find.byKey(const ValueKey('end-assessment'));
    await tester.ensureVisible(end);
    await tester.tap(end);
    await tester.pumpAndSettle();
    final endPinField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(endPinField, '2468');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(controller.activeSession, isNull);
    final savedSession = (await repository.loadSessions()).single;
    expect(savedSession.isActive, isFalse);
    expect(await repository.loadIncidents(savedSession.id), isEmpty);
  });

  testWidgets('iOS install action opens the manual Home Screen workflow', (
    tester,
  ) async {
    await initializeDependencies(
      installSnapshot: const PwaInstallSnapshot(
        isInstalled: false,
        isIos: true,
        canPrompt: false,
      ),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpShell(tester);

    final installButton = tester.widget<IconButton>(
      find.byKey(InstallAppAction.compactButtonKey),
    );
    expect(installButton.tooltip, 'Install App');

    await tester.tap(find.byKey(InstallAppAction.compactButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(InstallAppAction.instructionsKey), findsOneWidget);
    expect(find.text('Install Unit Converter'), findsOneWidget);
    expect(find.text('Tap the Share button'), findsOneWidget);
    expect(find.text('Choose Add to Home Screen'), findsOneWidget);
    expect(find.text('Confirm by tapping Add'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('unsupported and installed states hide install controls', (
    tester,
  ) async {
    await initializeDependencies(
      installSnapshot: const PwaInstallSnapshot.unavailable(),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1366, 900);
    addTearDown(tester.view.reset);
    await pumpShell(tester);

    expect(find.byKey(InstallAppAction.compactButtonKey), findsNothing);
    expect(find.byKey(InstallAppAction.labeledButtonKey), findsNothing);

    installBridge.emit(PwaInstallBridgeEvent.installed);
    await tester.pump();

    expect(installService.state, PwaInstallState.installed);
    expect(find.byKey(InstallAppAction.compactButtonKey), findsNothing);
    expect(find.byKey(InstallAppAction.labeledButtonKey), findsNothing);
  });

  testWidgets('install prompt lifecycle is explicitly suppressed', (
    tester,
  ) async {
    await initializeDependencies();
    final now = DateTime.now().toUtc();
    await monitor.startSession(
      AssessmentSession(
        id: 'active-session',
        studentName: 'Student',
        assessmentName: 'Quiz',
        startedAt: now,
        plannedDuration: const Duration(minutes: 30),
      ),
    );
    await controller.refreshReports();

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpShell(tester);

    final promptResult = Completer<PwaInstallPromptOutcome>();
    installBridge.nextPromptResult = promptResult;
    await tester.tap(find.byKey(InstallAppAction.compactButtonKey));
    await tester.pump();
    expect(installService.state, PwaInstallState.installing);
    expect(controller.isPresenceMonitoringSuppressed, isTrue);

    await controller.handleLifecycleState(AppLifecycleState.hidden);
    expect(monitor.pendingAbsence, isNull);
    expect(await repository.loadPendingAbsence(), isNull);

    promptResult.complete(PwaInstallPromptOutcome.dismissed);
    await tester.pump();
    await tester.pump();
    expect(controller.isPresenceMonitoringSuppressed, isTrue);

    await controller.handleLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(controller.isPresenceMonitoringSuppressed, isFalse);
    expect(await repository.loadIncidents('active-session'), isEmpty);
  });
}

final class _FakePwaInstallBridge implements PwaInstallBridge {
  _FakePwaInstallBridge(this.snapshot);

  final PwaInstallSnapshot snapshot;
  final StreamController<PwaInstallBridgeEvent> _events =
      StreamController<PwaInstallBridgeEvent>.broadcast(sync: true);
  Completer<PwaInstallPromptOutcome>? nextPromptResult;
  bool _disposed = false;

  @override
  Stream<PwaInstallBridgeEvent> get events => _events.stream;

  void emit(PwaInstallBridgeEvent event) {
    _events.add(event);
  }

  @override
  Future<PwaInstallSnapshot> initialize() async => snapshot;

  @override
  Future<PwaInstallPromptOutcome> promptInstall() async {
    return nextPromptResult?.future ?? PwaInstallPromptOutcome.dismissed;
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    unawaited(_events.close());
  }
}
