library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

/// Loads, caches, and shows [gma.AppOpenAd]s.
///
/// App Open ads expire after 4 hours. [isReady] enforces this TTL by tracking
/// the load timestamp — the SDK does not expose an expiry check.
///
/// [AppOpenAdManager] does NOT register a [WidgetsBindingObserver] itself.
/// [JustAdsProvider] owns the lifecycle observer and calls [show] on foreground.
class AppOpenAdManager {
  gma.AppOpenAd? _cachedAd;
  DateTime? _loadTime;
  bool _isShowing = false;

  static const Duration _adExpiry = Duration(hours: 4);

  bool get isReady {
    if (_cachedAd == null || _isShowing) return false;
    final loaded = _loadTime;
    if (loaded == null) return false;
    return DateTime.now().difference(loaded) < _adExpiry;
  }

  Future<void> preload(String adUnitId) async {
    if (isReady) return;
    _cachedAd?.dispose();
    _cachedAd = null;
    _loadTime = null;

    final completer = Completer<void>();

    gma.AppOpenAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      adLoadCallback: gma.AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _loadTime = DateTime.now();
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAdManager: load failed (${error.message})');
          completer.complete();
        },
      ),
    );

    await completer.future;
  }

  Future<bool> show() async {
    if (!isReady) return false;

    final completer = Completer<bool>();

    _cachedAd!.fullScreenContentCallback = gma.FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowing = false;
        ad.dispose();
        _cachedAd = null;
        _loadTime = null;
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAdManager: show failed (${error.message})');
        _isShowing = false;
        ad.dispose();
        _cachedAd = null;
        _loadTime = null;
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _cachedAd!.show();
    return completer.future;
  }

  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
    _loadTime = null;
  }
}
