import 'pwa_install_bridge.dart';
import 'pwa_install_bridge_stub.dart'
    if (dart.library.js_interop) 'pwa_install_bridge_web.dart';

PwaInstallBridge createPwaInstallBridge() {
  return createPlatformPwaInstallBridge();
}
