import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/item_provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/item_model.dart';
import '../dialogs/inventory_detail_dialog.dart';

class InventoryCharacterView extends StatelessWidget {
  const InventoryCharacterView({super.key});

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final inventory = context.watch<InventoryProvider>().inventory;

    final items = itemProvider.itemsByCategory('character');

    if (itemProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text('보유 중인 캐릭터가 없습니다.', style: TextStyle(color: Colors.white70)));
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
              border: Border.all(color: owned ? Colors.blueAccent : Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
                alignment: Alignment.center,
                children: [
                    // 🔹 캐릭터는 levels[0].image_path 사용
                    Image.asset(
                    item.imagePathForLevel(1),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white30, size: 48),
                    ),
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