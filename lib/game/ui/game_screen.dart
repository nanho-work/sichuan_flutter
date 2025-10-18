import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'components/game_bar.dart';
import 'components/game_board.dart';
import 'components/game_navigation.dart';
import 'overlays/game_clear_dialog.dart';
import 'overlays/game_over_dialog.dart';
import '../../managers/sound_manager.dart';

class GameScreen extends StatefulWidget {
  final String stageFilePath; // ✅ 추가

  const GameScreen({super.key, required this.stageFilePath});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<GameProvider>().loadStage(widget.stageFilePath, context);
      SoundManager().playBGM('game_theme.mp3');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameProvider = Provider.of<GameProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // 게임 끝 → 홈 BGM 복귀 (원하면)
    SoundManager().playBGM('home_theme.mp3');
    _gameProvider.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final state = gameProvider.state;
    final bgImage = gameProvider.backgroundImage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state?.failed == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            onRetry: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              _gameProvider.restartStage(context); // 스테이지 재시작
            },
            onHome: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state?.cleared == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameClearDialog(
            onClose: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onNextStage: () {
              Navigator.of(context).pop(); // Close dialog
              _gameProvider.loadStage('assets/stages/next_stage.json', context); // Example next stage path
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ 전체 배경 이미지 (유저 착용한 배경 스킨)
          if (bgImage != null && bgImage.isNotEmpty)
            Positioned.fill(
              child: Image.asset(
                bgImage,
                fit: BoxFit.cover,
              ),
            ),

          // ✅ 게임 UI
          SafeArea(
            child: Column(
              children: [
                const GameBar(),
                // The GameBoard widget will be modified to wrap each tile in a Container with margin/padding and border.
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // 살짝 배경 강조 (선택사항)
                    ),
                    child: const GameBoard(),
                  ),
                ),
                const GameNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}