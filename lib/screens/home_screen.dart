import 'package:flutter/material.dart';
import '../widgets/settings/settings_dialog.dart';
import '../managers/sound_manager.dart';
import '../ads/ad_rewarded.dart';
import '../game/ui/game_screen.dart'; // ✅ 게임 스크린 import 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AdRewardedService.loadRewardedAd();
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()), // ✅ 게임 화면 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Koofy Universe!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startGame,
                child: const Text("🎮 게임 시작"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AdRewardedService.showRewardedAd(
                    onReward: () => debugPrint("✅ Reward granted"),
                    onFail: () => debugPrint("❌ Reward failed"),
                  );
                },
                child: const Text("🎁 보상형 광고 보기"),
              ),
            ],
          ),

          // 🔹 오른쪽 하단 플로팅 사이드 버튼
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'settings',
                  backgroundColor: Colors.blueAccent,
                  onPressed: _openSettingsDialog,
                  child: const Icon(Icons.settings),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'shop',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    // 상점 연결 등 다른 메뉴 추가 가능
                  },
                  child: const Icon(Icons.store),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}