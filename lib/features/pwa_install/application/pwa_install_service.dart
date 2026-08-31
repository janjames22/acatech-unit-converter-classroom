import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/pwa_install_models.dart';
import '../infrastructure/pwa_install_bridge.dart';
import '../infrastructure/pwa_install_bridge_factory.dart';

/// Observable application service for the PWA installation experience.
final class PwaInstallService extends ChangeNotifier {
  factory PwaInstallService({required PwaInstallBridge bridge}) {
    return PwaInstallService._(bridge);
  }

  factory PwaInstallService.platform() {
    return PwaInstallService._(createPwaInstallBridge());
  }

  PwaInstallService._(this._bridge);

  final PwaInstallBridge _bridge;

  PwaInstallState _state = PwaInstallState.unavailable;
  StreamSubscription<PwaInstallBridgeEvent>? _eventSubscription;
  Future<void>? _initialization;
  Future<PwaInstallPromptOutcome>? _promptOperation;
  bool _initialized = false;
  bool _isIos = false;
  bool _disposed = false;

  PwaInstallState get state => _state;

  bool get canPrompt => _state == PwaInstallState.available;

  /// Starts browser capability detection and event listening once.
  Future<void> initialize() {
    if (_initialized || _disposed) {
      return Future<void>.value();
    }
    return _initialization ??= _initialize();
  }

  /// Displays the deferred browser prompt at most once per captured event.
  ///
  /// Concurrent callers share one operation. iOS manual-install and native
  /// callers receive [PwaInstallPromptOutcome.unavailable] without changing
  /// their explanatory state.
  Future<PwaInstallPromptOutcome> promptInstall() {
    final activeOperation = _promptOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = _promptInstall();
    _promptOperation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_promptOperation, operation)) {
          _promptOperation = null;
        }
      }),
    );
    return operation;
  }

  Future<void> _initialize() async {
    _eventSubscription ??= _bridge.events.listen(_handleBridgeEvent);
    try {
      final snapshot = await _bridge.initialize();
      _isIos = snapshot.isIos;
      if (_state != PwaInstallState.installed) {
        _setState(_stateForSnapshot(snapshot));
      }
    } on Object {
      _setState(PwaInstallState.unavailable);
    } finally {
      _initialized = true;
      _initialization = null;
    }
  }

  Future<PwaInstallPromptOutcome> _promptInstall() async {
    await initialize();
    if (_disposed || _state != PwaInstallState.available) {
      return PwaInstallPromptOutcome.unavailable;
    }

    _setState(PwaInstallState.installing);
    PwaInstallPromptOutcome outcome;
    try {
      outcome = await _bridge.promptInstall();
    } on Object {
      outcome = PwaInstallPromptOutcome.unavailable;
    }

    if (_state != PwaInstallState.installed) {
      switch (outcome) {
        case PwaInstallPromptOutcome.accepted:
          _setState(PwaInstallState.installed);
        case PwaInstallPromptOutcome.dismissed:
        case PwaInstallPromptOutcome.unavailable:
          _setState(
            _isIos
                ? PwaInstallState.iosManualInstall
                : PwaInstallState.unavailable,
          );
      }
    }
    return outcome;
  }

  void _handleBridgeEvent(PwaInstallBridgeEvent event) {
    if (_disposed) {
      return;
    }
    switch (event) {
      case PwaInstallBridgeEvent.promptAvailable:
        if (_state != PwaInstallState.installed && !_isIos) {
          _setState(PwaInstallState.available);
        }
      case PwaInstallBridgeEvent.installed:
        _setState(PwaInstallState.installed);
    }
  }

  PwaInstallState _stateForSnapshot(PwaInstallSnapshot snapshot) {
    if (snapshot.isInstalled) {
      return PwaInstallState.installed;
    }
    if (snapshot.isIos) {
      return PwaInstallState.iosManualInstall;
    }
    if (snapshot.canPrompt) {
      return PwaInstallState.available;
    }
    return PwaInstallState.unavailable;
  }

  void _setState(PwaInstallState value) {
    if (_disposed || value == _state) {
      return;
    }
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    final subscription = _eventSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    _eventSubscription = null;
    _bridge.dispose();
    super.dispose();
  }
}
