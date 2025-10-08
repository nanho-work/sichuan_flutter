import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../managers/sound_manager.dart';

/// ✅ 보상형 광고 관리 서비스 (우회 방지 강화)
class AdRewardedService with WidgetsBindingObserver {
  static RewardedAd? _rewardedAd;
  static bool _isLoaded = false;
  static bool _rewardGiven = false;
  static bool _isAdPlaying = false;

  /// 광고 로드
  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: 'ca-app-pub-5773331970563455/7406320175', // 🔹 실제 광고 ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('🎬 보상형 광고 시작');
              _isAdPlaying = true;
              _rewardGiven = false;
              SoundManager().pauseBGM();
              WidgetsBinding.instance.addObserver(AdRewardedService());
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('✅ 광고 종료');
              _isAdPlaying = false;
              SoundManager().resumeBGM();
              WidgetsBinding.instance.removeObserver(AdRewardedService());
              ad.dispose();
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ 광고 표시 실패: $error');
              _isAdPlaying = false;
              WidgetsBinding.instance.removeObserver(AdRewardedService());
              ad.dispose();
              loadRewardedAd();
            },
          );

          debugPrint("✅ Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Rewarded Ad Failed to Load: $error");
          _rewardedAd = null;
          _isLoaded = false;
        },
      ),
    );
  }

  /// 광고 표시 (보상 지급 포함)
  static void showRewardedAd({
    required Function onReward,
    Function? onFail,
  }) {
    if (!_isLoaded || _rewardedAd == null) {
      debugPrint("⚠️ 보상형 광고가 아직 로드되지 않음");
      if (onFail != null) onFail();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (!_rewardGiven) {
          _rewardGiven = true;
          debugPrint("🎁 보상 지급 완료");
          onReward();
        }
      },
    );

    _rewardedAd = null;
    _isLoaded = false;
  }

  /// 앱 라이프사이클 감지 — 광고 도중 백그라운드 진입 시 리워드 방지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isAdPlaying && state == AppLifecycleState.paused) {
      debugPrint("⚠️ 광고 도중 앱이 백그라운드로 이동 — 리워드 차단 플래그 유지");
      _rewardGiven = true; // 광고 중 앱을 벗어나면 보상 차단
    }
  }

  /// 광고 리소스 정리
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
    _rewardGiven = false;
    _isAdPlaying = false;
    WidgetsBinding.instance.removeObserver(AdRewardedService());
  }
}