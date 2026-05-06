import 'package:flutter_test/flutter_test.dart';
import 'package:just_ads/just_ads.dart';

void main() {
  group('JustAdsConfig', () {
    test('resolvedAdUnitIds return production IDs when testMode is false', () {
      const config = JustAdsConfig(
        bannerAdUnitId: 'banner-prod',
        interstitialAdUnitId: 'inter-prod',
        rewardedAdUnitId: 'rewarded-prod',
        appOpenAdUnitId: 'appopen-prod',
      );

      expect(config.resolvedBannerAdUnitId, 'banner-prod');
      expect(config.resolvedInterstitialAdUnitId, 'inter-prod');
      expect(config.resolvedRewardedAdUnitId, 'rewarded-prod');
      expect(config.resolvedAppOpenAdUnitId, 'appopen-prod');
    });

    test('resolvedAdUnitIds return test IDs when testMode is true', () {
      const config = JustAdsConfig(
        bannerAdUnitId: 'banner-prod',
        interstitialAdUnitId: 'inter-prod',
        rewardedAdUnitId: 'rewarded-prod',
        appOpenAdUnitId: 'appopen-prod',
        testMode: true,
      );

      expect(config.resolvedBannerAdUnitId, JustAdsConfig.testBannerAdUnitId);
      expect(config.resolvedInterstitialAdUnitId,
          JustAdsConfig.testInterstitialAdUnitId);
      expect(
          config.resolvedRewardedAdUnitId, JustAdsConfig.testRewardedAdUnitId);
      expect(
          config.resolvedAppOpenAdUnitId, JustAdsConfig.testAppOpenAdUnitId);
    });

    test('test ad unit IDs match Google official test IDs', () {
      expect(JustAdsConfig.testBannerAdUnitId,
          'ca-app-pub-3940256099942544/6300978111');
      expect(JustAdsConfig.testInterstitialAdUnitId,
          'ca-app-pub-3940256099942544/1033173712');
      expect(JustAdsConfig.testRewardedAdUnitId,
          'ca-app-pub-3940256099942544/5224354917');
      expect(JustAdsConfig.testAppOpenAdUnitId,
          'ca-app-pub-3940256099942544/9257395921');
    });
  });
}
