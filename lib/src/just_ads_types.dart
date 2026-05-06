library;

import 'package:flutter/widgets.dart';

/// Named ad size constants used by [JustBannerAdConfig].
class JustAdSize {
  const JustAdSize({required this.width, required this.height});

  final int width;
  final int height;

  static const JustAdSize banner = JustAdSize(width: 320, height: 50);
  static const JustAdSize largeBanner = JustAdSize(width: 320, height: 100);
  static const JustAdSize mediumRectangle = JustAdSize(width: 300, height: 250);
  static const JustAdSize leaderboard = JustAdSize(width: 728, height: 90);
  static const JustAdSize fullBanner = JustAdSize(width: 468, height: 60);

  /// Sentinel — requests an anchored adaptive banner (fills screen width).
  static const JustAdSize adaptive = JustAdSize(width: -1, height: -1);

  bool get isAdaptive => width == -1 && height == -1;

  @override
  String toString() => isAdaptive ? 'adaptive' : '${width}x$height';
}

/// Configuration for creating a banner ad.
class JustBannerAdConfig {
  const JustBannerAdConfig({
    required this.adUnitId,
    this.size = JustAdSize.adaptive,
  });

  final String adUnitId;
  final JustAdSize size;
}

/// A loaded, renderable banner ad handle returned by [JustAdsManager.createBannerAd].
///
/// Embed [widget] in your widget tree. Call [dispose] when removing it.
class JustBannerAdInstance {
  const JustBannerAdInstance({
    required this.widget,
    required this.dispose,
    this.actualSize,
  });

  final Widget widget;
  final VoidCallback dispose;
  final JustAdSize? actualSize;
}

/// A reward item granted after a completed rewarded ad view.
class JustRewardItem {
  const JustRewardItem({required this.type, required this.amount});

  final String type;
  final int amount;
}

/// GDPR/UMP consent status returned by [JustAdsManager] after initialization.
enum JustConsentStatus {
  obtained,
  notRequired,
  denied,
  unknown,
}

/// Configuration for the UMP consent flow.
class JustConsentConfig {
  const JustConsentConfig({
    this.testMode = false,
    this.debugGeography = false,
    this.testDeviceHashedIds = const [],
  });

  final bool testMode;

  /// Force UMP to behave as if the device is in a GDPR geography (test only).
  final bool debugGeography;

  final List<String> testDeviceHashedIds;
}
