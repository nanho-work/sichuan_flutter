import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_provider.dart';
import '../../models/item_model.dart';
import 'item_card/item_card.dart';

class StoreTabView extends StatelessWidget {
  const StoreTabView({super.key, required this.category});

  final ItemCategory category; // character | blockSet | background

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ItemProvider>();
    final items = provider.itemsByCategory(category.value);

    if (items.isEmpty) {
      return const Center(
        child: Text('표시할 아이템이 없어요.', style: TextStyle(color: Colors.white70)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3열
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .78,
          ),
          itemCount: items.length,
          itemBuilder: (_, idx) {
            final item = items[idx];
            return ItemCard(item: item);
          },
        ),
      ),
    );
  }
}