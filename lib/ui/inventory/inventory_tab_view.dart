import 'package:flutter/material.dart';
import 'inventory_card/inventory_character_view.dart';
import 'inventory_card/inventory_block_view.dart';
import 'inventory_card/inventory_background_view.dart';

class InventoryTabView extends StatelessWidget {
  final TabController tabController;
  const InventoryTabView({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: '캐릭터'),
            Tab(text: '블록'),
            Tab(text: '배경'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              InventoryCharacterView(),
              InventoryBlockView(),
              InventoryBackgroundView(),
            ],
          ),
        ),
      ],
    );
  }
}