import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../providers/inventory_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/user_item_model.dart';

class InventoryDetailDialog extends StatefulWidget {
  final ItemModel item;
  final bool owned;

  const InventoryDetailDialog({
    super.key,
    required this.item,
    required this.owned,
  });

  @override
  State<InventoryDetailDialog> createState() => _InventoryDetailDialogState();
}

class _InventoryDetailDialogState extends State<InventoryDetailDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final ownedItem = inventoryProvider.inventory.firstWhere(
      (i) => i.itemId == widget.item.id,
      orElse: () => UserItemModel(
        uid: '',
        itemId: widget.item.id,
        category: widget.item.category.value,
        equipped: false,
        source: 'shop',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
      ),
    );

    final isEquipped = ownedItem.equipped;
    final owned = widget.owned;

    return Dialog(
      backgroundColor: Colors.brown.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이미지
            if (widget.item.images?.isNotEmpty == true)
              Image.asset(
                widget.item.images!.first,
                height: 120,
              ),
            const SizedBox(height: 12),

            // 이름 + 희귀도
            Text(
              widget.item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.rarity.value.toUpperCase(),
              style: TextStyle(
                color: _rarityColor(widget.item.rarity),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              widget.item.description.isNotEmpty
                  ? widget.item.description
                  : "아이템 설명이 없습니다.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24),

            // 장비/해제 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (owned && isEquipped)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("장착중"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: null,
                  ),

                if (owned && !isEquipped)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: _isLoading
                        ? const Text("처리중...")
                        : const Text("장착"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? Colors.grey : Colors.blueAccent,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_isLoading) return;
                            setState(() => _isLoading = true);

                            try {
                              await inventoryProvider.unequipCategory(widget.item.category);
                              await inventoryProvider.setEquipped(widget.item.id, true);

                              // ✅ 안전한 Navigator pop
                              if (mounted && Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              debugPrint("❌ Equip action failed: $e");
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                  ),

                const SizedBox(width: 12),

                // 닫기 버튼을 같은 행에 배치
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    "닫기",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.rare:
        return Colors.blueAccent;
      case ItemRarity.epic:
        return Colors.purpleAccent;
      case ItemRarity.legendary:
        return Colors.amberAccent;
      default:
        return Colors.white70;
    }
  }
}