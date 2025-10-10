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

    UserItemModel? equippedCharacter =
        inventory.firstWhere((i) => i.category == 'character' && i.equipped, orElse: () => UserItemModel(
          uid: '',
          itemId: '',
          category: '',
          equipped: false,
          source: '',
          upgradeLevel: 1,
          ownedAt: DateTime.now(),
        ));

    UserItemModel? equippedBackground =
        inventory.firstWhere((i) => i.category == 'background' && i.equipped, orElse: () => UserItemModel(
          uid: '',
          itemId: '',
          category: '',
          equipped: false,
          source: '',
          upgradeLevel: 1,
          ownedAt: DateTime.now(),
        ));

    // 해당 아이템 정보 매칭
    ItemModel? charData = items.firstWhere(
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

    ItemModel? bgData = items.firstWhere(
      (i) => i.id == equippedBackground.itemId,
      orElse: () => ItemModel(
        id: 'default_bg',
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

    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        image: bgData.images?.isNotEmpty == true
            ? DecorationImage(
                image: AssetImage(bgData.images!.first),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 캐릭터 이미지
          if (charData.images?.isNotEmpty == true)
            Positioned(
              bottom: 0,
              child: Image.asset(
                charData.images!.first,
                height: 160,
              ),
            ),
          // 버튼: 변경 / 해제
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text("변경"),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    // 착용 해제 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text("해제"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}