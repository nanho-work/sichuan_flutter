import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('게임 오버'),
      content: const Text('시간이 초과되었습니다.'),
      actions: [
        TextButton(onPressed: onRetry, child: const Text('다시하기')),
        TextButton(onPressed: onHome, child: const Text('홈으로')),
      ],
    );
  }
}