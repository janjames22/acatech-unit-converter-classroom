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

    const widths = <double>[360, 390, 430, 768, 1024, 1366, 1920];
    tester.view.physicalSize = const Size(360, 900);
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

  testWidgets('internal navigation keeps monitor and creates no incident', (
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
    final originalMonitor = controller.monitor;

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await pumpShell(tester);

    await tester.tap(find.text('Assessment').last);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Home').last);
    await tester.pump(const Duration(milliseconds: 500));

    expect(identical(controller.monitor, originalMonitor), isTrue);
    expect(await repository.loadIncidents('active-session'), isEmpty);
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
