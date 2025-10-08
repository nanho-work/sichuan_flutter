import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ad_banner.dart';
import '../ads/ad_rewarded.dart';
import 'sound_manager.dart';

/// ✅ 광고 중앙 제어 매니저
/// 배너 & 리워드 광고를 통합 제어하며 사운드 / 정책 / 쿨타임 관리
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  DateTime? _lastRewardTime;
  bool isRewardCoolingDown = false;

  /// 광고 시스템 초기화
  Future<void> initAds() async {
    await MobileAds.instance.initialize();
    debugPrint("✅ AdMob 초기화 완료");

    await AdBannerService.loadBannerAd(
      onLoaded: () => debugPrint("✅ 배너 로드 완료"),
      onFailed: (error) => debugPrint("❌ 배너 로드 실패: $error"),
    );

    await AdRewardedService.loadRewardedAd();
  }

  /// 배너 위젯 노출
  Widget bannerWidget() => AdBannerService.bannerWidget();

  /// 리워드 광고 실행
  void showRewardedAd({
    required Function onReward,
    Function? onFail,
  }) {
    // 쿨타임 30초 제한
    if (isRewardCoolingDown) {
      debugPrint("⏳ 광고 쿨타임 중입니다.");
      if (onFail != null) onFail();
      return;
    }

    AdRewardedService.showRewardedAd(
      onReward: () {
        onReward();
        _setCooldown();
      },
      onFail: onFail,
    );
  }

  /// 광고 쿨타임 관리 (30초)
  void _setCooldown() {
    _lastRewardTime = DateTime.now();
    isRewardCoolingDown = true;
    Future.delayed(const Duration(seconds: 30), () {
      isRewardCoolingDown = false;
      debugPrint("🕒 리워드 광고 쿨타임 해제");
    });
  }

  /// 광고 리소스 해제
  void dispose() {
    AdBannerService.dispose();
    AdRewardedService.dispose();
    debugPrint("🧹 모든 광고 리소스 해제");
  }
}