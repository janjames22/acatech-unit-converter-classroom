import '../domain/pwa_install_models.dart';
import 'pwa_install_bridge.dart';

PwaInstallBridge createPlatformPwaInstallBridge() {
  return const UnavailablePwaInstallBridge();
}

/// Native and unsupported-platform implementation.
final class UnavailablePwaInstallBridge implements PwaInstallBridge {
  const UnavailablePwaInstallBridge();

  @override
  Stream<PwaInstallBridgeEvent> get events =>
      const Stream<PwaInstallBridgeEvent>.empty();

  @override
  Future<PwaInstallSnapshot> initialize() async {
    return const PwaInstallSnapshot.unavailable();
  }

  @override
  Future<PwaInstallPromptOutcome> promptInstall() async {
    return PwaInstallPromptOutcome.unavailable;
  }

  @override
  void dispose() {}
}
