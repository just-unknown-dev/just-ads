library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import 'just_ads_types.dart';

/// Loads, caches, and shows [gma.RewardedAd]s.
class RewardedAdManager {
  gma.RewardedAd? _cachedAd;
  bool _isShowing = false;

  bool get isReady => _cachedAd != null && !_isShowing;

  Future<void> preload(String adUnitId) async {
    _cachedAd?.dispose();
    _cachedAd = null;

    final completer = Completer<void>();

    await gma.RewardedAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      rewardedAdLoadCallback: gma.RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedAd = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAdManager: load failed (${error.message})');
          completer.complete();
        },
      ),
    );

    await completer.future;
  }

  /// Shows the cached rewarded ad.
  ///
  /// Returns the [JustRewardItem] if the user earns a reward, or `null` if
  /// the ad was dismissed before earning or was not ready.
  Future<JustRewardItem?> show() async {
    if (!isReady) return null;

    final completer = Completer<JustRewardItem?>();

    _cachedAd!.fullScreenContentCallback = gma.FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowing = false;
        ad.dispose();
        _cachedAd = null;
        if (!completer.isCompleted) completer.complete(null);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAdManager: show failed (${error.message})');
        _isShowing = false;
        ad.dispose();
        _cachedAd = null;
        if (!completer.isCompleted) completer.complete(null);
      },
    );

    await _cachedAd!.show(
      onUserEarnedReward: (_, gma.RewardItem reward) {
        if (!completer.isCompleted) {
          completer.complete(
            JustRewardItem(
              type: reward.type,
              amount: reward.amount.toInt(),
            ),
          );
        }
      },
    );

    return completer.future;
  }

  void dispose() {
    _cachedAd?.dispose();
    _cachedAd = null;
  }
}
