import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/item_model.dart';
import '../../../../managers/image_manager.dart';
import '../../../../providers/inventory_provider.dart';

/// 공통 가격 표시 위젯
class ItemPrice extends StatelessWidget {
  const ItemPrice({super.key, required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    // ✅ 유저 인벤토리 정보 가져오기
    final inventoryProvider = context.watch<InventoryProvider>();
    final isOwned = inventoryProvider.hasItem(item.id);

    // ✅ 이미 보유한 경우
    if (isOwned) {
      return const Text(
        '보유중',
        style: TextStyle(
          color: Colors.amberAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // ✅ 보유하지 않은 경우 가격 표시
    if ((item.price ?? 0) > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.currency == ItemCurrency.gold)
            ImageManager.instance.getCurrencyIcon(CurrencyType.gold, size: 16)
          else if (item.currency == ItemCurrency.gem)
            ImageManager.instance.getCurrencyIcon(CurrencyType.gem, size: 16)
          else if (item.currency == ItemCurrency.free)
            ImageManager.instance.getCurrencyIcon(CurrencyType.energy, size: 16),
          const SizedBox(width: 4),
          Text(
            '${item.price}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      );
    }

    // ✅ 무료 아이템
    return const Text(
      '무료',
      style: TextStyle(color: Colors.greenAccent, fontSize: 12),
    );
  }
}