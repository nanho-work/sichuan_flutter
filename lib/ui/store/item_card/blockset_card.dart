import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../managers/image_manager.dart';
import '../dialogs/item_detail_dialog.dart';
import 'widgets/item_image.dart';
import 'widgets/item_price.dart';

/// =======================================================
/// 🍎 BlockSetCard — 블록셋 전용 카드 (썸네일 우선 표시)
/// =======================================================
class BlockSetCard extends StatelessWidget {
  const BlockSetCard({super.key, required this.item});
  final dynamic item;

  String _imageFromItem(dynamic it) {
    try {
      if (it.thumbnails != null && it.thumbnails.isNotEmpty) return it.thumbnails.first;
      if (it.images != null && it.images.isNotEmpty) return it.images.first;
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
              '${item.name ?? ''} (${item.count ?? 0})',
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