import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// ✅ 배너 광고 관리 서비스
/// 화면 하단 또는 원하는 위치에 상시 노출
class AdBannerService {
  static BannerAd? _bannerAd;
  static bool _isLoaded = false;

  // Game banner ad support
  static BannerAd? _gameBannerAd;
  static bool _isGameBannerLoaded = false;

  /// 배너 광고 로드
  static Future<void> loadBannerAd({
    required VoidCallback onLoaded,
    required Function(LoadAdError) onFailed,
  }) async {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/8719401847', // 🔹 실제 광고 ID (배너)
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoaded = false;
          onFailed(error);
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// 게임 배너 광고 로드
  static Future<void> loadGameBannerAd({
    required VoidCallback onLoaded,
    required Function(LoadAdError) onFailed,
  }) async {
    _gameBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/6426992860', // 🔹 게임용 광고 ID (배너)
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isGameBannerLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isGameBannerLoaded = false;
          onFailed(error);
        },
      ),
    );
    await _gameBannerAd!.load();
  }

  /// 배너 위젯 반환
  static Widget bannerWidget() {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        color: Colors.transparent,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  /// 게임 배너 위젯 반환
  static Widget gameBannerWidget() {
    if (!_isGameBannerLoaded || _gameBannerAd == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: _gameBannerAd!.size.width.toDouble(),
        height: _gameBannerAd!.size.height.toDouble(),
        color: Colors.transparent,
        child: AdWidget(ad: _gameBannerAd!),
      ),
    );
  }

  /// 배너 광고 리소스 정리
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
  /// 게임 배너 광고 리소스 정리
  static void disposeGameBanner() {
    _gameBannerAd?.dispose();
    _gameBannerAd = null;
    _isGameBannerLoaded = false;
  }
}