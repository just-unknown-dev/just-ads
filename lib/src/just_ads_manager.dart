library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import 'app_open_ad_manager.dart';
import 'banner_ad_manager.dart';
import 'interstitial_ad_manager.dart';
import 'just_ads_config.dart';
import 'just_ads_types.dart';
import 'rewarded_ad_manager.dart';
import 'ump_manager.dart';

/// Standalone mobile ads manager backed by `google_mobile_ads`.
///
/// Not tied to any engine framework — use it independently or bridge it to
/// an engine via an adapter (see `just_game_engine` integration example).
///
/// Implements [WidgetsBindingObserver] to detect app foreground transitions
/// and show App Open ads automatically when [showAppOpenOnForeground] is `true`.
///
/// **Usage** (mobile only):
/// ```dart
/// final manager = JustAdsManager(
///   config: JustAdsConfig(
///     bannerAdUnitId: JustAdsConfig.testBannerAdUnitId,
///     interstitialAdUnitId: JustAdsConfig.testInterstitialAdUnitId,
///     rewardedAdUnitId: JustAdsConfig.testRewardedAdUnitId,
///     appOpenAdUnitId: JustAdsConfig.testAppOpenAdUnitId,
///     testMode: true,
///   ),
/// );
/// await manager.initialize(
///   consent: JustConsentConfig(testMode: true, debugGeography: true),
/// );
/// await manager.preloadInterstitialAd(manager.config.resolvedInterstitialAdUnitId);
/// ```
class JustAdsManager with WidgetsBindingObserver {
  JustAdsManager({
    required this.config,
    this.showAppOpenOnForeground = true,
    void Function(JustConsentStatus status)? onConsentStatusChanged,
  }) : _onConsentStatusChanged = onConsentStatusChanged;

  final JustAdsConfig config;

  /// When `true`, app-open ads show automatically when the app is foregrounded.
  final bool showAppOpenOnForeground;

  final void Function(JustConsentStatus status)? _onConsentStatusChanged;

  late final UmpManager _umpManager = UmpManager(
    onConsentStatusChanged: (status) {
      _consentStatus = status;
      _onConsentStatusChanged?.call(status);
    },
  );

  final BannerAdManager _bannerManager = BannerAdManager();
  final InterstitialAdManager _interstitialManager = InterstitialAdManager();
  final RewardedAdManager _rewardedManager = RewardedAdManager();
  final AppOpenAdManager _appOpenManager = AppOpenAdManager();

  bool _initialized = false;
  JustConsentStatus _consentStatus = JustConsentStatus.unknown;

  /// The most recently resolved consent status.
  ///
  /// Meaningful after [initialize] completes. Returns [JustConsentStatus.unknown]
  /// before initialization or if UMP was skipped.
  JustConsentStatus get consentStatus => _consentStatus;

  bool get isInitialized => _initialized;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Initialisation sequence (MUST follow this order per Google policy):
  ///
  /// 1. Request UMP consent.
  /// 2. Configure [gma.RequestConfiguration] (COPPA, content rating).
  /// 3. Call [gma.MobileAds.instance.initialize()].
  Future<void> initialize({JustConsentConfig? consent}) async {
    if (_initialized) return;

    // Step 1: UMP consent — MUST come before SDK init.
    if (consent != null) {
      await _umpManager.requestConsent(consent);
    }

    // Step 2: SDK request configuration.
    await gma.MobileAds.instance.updateRequestConfiguration(
      gma.RequestConfiguration(
        testDeviceIds: config.testDeviceIds,
        tagForChildDirectedTreatment: config.tagForChildDirectedTreatment
            ? gma.TagForChildDirectedTreatment.yes
            : gma.TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: config.tagForUnderAgeOfConsent
            ? gma.TagForUnderAgeOfConsent.yes
            : gma.TagForUnderAgeOfConsent.unspecified,
        maxAdContentRating: _mapContentRating(config.maxAdContentRating),
      ),
    );

    // Step 3: SDK initialization.
    await gma.MobileAds.instance.initialize();

    _initialized = true;

    // Register lifecycle observer for App Open ads.
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialManager.dispose();
    _rewardedManager.dispose();
    _appOpenManager.dispose();
    _initialized = false;
  }

  // ── WidgetsBindingObserver ─────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized || !showAppOpenOnForeground) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_appOpenManager.show());
    }
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  Future<JustBannerAdInstance?> createBannerAd(JustBannerAdConfig config) =>
      _bannerManager.createBannerAd(config);

  // ── Interstitial ───────────────────────────────────────────────────────────

  Future<void> preloadInterstitialAd(String adUnitId) =>
      _interstitialManager.preload(adUnitId);

  Future<bool> showInterstitialAd() => _interstitialManager.show();

  bool get isInterstitialAdReady => _interstitialManager.isReady;

  // ── Rewarded ───────────────────────────────────────────────────────────────

  Future<void> preloadRewardedAd(String adUnitId) =>
      _rewardedManager.preload(adUnitId);

  Future<JustRewardItem?> showRewardedAd() => _rewardedManager.show();

  bool get isRewardedAdReady => _rewardedManager.isReady;

  // ── App Open ───────────────────────────────────────────────────────────────

  Future<void> preloadAppOpenAd(String adUnitId) =>
      _appOpenManager.preload(adUnitId);

  Future<bool> showAppOpenAd() => _appOpenManager.show();

  bool get isAppOpenAdReady => _appOpenManager.isReady;

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _mapContentRating(MaxAdContentRating rating) {
    return switch (rating) {
      MaxAdContentRating.general => gma.MaxAdContentRating.g,
      MaxAdContentRating.parentalGuidance => gma.MaxAdContentRating.pg,
      MaxAdContentRating.teen => gma.MaxAdContentRating.t,
      MaxAdContentRating.matureAudience => gma.MaxAdContentRating.ma,
    };
  }
}
