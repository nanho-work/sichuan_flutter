import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import 'character_card.dart';
import 'blockset_card.dart';
import 'background_card.dart';

/// =======================================================
/// 🧩 ItemCard Router — 카테고리별 카드 분기
/// =======================================================
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    switch (item.category) {
      case ItemCategory.character:
        return CharacterCard(item: item);
      case ItemCategory.blockSet:
        return BlockSetCard(item: item);
      case ItemCategory.background:
        return BackgroundCard(item: item);
      default:
        return const SizedBox.shrink();
    }
  }
}