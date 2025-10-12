import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../managers/image_manager.dart';
import '../dialogs/item_detail_dialog.dart';
import 'widgets/item_image.dart';
import 'widgets/item_price.dart';

/// =======================================================
/// 🎭 CharacterCard — 캐릭터 전용 카드
/// =======================================================
class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.item});
  final dynamic item;

  String _imageFromItem(dynamic it) {
    try {
      final levels = it.levels as List;
      if (levels.isNotEmpty) {
        final m = levels.first;
        if (m is Map) return (m['image_path'] as String?) ?? '';
        return m.imagePath as String? ?? '';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final imgPath = _imageFromItem(item);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => ItemDetailDialog(item: item),
        );
        // await context.read<ItemProvider>().refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2B3C).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(child: ItemImage(imgPath: imgPath)),
            const SizedBox(height: 6),
            Text(
              '${item.name ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            ItemPrice(item: item),
          ],
        ),
      ),
    );
  }
}