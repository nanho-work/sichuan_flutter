import 'package:flutter/material.dart';
import '../managers/sound_manager.dart';
import '../ads/ad_banner.dart'; // ✅ 배너 광고 서비스
import '../widgets/app_header.dart';  // ✅ 상단 헤더 추가
import 'home_screen.dart';
import 'store_screen.dart';
import 'inventory_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  final sound = SoundManager();
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    StoreScreen(),
    InventoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdBannerService.loadBannerAd(
      onLoaded: () => setState(() {}),
      onFailed: (error) => debugPrint("Banner load failed: $error"),
    );
    if (!sound.isPlayingBGM) {
      sound.playBGM('home_theme.mp3'); // ✅ 배경음 한 번만 실행
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdBannerService.dispose(); // 광고 리소스 정리
    sound.stopBGM(); // BGM 정리
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
      backgroundColor: Colors.black, // 전체 배경 톤
      body: Column(
        children: [
          // ✅ 하단 광고 배너 (위로 이동)
          AdBannerService.bannerWidget(),

          // ✅ 상단 헤더
          const AppHeader(),

          // ✅ 메인 화면 영역
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey.shade900,
        indicatorColor: Colors.blueAccent.shade200.withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          sound.playSFX('pageturn.mp3');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.store), label: '상점'),
          NavigationDestination(icon: Icon(Icons.inventory), label: '인벤토리'),
        ],
      ),
    );
  }
}