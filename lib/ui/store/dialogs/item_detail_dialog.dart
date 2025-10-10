import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import 'character_detail_dialog.dart';
import 'blockset_detail_dialog.dart';
import 'background_detail_dialog.dart';

class ItemDetailDialog extends StatelessWidget {
  const ItemDetailDialog({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    switch (item.category) {
      case ItemCategory.character:
        return CharacterDetailDialog(item: item);
      case ItemCategory.blockSet:
        return BlocksetDetailDialog(item: item);
      case ItemCategory.background:
        return BackgroundDetailDialog(item: item);
      default:
        return const SizedBox.shrink();
    }
  }
}