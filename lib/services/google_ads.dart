import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds  {
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

/*
  //TEST IDs
  final interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
  final bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';
 */

  //App IDs
  final interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-4137620141469367/2691860878'
      : 'ca-app-pub-4137620141469367/6220042348';
  final bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-4137620141469367/6554497530'
      : 'ca-app-pub-4137620141469367/5349227071';


  void loadInterstitialAd({bool showAfterLoad = false}) {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
            //if(showAfterLoad) showInterstitialAd();
            interstitialAd!.show();
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showInterstitialAd () {
    if(interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  /// Loads a banner ad.
  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }


}