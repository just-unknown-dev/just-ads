library;

/// All configuration needed by [JustAdsProvider].
class JustAdsConfig {
  const JustAdsConfig({
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.appOpenAdUnitId,
    this.testMode = false,
    this.testDeviceIds = const [],
    this.tagForChildDirectedTreatment = false,
    this.tagForUnderAgeOfConsent = false,
    this.maxAdContentRating = MaxAdContentRating.general,
  });

  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final String appOpenAdUnitId;

  /// When `true`, test ad unit IDs are used regardless of the IDs provided above.
  final bool testMode;

  /// Device IDs (MD5 hash of IDFA/GAID) that receive test ads.
  final List<String> testDeviceIds;

  final bool tagForChildDirectedTreatment;
  final bool tagForUnderAgeOfConsent;
  final MaxAdContentRating maxAdContentRating;

  // ── Google official test ad unit IDs ───────────────────────────────────────

  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  // ── Resolved IDs (substitutes test IDs when testMode == true) ─────────────

  String get resolvedBannerAdUnitId =>
      testMode ? testBannerAdUnitId : bannerAdUnitId;

  String get resolvedInterstitialAdUnitId =>
      testMode ? testInterstitialAdUnitId : interstitialAdUnitId;

  String get resolvedRewardedAdUnitId =>
      testMode ? testRewardedAdUnitId : rewardedAdUnitId;

  String get resolvedAppOpenAdUnitId =>
      testMode ? testAppOpenAdUnitId : appOpenAdUnitId;
}

/// Maximum ad content rating. Maps to [gma.MaxAdContentRating] string constants.
enum MaxAdContentRating { general, parentalGuidance, teen, matureAudience }
