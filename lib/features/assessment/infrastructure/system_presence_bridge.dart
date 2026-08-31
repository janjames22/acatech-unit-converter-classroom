import 'dart:async';

import 'package:flutter/services.dart';

enum SystemPresenceSignal { screenOff, screenOn, deviceLocked, deviceUnlocked }

/// Receives optional native evidence that can exclude known lock/screen-off
/// transitions. Unsupported platforms simply produce no signals.
class SystemPresenceBridge {
  static const MethodChannel _channel = MethodChannel(
    'unit_converter/presence',
  );

  final StreamController<SystemPresenceSignal> _signals =
      StreamController<SystemPresenceSignal>.broadcast();
  bool _started = false;

  Stream<SystemPresenceSignal> get signals => _signals.stream;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      final value = await _channel.invokeMethod<String>('getCurrentState');
      _emit(value);
    } on MissingPluginException {
      // Web and platforms without a native adapter intentionally do nothing.
    } on PlatformException {
      // Presence monitoring still works through Flutter lifecycle callbacks.
    }
  }

  Future<void> dispose() async {
    if (!_started) {
      return;
    }
    _started = false;
    _channel.setMethodCallHandler(null);
    await _signals.close();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'presenceSignal') {
      _emit(call.arguments as String?);
    }
  }

  void _emit(String? value) {
    final signal = switch (value) {
      'screenOff' => SystemPresenceSignal.screenOff,
      'screenOn' => SystemPresenceSignal.screenOn,
      'deviceLocked' => SystemPresenceSignal.deviceLocked,
      'deviceUnlocked' => SystemPresenceSignal.deviceUnlocked,
      _ => null,
    };
    if (signal != null && !_signals.isClosed) {
      _signals.add(signal);
    }
  }
}
