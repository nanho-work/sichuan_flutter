import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final VoidCallback onClose;
  const GameOverDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('실패'),
      content: const Text('시간이 초과되었습니다.'),
      actions: [
        TextButton(onPressed: onClose, child: const Text('닫기')),
      ],
    );
  }
}