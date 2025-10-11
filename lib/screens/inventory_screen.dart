import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/item_model.dart';
import '../../models/user_item_model.dart';
import '../ui/inventory/inventory_tab_view.dart';
import '../ui/inventory/widgets/equipped_item_view.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
      context.read<ItemProvider>().loadAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final inventory = context.watch<InventoryProvider>().inventory;
    final items = context.watch<ItemProvider>().items;

    // ✅ 착용된 배경 찾기
    final equippedBackground = inventory.firstWhere(
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

    final bgData = items.firstWhere(
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 전체 배경 이미지
          if (bgData.images?.isNotEmpty == true)
            Positioned.fill(
              child: Image.asset(
                bgData.images!.first,
                fit: BoxFit.cover,
              ),
            ),

          // 🔹 반투명 오버레이 (글씨 가독성)
          Container(color: Colors.black.withOpacity(0.4)),

          // 🔹 실제 인벤토리 내용
          Column(
            children: [
              const SizedBox(height: 280, child: EquippedItemView()),
              Expanded(
                child: InventoryTabView(tabController: _tabController),
              ),
            ],
          ),
        ],
      ),
    );
  }
}