import 'package:flutter/material.dart';

/// ❌ 다이얼로그 닫기 전용 버튼
class CloseDialogButton extends StatelessWidget {
  final VoidCallback? onClose;
  const CloseDialogButton({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.close, color: Colors.white54, size: 18),
      label: const Text("닫기", style: TextStyle(color: Colors.white54, fontSize: 14)),
      onPressed: onClose ?? () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        foregroundColor: Colors.white,
      ),
    );
  }
}