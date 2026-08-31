enum PwaInstallState {
  unavailable,
  available,
  installing,
  installed,
  iosManualInstall,
}

enum PwaInstallPromptOutcome { accepted, dismissed, unavailable }

enum PwaInstallBridgeEvent { promptAvailable, installed }

/// Browser capability snapshot captured when install monitoring starts.
final class PwaInstallSnapshot {
  const PwaInstallSnapshot({
    required this.isInstalled,
    required this.isIos,
    required this.canPrompt,
  });

  const PwaInstallSnapshot.unavailable()
    : isInstalled = false,
      isIos = false,
      canPrompt = false;

  final bool isInstalled;
  final bool isIos;
  final bool canPrompt;
}
