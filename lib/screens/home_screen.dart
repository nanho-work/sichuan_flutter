import 'package:flutter/material.dart';
import '../widgets/settings/settings_dialog.dart';
import '../managers/sound_manager.dart';
import '../ads/ad_rewarded.dart';
import '../game/ui/stage_select_screen.dart'; // ✅ 추가

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
    showDialog(context: context, builder: (_) => const SettingsDialog());
  }

  void _openStageSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StageSelectScreen()),
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
              const Text('Welcome to Koofy Universe!', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openStageSelect,
                child: const Text("🎯 스테이지 선택"),
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
                  onPressed: () {},
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