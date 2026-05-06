# Just Ads

Mobile ads for Flutter apps using `google_mobile_ads`, with built-in UMP consent support.

`just_ads` provides a single manager API for:

- Banner ads
- Interstitial ads
- Rewarded ads
- App Open ads
- GDPR/UMP consent flow

## Features

- Simple `JustAdsManager` setup and lifecycle handling
- Google official test ad unit IDs available out of the box
- UMP consent request before SDK initialization (policy-safe order)
- Typed config models for ad formats and consent
- Optional automatic App Open show on app foreground

## Platform support

- Android
- iOS

This package is intended for mobile ad integrations. For non-mobile platforms, skip initialization and ad calls.

## Getting started

1. Add dependency:

```yaml
dependencies:
	just_ads:
		path: ../just_ads
```

2. Ensure your app is configured for Google Mobile Ads:

- Android: add your AdMob app ID in `AndroidManifest.xml`.
- iOS: add your AdMob app ID in `Info.plist`.

3. Initialize ads once on app startup (or your app's bootstrap phase).

## Quick start

```dart
import 'dart:io';

import 'package:just_ads/just_ads.dart';

Future<JustAdsManager?> initializeAds() async {
	if (!(Platform.isAndroid || Platform.isIOS)) {
		return null;
	}

	final ads = JustAdsManager(
		config: const JustAdsConfig(
			bannerAdUnitId: JustAdsConfig.testBannerAdUnitId,
			interstitialAdUnitId: JustAdsConfig.testInterstitialAdUnitId,
			rewardedAdUnitId: JustAdsConfig.testRewardedAdUnitId,
			appOpenAdUnitId: JustAdsConfig.testAppOpenAdUnitId,
			testMode: true,
		),
	);

	await ads.initialize(
		consent: const JustConsentConfig(
			testMode: true,
			debugGeography: true,
		),
	);

	await ads.preloadInterstitialAd(ads.config.resolvedInterstitialAdUnitId);
	await ads.preloadRewardedAd(ads.config.resolvedRewardedAdUnitId);
	await ads.preloadAppOpenAd(ads.config.resolvedAppOpenAdUnitId);

	return ads;
}
```

## Banner usage

```dart
final banner = await ads.createBannerAd(
	JustBannerAdConfig(
		adUnitId: ads.config.resolvedBannerAdUnitId,
		size: JustAdSize.adaptive,
	),
);

// Add banner?.widget to your widget tree, and call banner?.dispose() when done.
```

## Interstitial usage

```dart
if (ads.isInterstitialAdReady) {
	await ads.showInterstitialAd();
}
```

## Rewarded usage

```dart
final reward = await ads.showRewardedAd();
if (reward != null) {
	// Grant reward.amount of reward.type
}
```

## App Open behavior

If `showAppOpenOnForeground` is `true` (default), `JustAdsManager` listens to app lifecycle and automatically attempts to show an App Open ad when the app resumes.

You can also show manually:

```dart
await ads.showAppOpenAd();
```

## Example

See `example/example.dart` in this package for a complete runnable sample UI.

## Contributing

Please read:

- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`

## License

BSD-3-Clause. See `LICENSE`.
