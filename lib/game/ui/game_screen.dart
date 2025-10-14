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
    final state = context.watch<GameProvider>().state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state?.cleared == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameClearDialog(
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      } else if (state?.failed == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: const [
            GameBar(),
            Expanded(child: GameBoard()),
            GameNavigation(),
          ],
        ),
      ),
    );
  }
}