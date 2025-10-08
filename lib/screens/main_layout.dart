import 'package:flutter/material.dart';
import '../managers/sound_manager.dart';
import '../managers/ad_manager.dart'; // ✅ 광고 매니저 추가
import '../widgets/app_header.dart';  // ✅ 상단 헤더 추가
import 'home_screen.dart';
import 'store_screen.dart';
import 'inventory_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final sound = SoundManager();
  final ads = AdManager();
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    StoreScreen(),
    InventoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    sound.playBGM('home_theme.mp3'); // 홈 진입 BGM
    ads.initAds(); // ✅ 광고 초기화
  }

  @override
  void dispose() {
    sound.stopBGM();
    ads.dispose(); // ✅ 광고 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 전체 배경 톤
      body: Column(
        children: [
          // ✅ 상단 헤더
          const AppHeader(
            profileImage: 'assets/images/profile_default.png',
            energy: 5,
            maxEnergy: 7,
            gems: 120,
            gold: 8500,
          ),

          // ✅ 메인 화면 영역
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // ✅ 하단 광고 배너
          ads.bannerWidget(),
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