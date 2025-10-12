import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../providers/item_provider.dart';
import '../../../models/user_item_model.dart';
import '../../../models/item_model.dart';

class EquippedItemView extends StatelessWidget {
  const EquippedItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>().inventory;
    final items = context.watch<ItemProvider>().items;

    // ✅ 착용 중 아이템 정보 가져오기
    UserItemModel equippedCharacter = inventory.firstWhere(
      (i) => i.category == 'character' && i.equipped,
      orElse: () => UserItemModel(
        uid: '',
        itemId: '',
        category: '',
        equipped: false,
        source: '',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
      ),
    );

    UserItemModel equippedBackground = inventory.firstWhere(
      (i) => i.category == 'background' && i.equipped,
      orElse: () => UserItemModel(
        uid: '',
        itemId: '',
        category: '',
        equipped: false,
        source: '',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
      ),
    );

    UserItemModel equippedBlock = inventory.firstWhere(
      (i) => i.category == 'block_set' && i.equipped,
      orElse: () => UserItemModel(
        uid: '',
        itemId: '',
        category: '',
        equipped: false,
        source: '',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
      ),
    );

    // ✅ 각 아이템 데이터 매칭
    final charData = items.firstWhere(
      (i) => i.id == equippedCharacter.itemId,
      orElse: () => ItemModel(
        id: 'default_char',
        name: '기본 캐릭터',
        category: ItemCategory.character,
        description: '',
        rarity: ItemRarity.common,
        currency: ItemCurrency.free,
        available: true,
        price: 0,
        levels: const [],
      ),
    );

    final bgData = items.firstWhere(
      (i) => i.id == equippedBackground.itemId,
      orElse: () => ItemModel(
        id: 'bg_default',
        name: '기본 배경',
        category: ItemCategory.background,
        description: '',
        rarity: ItemRarity.common,
        currency: ItemCurrency.free,
        available: true,
        price: 0,
        levels: const [],
      ),
    );

    final blockData = items.firstWhere(
      (i) => i.id == equippedBlock.itemId,
      orElse: () => ItemModel(
        id: 'block_default',
        name: '기본 블록 세트',
        category: ItemCategory.blockSet,
        description: '',
        rarity: ItemRarity.common,
        currency: ItemCurrency.free,
        available: true,
        price: 0,
        levels: const [],
      ),
    );

    // ✅ 뷰
    return Container(
      height: 240,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '착용 중 캐릭터: ${charData.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                image: bgData.images?.isNotEmpty == true
                    ? DecorationImage(
                        image: AssetImage(bgData.images!.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (equippedBlock.equipped && blockData.thumbnails?.isNotEmpty == true)
                    Positioned(
                      top: 24,
                      right: 24,
                      child: SizedBox(
                        height: 140,
                        child: Image.asset(
                          blockData.thumbnails!.first,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  if (equippedCharacter.equipped &&
                      charData.imagePathForLevel(equippedCharacter.upgradeLevel).isNotEmpty)
                    Positioned(
                      right: 24,
                      bottom: 0,
                      child: SizedBox(
                        height: 140,
                        child: Image.asset(
                          charData.imagePathForLevel(equippedCharacter.upgradeLevel),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}