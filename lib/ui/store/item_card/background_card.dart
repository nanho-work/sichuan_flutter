import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../dialogs/item_detail_dialog.dart';
import 'widgets/item_image.dart';
import 'widgets/item_price.dart';

/// =======================================================
/// 🌅 BackgroundCard — 배경 전용 카드 (희귀도 테두리 효과)
/// =======================================================
class BackgroundCard extends StatelessWidget {
  const BackgroundCard({super.key, required this.item});
  final dynamic item;

  String _imageFromItem(dynamic it) {
    try {
        if (it.images != null && it.images.isNotEmpty) {
        return it.images.first;
        }
    } catch (_) {}
    return '';
    }

  Color _rarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.rare:
        return Colors.blueAccent;
      case ItemRarity.epic:
        return Colors.purpleAccent;
      case ItemRarity.legendary:
        return Colors.orangeAccent;
      default:
        return Colors.white10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgPath = _imageFromItem(item);
    final borderColor = _rarityColor(item.rarity);

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
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(child: ItemImage(imgPath: imgPath, fit: BoxFit.cover)),
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