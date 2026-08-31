import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/pwa_install/pwa_install.dart';

void main() {
  group('PwaInstallService initialization', () {
    test('uses installed as the highest-priority snapshot state', () async {
      final bridge = _FakePwaInstallBridge(
        snapshot: const PwaInstallSnapshot(
          isInstalled: true,
          isIos: true,
          canPrompt: true,
        ),
      );
      final service = PwaInstallService(bridge: bridge);

      await service.initialize();

      expect(service.state, PwaInstallState.installed);
      expect(service.canPrompt, isFalse);
      service.dispose();
    });

    test('uses manual-install state for iOS browser mode', () async {
      final bridge = _FakePwaInstallBridge(
        snapshot: const PwaInstallSnapshot(
          isInstalled: false,
          isIos: true,
          canPrompt: false,
        ),
      );
      final service = PwaInstallService(bridge: bridge);

      await service.initialize();

      expect(service.state, PwaInstallState.iosManualInstall);
      expect(
        await service.promptInstall(),
        PwaInstallPromptOutcome.unavailable,
      );
      expect(service.state, PwaInstallState.iosManualInstall);
      expect(bridge.promptCalls, 0);
      service.dispose();
    });

    test('reports an available captured prompt', () async {
      final bridge = _FakePwaInstallBridge(
        snapshot: const PwaInstallSnapshot(
          isInstalled: false,
          isIos: false,
          canPrompt: true,
        ),
      );
      final service = PwaInstallService(bridge: bridge);

      await service.initialize();

      expect(service.state, PwaInstallState.available);
      expect(service.canPrompt, isTrue);
      service.dispose();
    });

    test('is idempotent and initializes its bridge once', () async {
      final bridge = _FakePwaInstallBridge();
      final service = PwaInstallService(bridge: bridge);

      await Future.wait(<Future<void>>[
        service.initialize(),
        service.initialize(),
        service.initialize(),
      ]);

      expect(bridge.initializeCalls, 1);
      expect(service.state, PwaInstallState.unavailable);
      service.dispose();
    });

    test('native platform factory compiles and reports unavailable', () async {
      final service = PwaInstallService.platform();

      await service.initialize();

      expect(service.state, PwaInstallState.unavailable);
      expect(
        await service.promptInstall(),
        PwaInstallPromptOutcome.unavailable,
      );
      service.dispose();
    });
  });

  group('PwaInstallService browser events', () {
    test('moves to available when beforeinstallprompt is captured', () async {
      final bridge = _FakePwaInstallBridge();
      final service = PwaInstallService(bridge: bridge);
      await service.initialize();

      bridge.emit(PwaInstallBridgeEvent.promptAvailable);

      expect(service.state, PwaInstallState.available);
      expect(service.canPrompt, isTrue);
      service.dispose();
    });

    test(
      'keeps iOS manual instructions when prompt event is unexpected',
      () async {
        final bridge = _FakePwaInstallBridge(
          snapshot: const PwaInstallSnapshot(
            isInstalled: false,
            isIos: true,
            canPrompt: false,
          ),
        );
        final service = PwaInstallService(bridge: bridge);
        await service.initialize();

        bridge.emit(PwaInstallBridgeEvent.promptAvailable);

        expect(service.state, PwaInstallState.iosManualInstall);
        service.dispose();
      },
    );

    test('appinstalled moves any live state to installed', () async {
      final bridge = _FakePwaInstallBridge();
      final service = PwaInstallService(bridge: bridge);
      await service.initialize();

      bridge.emit(PwaInstallBridgeEvent.installed);

      expect(service.state, PwaInstallState.installed);
      service.dispose();
    });
  });

  group('PwaInstallService prompt lifecycle', () {
    test(
      'exposes installing and accepted states and notifies listeners',
      () async {
        final prompt = Completer<PwaInstallPromptOutcome>();
        final promptStarted = Completer<void>();
        final bridge = _FakePwaInstallBridge(
          snapshot: const PwaInstallSnapshot(
            isInstalled: false,
            isIos: false,
            canPrompt: true,
          ),
          promptHandler: () {
            promptStarted.complete();
            return prompt.future;
          },
        );
        final service = PwaInstallService(bridge: bridge);
        final observedStates = <PwaInstallState>[];
        service.addListener(() => observedStates.add(service.state));
        await service.initialize();

        final result = service.promptInstall();
        await promptStarted.future;
        expect(service.state, PwaInstallState.installing);

        prompt.complete(PwaInstallPromptOutcome.accepted);
        expect(await result, PwaInstallPromptOutcome.accepted);
        expect(service.state, PwaInstallState.installed);
        expect(
          observedStates,
          containsAllInOrder(<PwaInstallState>[
            PwaInstallState.available,
            PwaInstallState.installing,
            PwaInstallState.installed,
          ]),
        );
        service.dispose();
      },
    );

    test(
      'coalesces concurrent taps into one one-shot browser prompt',
      () async {
        final prompt = Completer<PwaInstallPromptOutcome>();
        final promptStarted = Completer<void>();
        final bridge = _FakePwaInstallBridge(
          snapshot: const PwaInstallSnapshot(
            isInstalled: false,
            isIos: false,
            canPrompt: true,
          ),
          promptHandler: () {
            promptStarted.complete();
            return prompt.future;
          },
        );
        final service = PwaInstallService(bridge: bridge);
        await service.initialize();

        final first = service.promptInstall();
        await promptStarted.future;
        final second = service.promptInstall();
        expect(identical(first, second), isTrue);
        expect(bridge.promptCalls, 1);

        prompt.complete(PwaInstallPromptOutcome.dismissed);
        expect(await first, PwaInstallPromptOutcome.dismissed);
        expect(await second, PwaInstallPromptOutcome.dismissed);
        expect(service.state, PwaInstallState.unavailable);
        service.dispose();
      },
    );

    test('does not reuse a dismissed one-shot event', () async {
      final bridge = _FakePwaInstallBridge(
        snapshot: const PwaInstallSnapshot(
          isInstalled: false,
          isIos: false,
          canPrompt: true,
        ),
        promptHandler: () async => PwaInstallPromptOutcome.dismissed,
      );
      final service = PwaInstallService(bridge: bridge);
      await service.initialize();

      expect(await service.promptInstall(), PwaInstallPromptOutcome.dismissed);
      expect(service.state, PwaInstallState.unavailable);
      expect(
        await service.promptInstall(),
        PwaInstallPromptOutcome.unavailable,
      );
      expect(bridge.promptCalls, 1);
      service.dispose();
    });

    test(
      'appinstalled remains authoritative while a prompt resolves',
      () async {
        final prompt = Completer<PwaInstallPromptOutcome>();
        final promptStarted = Completer<void>();
        final bridge = _FakePwaInstallBridge(
          snapshot: const PwaInstallSnapshot(
            isInstalled: false,
            isIos: false,
            canPrompt: true,
          ),
          promptHandler: () {
            promptStarted.complete();
            return prompt.future;
          },
        );
        final service = PwaInstallService(bridge: bridge);
        await service.initialize();

        final result = service.promptInstall();
        await promptStarted.future;
        bridge.emit(PwaInstallBridgeEvent.installed);
        prompt.complete(PwaInstallPromptOutcome.dismissed);

        expect(await result, PwaInstallPromptOutcome.dismissed);
        expect(service.state, PwaInstallState.installed);
        service.dispose();
      },
    );

    test('converts bridge prompt failures to unavailable', () async {
      final bridge = _FakePwaInstallBridge(
        snapshot: const PwaInstallSnapshot(
          isInstalled: false,
          isIos: false,
          canPrompt: true,
        ),
        promptHandler: () => Future<PwaInstallPromptOutcome>.error(
          StateError('Browser prompt failed.'),
        ),
      );
      final service = PwaInstallService(bridge: bridge);
      await service.initialize();

      expect(
        await service.promptInstall(),
        PwaInstallPromptOutcome.unavailable,
      );
      expect(service.state, PwaInstallState.unavailable);
      service.dispose();
    });
  });

  test('dispose owns and disposes the platform bridge', () async {
    final bridge = _FakePwaInstallBridge();
    final service = PwaInstallService(bridge: bridge);
    await service.initialize();

    service.dispose();
    bridge.emit(PwaInstallBridgeEvent.installed);

    expect(bridge.disposed, isTrue);
    expect(service.state, PwaInstallState.unavailable);
  });
}

final class _FakePwaInstallBridge implements PwaInstallBridge {
  _FakePwaInstallBridge({
    this.snapshot = const PwaInstallSnapshot.unavailable(),
    this.promptHandler,
  });

  final StreamController<PwaInstallBridgeEvent> _events =
      StreamController<PwaInstallBridgeEvent>.broadcast(sync: true);
  final PwaInstallSnapshot snapshot;
  final Future<PwaInstallPromptOutcome> Function()? promptHandler;

  int initializeCalls = 0;
  int promptCalls = 0;
  bool disposed = false;

  @override
  Stream<PwaInstallBridgeEvent> get events => _events.stream;

  void emit(PwaInstallBridgeEvent event) {
    _events.add(event);
  }

  @override
  Future<PwaInstallSnapshot> initialize() async {
    initializeCalls++;
    return snapshot;
  }

  @override
  Future<PwaInstallPromptOutcome> promptInstall() {
    promptCalls++;
    return promptHandler?.call() ??
        Future<PwaInstallPromptOutcome>.value(
          PwaInstallPromptOutcome.unavailable,
        );
  }

  @override
  void dispose() {
    disposed = true;
  }
}
