import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/item_provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/item_model.dart';
import '../dialogs/inventory_detail_dialog.dart';

class InventoryBlockView extends StatelessWidget {
  const InventoryBlockView({super.key});

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final inventory = context.watch<InventoryProvider>().inventory;

    final items = itemProvider.itemsByCategory('block_set');

    if (itemProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text('보유 중인 블록 세트가 없습니다.', style: TextStyle(color: Colors.white70)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final owned = inventory.any((i) => i.itemId == item.id);

        return GestureDetector(
          onTap: owned
              ? () {
                  showDialog(
                    context: context,
                    builder: (_) => InventoryDetailDialog(item: item, owned: owned),
                  );
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: owned ? Colors.greenAccent : Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (item.images?.isNotEmpty == true)
                  Image.asset(item.images!.first, fit: BoxFit.cover),
                if (!owned)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: const Text("미보유", style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}