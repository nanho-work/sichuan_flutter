import 'package:flutter/material.dart';

class GameClearDialog extends StatelessWidget {
  final VoidCallback onClose;
  const GameClearDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('클리어!'),
      content: const Text('스테이지를 완료했습니다.'),
      actions: [
        TextButton(onPressed: onClose, child: const Text('닫기')),
      ],
    );
  }
}