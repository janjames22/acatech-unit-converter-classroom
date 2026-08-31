import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/app/presentation/install_app_action.dart';
import 'package:unit_converter/features/pwa_install/pwa_install.dart';

void main() {
  testWidgets('hides unavailable state and adapts available affordance', (
    tester,
  ) async {
    final unavailable = await _pumpAction(
      tester,
      width: 390,
      snapshot: const PwaInstallSnapshot.unavailable(),
    );
    addTearDown(unavailable.dispose);
    expect(find.byKey(InstallAppAction.compactButtonKey), findsNothing);

    unavailable.dispose();
    final available = await _pumpAction(
      tester,
      width: 390,
      snapshot: _availableSnapshot,
    );
    addTearDown(available.dispose);
    expect(find.byKey(InstallAppAction.compactButtonKey), findsOneWidget);
    expect(find.byKey(InstallAppAction.labeledButtonKey), findsNothing);
    expect(find.byTooltip('Install App'), findsOneWidget);

    tester.view.physicalSize = const Size(1024, 900);
    await tester.pump();
    await tester.pumpWidget(_actionApp(service: available, compact: false));
    expect(find.byKey(InstallAppAction.compactButtonKey), findsNothing);
    expect(find.byKey(InstallAppAction.labeledButtonKey), findsOneWidget);
    expect(find.text('Install App'), findsOneWidget);
  });

  testWidgets('shows installing and installed states', (tester) async {
    final bridge = _FakePwaInstallBridge(_availableSnapshot);
    final result = Completer<PwaInstallPromptOutcome>();
    bridge.nextPromptResult = result;
    final service = PwaInstallService(bridge: bridge);
    await service.initialize();
    addTearDown(service.dispose);

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_actionApp(service: service, compact: false));

    await tester.tap(find.byKey(InstallAppAction.labeledButtonKey));
    await tester.pump();
    expect(service.state, PwaInstallState.installing);
    expect(find.text('Installing…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(InstallAppAction.labeledButtonKey))
          .onPressed,
      isNull,
    );

    result.complete(PwaInstallPromptOutcome.accepted);
    await tester.pumpAndSettle();
    expect(service.state, PwaInstallState.installed);
    expect(find.byKey(InstallAppAction.labeledButtonKey), findsNothing);
    expect(find.text('Installed'), findsNothing);
    expect(
      find.text(
        'Installation accepted. Unit Converter is being added to your device.',
      ),
      findsOneWidget,
    );
  });

  for (final width in <double>[390, 1024]) {
    testWidgets('shows polished iOS instructions at ${width.toInt()}px', (
      tester,
    ) async {
      final bridge = _FakePwaInstallBridge(_iosSnapshot);
      final service = PwaInstallService(bridge: bridge);
      await service.initialize();
      addTearDown(service.dispose);

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _actionApp(service: service, compact: width < 600),
      );

      final action = width < 600
          ? find.byKey(InstallAppAction.compactButtonKey)
          : find.byKey(InstallAppAction.labeledButtonKey);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byKey(InstallAppAction.instructionsKey), findsOneWidget);
      expect(find.text('Install Unit Converter'), findsOneWidget);
      expect(find.text('Tap the Share button'), findsOneWidget);
      expect(find.text('Choose Add to Home Screen'), findsOneWidget);
      expect(find.text('Confirm by tapping Add'), findsOneWidget);
      expect(
        find.textContaining(
          'appear on your Home Screen and can launch in its own app window',
        ),
        findsOneWidget,
      );
      expect(find.text('Got it'), findsOneWidget);
      expect(bridge.promptCalls, 0);
      expect(
        find.byType(BottomSheet),
        width < 600 ? findsOneWidget : findsNothing,
      );
      expect(find.byType(Dialog), width < 600 ? findsNothing : findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

const _availableSnapshot = PwaInstallSnapshot(
  isInstalled: false,
  isIos: false,
  canPrompt: true,
);

const _iosSnapshot = PwaInstallSnapshot(
  isInstalled: false,
  isIos: true,
  canPrompt: false,
);

Future<PwaInstallService> _pumpAction(
  WidgetTester tester, {
  required double width,
  required PwaInstallSnapshot snapshot,
}) async {
  final service = PwaInstallService(bridge: _FakePwaInstallBridge(snapshot));
  await service.initialize();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_actionApp(service: service, compact: width < 600));
  return service;
}

Widget _actionApp({required PwaInstallService service, required bool compact}) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          InstallAppAction(
            service: service,
            compact: compact,
            onPromptInstall: service.promptInstall,
          ),
        ],
      ),
    ),
  );
}

final class _FakePwaInstallBridge implements PwaInstallBridge {
  _FakePwaInstallBridge(this.snapshot);

  final PwaInstallSnapshot snapshot;
  final StreamController<PwaInstallBridgeEvent> _events =
      StreamController<PwaInstallBridgeEvent>.broadcast(sync: true);
  Completer<PwaInstallPromptOutcome>? nextPromptResult;
  int promptCalls = 0;
  bool _disposed = false;

  @override
  Stream<PwaInstallBridgeEvent> get events => _events.stream;

  @override
  Future<PwaInstallSnapshot> initialize() async => snapshot;

  @override
  Future<PwaInstallPromptOutcome> promptInstall() async {
    promptCalls++;
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
