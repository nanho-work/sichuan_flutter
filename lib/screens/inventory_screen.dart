import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/user_provider.dart';
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

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: AppBar(
        title: const Text("인벤토리"),
        backgroundColor: Colors.brown.shade600,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단: 착용중 아이템 뷰
          if (user != null) const EquippedItemView(),

          // 하단: 탭 구성
          Expanded(
            child: InventoryTabView(tabController: _tabController),
          ),
        ],
      ),
    );
  }
}