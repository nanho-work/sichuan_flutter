import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/item_model.dart';
import '../../../../providers/inventory_provider.dart';

/// 🚀 레벨업 버튼 — 아이템 강화 처리용
class LevelUpButton extends StatefulWidget {
  final ItemModel item;
  final int currentLevel;
  const LevelUpButton({
    super.key,
    required this.item,
    required this.currentLevel,
  });

  @override
  State<LevelUpButton> createState() => _LevelUpButtonState();
}

class _LevelUpButtonState extends State<LevelUpButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.read<InventoryProvider>();
    final nextLevel = widget.currentLevel + 1;
    final canUpgrade = widget.item.levels.length > widget.currentLevel;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.upgrade),
        label: Text(
          canUpgrade ? "레벨업 (${widget.currentLevel} → $nextLevel)" : "최대 레벨",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canUpgrade ? Colors.greenAccent.shade700 : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: canUpgrade && !_isLoading
            ? () async {
                setState(() => _isLoading = true);
                try {
                  await inventoryProvider.updateEnhanceLevel(widget.item.id, nextLevel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${widget.item.name}이(가) 레벨 $nextLevel로 강화되었습니다.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("레벨업 실패: $e")),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              }
            : null,
      ),
    );
  }
}