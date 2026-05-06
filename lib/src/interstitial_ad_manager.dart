library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

/// Loads, caches, and shows [gma.InterstitialAd]s.
class InterstitialAdManager {
  gma.InterstitialAd? _cachedAd;
  bool _isShowing = false;

  bool get isReady => _cachedAd != null && !_isShowing;

  Future<void> preload(String adUnitId) async {
    _cachedAd?.dispose();
    _cachedAd = null;

    final completer = Completer<void>();

    await gma.InterstitialAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      adLoadCallback: gma.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          _cachedAd!.fullScreenContentCallback =
              gma.FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) => _isShowing = true,
            onAdDismissedFullScreenContent: (ad) {
              _isShowing = false;
              ad.dispose();
              _cachedAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                  'InterstitialAdManager: show failed (${error.message})');
              _isShowing = false;
              ad.dispose();
              _cachedAd = null;
            },
          );
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              'InterstitialAdManager: load failed (${error.message})');
          completer.complete();
        },
      ),
    );

    await completer.future;
  }

  Future<bool> show() async {
    if (!isReady) return false;
    _isShowing = true;
    await _cachedAd!.show();
    return true;
  }

  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
  }
}
