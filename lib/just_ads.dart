/// just_ads — Standalone mobile advertising (Banner, Interstitial, Rewarded,
/// App Open) with GDPR/UMP consent management.
///
/// No dependency on any game engine — use directly or bridge via an adapter.
///
/// ## Quick start
///
/// ```dart
/// import 'dart:io';
/// import 'package:just_ads/just_ads.dart';
///
/// if (Platform.isAndroid || Platform.isIOS) {
///   final manager = JustAdsManager(
///     config: JustAdsConfig(
///       bannerAdUnitId: JustAdsConfig.testBannerAdUnitId,
///       interstitialAdUnitId: JustAdsConfig.testInterstitialAdUnitId,
///       rewardedAdUnitId: JustAdsConfig.testRewardedAdUnitId,
///       appOpenAdUnitId: JustAdsConfig.testAppOpenAdUnitId,
///       testMode: true,
///     ),
///   );
///   await manager.initialize(
///     consent: JustConsentConfig(testMode: true, debugGeography: true),
///   );
///   await manager.preloadInterstitialAd(manager.config.resolvedInterstitialAdUnitId);
/// }
/// ```
library;

export 'src/ad_inspector.dart';
export 'src/just_ads_config.dart';
export 'src/just_ads_manager.dart';
export 'src/just_ads_types.dart';
