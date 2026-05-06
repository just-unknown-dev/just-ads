library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import 'just_ads_types.dart';

/// Creates and wraps [gma.BannerAd] instances as [JustBannerAdInstance].
class BannerAdManager {
  /// Creates and loads a banner ad from [config].
  ///
  /// Returns `null` on load failure or timeout.
  Future<JustBannerAdInstance?> createBannerAd(JustBannerAdConfig config) async {
    gma.AdSize adSize;

    if (config.size.isAdaptive) {
      final screenWidth =
          PlatformDispatcher.instance.views.first.physicalSize.width ~/
          PlatformDispatcher.instance.views.first.devicePixelRatio;
      final anchored =
          await gma.AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        screenWidth.toInt(),
      );
      adSize = anchored ?? gma.AdSize.banner;
    } else {
      adSize = gma.AdSize(width: config.size.width, height: config.size.height);
    }

    final completer = Completer<JustBannerAdInstance?>();
    gma.BannerAd? banner;

    banner = gma.BannerAd(
      adUnitId: config.adUnitId,
      size: adSize,
      request: const gma.AdRequest(),
      listener: gma.BannerAdListener(
        onAdLoaded: (_) {
          if (!completer.isCompleted) {
            completer.complete(
              JustBannerAdInstance(
                widget: gma.AdWidget(ad: banner!),
                dispose: () => banner!.dispose(),
                actualSize: JustAdSize(
                  width: adSize.width,
                  height: adSize.height,
                ),
              ),
            );
          }
        },
        onAdFailedToLoad: (_, error) {
          debugPrint('BannerAdManager: load failed (${error.message})');
          banner?.dispose();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    await banner.load();

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        banner?.dispose();
        return null;
      },
    );
  }
}
