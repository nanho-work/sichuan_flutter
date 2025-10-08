import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// ✅ 배너 광고 관리 서비스
/// 화면 하단 또는 원하는 위치에 상시 노출
class AdBannerService {
  static BannerAd? _bannerAd;
  static bool _isLoaded = false;

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

  /// 배너 광고 리소스 정리
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
}