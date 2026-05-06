import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_ads/just_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JustAdsExampleApp());
}

class JustAdsExampleApp extends StatelessWidget {
  const JustAdsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'just_ads example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AdsExamplePage(),
    );
  }
}

class AdsExamplePage extends StatefulWidget {
  const AdsExamplePage({super.key});

  @override
  State<AdsExamplePage> createState() => _AdsExamplePageState();
}

class _AdsExamplePageState extends State<AdsExamplePage> {
  JustAdsManager? _ads;
  JustBannerAdInstance? _banner;
  bool _loading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _banner?.dispose();
    _ads?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _loading = false;
        _status = 'Ads are supported only on Android and iOS.';
      });
      return;
    }

    final ads = JustAdsManager(
      config: const JustAdsConfig(
        bannerAdUnitId: JustAdsConfig.testBannerAdUnitId,
        interstitialAdUnitId: JustAdsConfig.testInterstitialAdUnitId,
        rewardedAdUnitId: JustAdsConfig.testRewardedAdUnitId,
        appOpenAdUnitId: JustAdsConfig.testAppOpenAdUnitId,
        testMode: true,
      ),
      onConsentStatusChanged: (status) {
        if (!mounted) return;
        setState(() {
          _status = 'Consent: $status';
        });
      },
    );

    try {
      await ads.initialize(
        consent: const JustConsentConfig(testMode: true, debugGeography: true),
      );

      await ads.preloadInterstitialAd(ads.config.resolvedInterstitialAdUnitId);
      await ads.preloadRewardedAd(ads.config.resolvedRewardedAdUnitId);
      await ads.preloadAppOpenAd(ads.config.resolvedAppOpenAdUnitId);

      final banner = await ads.createBannerAd(
        JustBannerAdConfig(
          adUnitId: ads.config.resolvedBannerAdUnitId,
          size: JustAdSize.adaptive,
        ),
      );

      if (!mounted) {
        banner?.dispose();
        ads.dispose();
        return;
      }

      setState(() {
        _ads = ads;
        _banner = banner;
        _loading = false;
        _status = 'Ready (consent: ${ads.consentStatus})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _status = 'Initialization failed: $e';
      });
      ads.dispose();
    }
  }

  Future<void> _showInterstitial() async {
    final ads = _ads;
    if (ads == null) return;

    final shown = await ads.showInterstitialAd();
    if (!mounted) return;

    setState(() {
      _status = shown
          ? 'Interstitial shown.'
          : 'Interstitial not ready, preloading again...';
    });

    if (!shown) {
      await ads.preloadInterstitialAd(ads.config.resolvedInterstitialAdUnitId);
    }
  }

  Future<void> _showRewarded() async {
    final ads = _ads;
    if (ads == null) return;

    final reward = await ads.showRewardedAd();
    if (!mounted) return;

    if (reward == null) {
      setState(() {
        _status = 'Rewarded not ready, preloading again...';
      });
      await ads.preloadRewardedAd(ads.config.resolvedRewardedAdUnitId);
      return;
    }

    setState(() {
      _status = 'Reward earned: ${reward.amount} ${reward.type}';
    });
  }

  Future<void> _showAppOpen() async {
    final ads = _ads;
    if (ads == null) return;

    final shown = await ads.showAppOpenAd();
    if (!mounted) return;

    setState(() {
      _status = shown
          ? 'App Open shown.'
          : 'App Open not ready, preloading again...';
    });

    if (!shown) {
      await ads.preloadAppOpenAd(ads.config.resolvedAppOpenAdUnitId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('just_ads example')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_status),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _showInterstitial,
                child: const Text('Show Interstitial'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _showRewarded,
                child: const Text('Show Rewarded'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _showAppOpen,
                child: const Text('Show App Open'),
              ),
              const Spacer(),
              if (_banner != null)
                Center(child: _banner!.widget)
              else
                const Text('Banner unavailable.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
