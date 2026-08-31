@JS()
library;

import 'dart:async';
import 'dart:js_interop';

import '../domain/pwa_install_models.dart';
import 'pwa_install_bridge.dart';

PwaInstallBridge createPlatformPwaInstallBridge() {
  return WebPwaInstallBridge();
}

/// Dart adapter for the early-loading JavaScript browser event bridge.
final class WebPwaInstallBridge implements PwaInstallBridge {
  final StreamController<PwaInstallBridgeEvent> _events =
      StreamController<PwaInstallBridgeEvent>.broadcast(sync: true);

  _WebPwaInstallApi? _api;
  JSFunction? _listener;
  bool _disposed = false;

  @override
  Stream<PwaInstallBridgeEvent> get events => _events.stream;

  @override
  Future<PwaInstallSnapshot> initialize() async {
    if (_disposed) {
      return const PwaInstallSnapshot.unavailable();
    }

    final api = _browserInstallApi;
    if (api == null) {
      return const PwaInstallSnapshot.unavailable();
    }

    if (_listener == null) {
      void handleBrowserEvent(JSString eventName) {
        if (_disposed) {
          return;
        }
        switch (eventName.toDart) {
          case 'promptAvailable':
            _events.add(PwaInstallBridgeEvent.promptAvailable);
          case 'installed':
            _events.add(PwaInstallBridgeEvent.installed);
        }
      }

      final listener = handleBrowserEvent.toJS;
      api.subscribe(listener);
      _listener = listener;
    }
    _api = api;

    final snapshot = api.getSnapshot();
    return PwaInstallSnapshot(
      isInstalled: snapshot.installed,
      isIos: snapshot.ios,
      canPrompt: snapshot.canPrompt,
    );
  }

  @override
  Future<PwaInstallPromptOutcome> promptInstall() async {
    final api = _api;
    if (_disposed || api == null) {
      return PwaInstallPromptOutcome.unavailable;
    }

    final result = await api.promptInstall().toDart;
    return switch (result.outcome) {
      'accepted' => PwaInstallPromptOutcome.accepted,
      'dismissed' => PwaInstallPromptOutcome.dismissed,
      _ => PwaInstallPromptOutcome.unavailable,
    };
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    final api = _api;
    final listener = _listener;
    if (api != null && listener != null) {
      api.unsubscribe(listener);
    }
    _api = null;
    _listener = null;
    unawaited(_events.close());
  }
}

@JS('unitConverterPwaInstallBridge')
external _WebPwaInstallApi? get _browserInstallApi;

extension type _WebPwaInstallApi(JSObject _) implements JSObject {
  external _WebPwaInstallSnapshot getSnapshot();
  external void subscribe(JSFunction listener);
  external void unsubscribe(JSFunction listener);
  external JSPromise<_WebPromptResult> promptInstall();
}

extension type _WebPwaInstallSnapshot(JSObject _) implements JSObject {
  external bool get installed;
  external bool get ios;
  external bool get canPrompt;
}

extension type _WebPromptResult(JSObject _) implements JSObject {
  external String get outcome;
}
