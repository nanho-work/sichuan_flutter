import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../providers/inventory_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/user_item_model.dart';

class InventoryDetailDialog extends StatelessWidget {
  final ItemModel item;
  final bool owned;

  const InventoryDetailDialog({
    super.key,
    required this.item,
    required this.owned,
  });

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final ownedItem = inventoryProvider.inventory.firstWhere(
      (i) => i.itemId == item.id,
      orElse: () => UserItemModel(
        uid: '',
        itemId: item.id,
        category: item.category.value,
        equipped: false,
        source: 'shop',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
      ),
    );
    final isEquipped = ownedItem.equipped;

    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이미지
            if (item.images?.isNotEmpty == true)
              Image.asset(
                item.images!.first,
                height: 120,
              ),
            const SizedBox(height: 12),

            // 이름 + 희귀도
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              item.rarity.value.toUpperCase(),
              style: TextStyle(
                color: _rarityColor(item.rarity),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              item.description.isNotEmpty ? item.description : "아이템 설명이 없습니다.",
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: null,
                  ),
                if (owned && !isEquipped)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("장착"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () async {
                      await inventoryProvider.unequipCategory(item.category);
                      await inventoryProvider.setEquipped(item.id, true);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 닫기 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("닫기", style: TextStyle(color: Colors.white54)),
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