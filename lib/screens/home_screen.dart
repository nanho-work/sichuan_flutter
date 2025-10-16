import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/settings/settings_dialog.dart';
import '../ads/ad_rewarded.dart';
import '../game/ui/game_screen.dart';
import '../game/data/stage_repository.dart';
import '../game/controllers/stage_controller.dart';
import '../game/ui/stage_carousel.dart';

import 'package:provider/provider.dart';
import 'package:sichuan_flutter/providers/user_provider.dart';

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

  Future<void> _goPlay(String filePath) async {
    if (filePath.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    if (user.energy <= 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("에너지가 부족합니다."),
          content: const Text("에너지를 충전한 뒤 다시 시도해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      debugPrint("🔥 에너지 차감 시도");
      await userProvider.consumeEnergy(1);
      debugPrint("✅ 에너지 차감 완료");

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(stageFilePath: filePath)),
      );
    } catch (e) {
      debugPrint("❌ 에너지 차감 실패: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StageController(repo: StageRepository()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  const Text('Welcome to Koofy Universe!',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 12),
                  // ✅ 홈 내부에 캐러셀 조립
                  Expanded(
                    child: Center(
                      child: StageCarousel(onPlay: _goPlay),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      AdRewardedService.showRewardedAd(
                        onReward: () => debugPrint("✅ Reward granted"),
                        onFail: () => debugPrint("❌ Reward failed"),
                      );
                    },
                    child: const Text("🎁 보상형 광고 보기"),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              // 우하단 floating 메뉴
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
        ),
      ),
    );
  }
}