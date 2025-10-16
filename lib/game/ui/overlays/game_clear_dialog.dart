// lib/game/ui/overlays/game_clear_dialog.dart
import 'package:flutter/material.dart';

class GameClearDialog extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onNextStage;

  const GameClearDialog({
    super.key,
    required this.onClose,
    required this.onNextStage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎉 클리어!'),
      content: const Text('스테이지를 완료했습니다. 다음 스테이지로 이동할까요?'),
      actions: [
        TextButton(onPressed: onClose, child: const Text('닫기')),
        ElevatedButton(onPressed: onNextStage, child: const Text('다음 스테이지')),
      ],
    );
  }
}