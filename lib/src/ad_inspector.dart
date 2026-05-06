library;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

/// Opens the AdMob Ad Inspector overlay (debug helper).
///
/// No-op in release builds. The inspector requires the device to be registered
/// in the AdMob console.
///
/// Example — register as a game terminal command:
/// ```dart
/// engine.terminal.registerCommand('adInspector', (_) {
///   AdInspector.open();
///   return 'Opening Ad Inspector...';
/// });
/// ```
class AdInspector {
  const AdInspector._();

  static void open() {
    if (!kDebugMode) return;
    gma.MobileAds.instance.openAdInspector((error) {
      if (error != null) {
        debugPrint('AdInspector: failed to open (${error.message})');
      }
    });
  }
}
