library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import 'just_ads_types.dart';

/// Manages the UMP (User Messaging Platform) GDPR consent flow.
///
/// CRITICAL ORDERING: [requestConsent] MUST complete before
/// [gma.MobileAds.instance.initialize()] is called.
class UmpManager {
  UmpManager({required this.onConsentStatusChanged});

  final void Function(JustConsentStatus status) onConsentStatusChanged;

  JustConsentStatus _status = JustConsentStatus.unknown;

  JustConsentStatus get status => _status;

  /// Runs the full UMP consent request flow.
  ///
  /// Safe to call on every cold-start — UMP caches consent; the form only
  /// appears when consent has not yet been obtained or has expired.
  Future<JustConsentStatus> requestConsent(JustConsentConfig config) async {
    try {
      final params = gma.ConsentRequestParameters();

      if (config.testMode || config.debugGeography) {
        params.consentDebugSettings = gma.ConsentDebugSettings(
          debugGeography: config.debugGeography
              ? gma.DebugGeography.debugGeographyEea
              : gma.DebugGeography.debugGeographyDisabled,
          testIdentifiers: config.testDeviceHashedIds,
        );
      }

      final updateCompleter = Completer<void>();
      gma.ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () => updateCompleter.complete(),
        (error) => updateCompleter.completeError(error),
      );
      await updateCompleter.future;

      await _loadAndShowIfRequired();

      _status = await _resolveStatus();
    } catch (e) {
      debugPrint('UmpManager: consent flow failed ($e)');
      _status = JustConsentStatus.unknown;
    }

    onConsentStatusChanged(_status);
    return _status;
  }

  Future<void> _loadAndShowIfRequired() async {
    final completer = Completer<void>();
    gma.ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    });
    await completer.future;
  }

  Future<JustConsentStatus> _resolveStatus() async {
    final canRequest =
        await gma.ConsentInformation.instance.canRequestAds();
    if (canRequest) return JustConsentStatus.obtained;

    final sdkStatus =
        await gma.ConsentInformation.instance.getConsentStatus();
    return switch (sdkStatus) {
      gma.ConsentStatus.notRequired => JustConsentStatus.notRequired,
      gma.ConsentStatus.obtained => JustConsentStatus.obtained,
      gma.ConsentStatus.required => JustConsentStatus.denied,
      _ => JustConsentStatus.unknown,
    };
  }

  void reset() {
    gma.ConsentInformation.instance.reset();
    _status = JustConsentStatus.unknown;
  }
}
