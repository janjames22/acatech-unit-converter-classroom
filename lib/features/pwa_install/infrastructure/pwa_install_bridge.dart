import '../domain/pwa_install_models.dart';

/// Platform boundary used by [PwaInstallService].
///
/// The browser implementation is selected through a conditional import. Native
/// targets receive an unavailable stub and never import JavaScript libraries.
abstract interface class PwaInstallBridge {
  Stream<PwaInstallBridgeEvent> get events;

  Future<PwaInstallSnapshot> initialize();

  Future<PwaInstallPromptOutcome> promptInstall();

  void dispose();
}
