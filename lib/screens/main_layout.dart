import 'package:flutter/material.dart';
import '../managers/sound_manager.dart';
import '../ads/ad_banner.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  final sound = SoundManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdBannerService.loadBannerAd(
      onLoaded: () => setState(() {}),
      onFailed: (error) => debugPrint("Banner load failed: $error"),
    );
    if (!sound.isPlayingBGM) {
      sound.playBGM('home_theme.mp3');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdBannerService.dispose();
    sound.stopBGM();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      sound.pauseBGM();
    } else if (state == AppLifecycleState.resumed) {
      if (!sound.isPlayingBGM) {
        sound.resumeBGM();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AdBannerService.bannerWidget(), // ✅ 상단 광고
          const AppHeader(),               // ✅ 항상 상단에 고정
          const Expanded(
            child: BottomNav(),            // ✅ 하단 네비게이션 포함한 본문
          ),
        ],
      ),
    );
  }
}