import 'package:cloud_firestore/cloud_firestore.dart';

class ShopItemModel {
  final String itemId;
  final String category;
  final String name;
  final String description;
  final int priceGold;
  final int priceGem;
  final String imageUrl;
  final String rarity;
  final String animationType;
  final Map<String, dynamic> effects;

  ShopItemModel({
    required this.itemId,
    required this.category,
    required this.name,
    required this.description,
    required this.priceGold,
    required this.priceGem,
    required this.imageUrl,
    required this.rarity,
    required this.animationType,
    required this.effects,
  });

  factory ShopItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopItemModel(
      itemId: doc.id,
      category: data['category'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      priceGold: data['price_gold'] ?? 0,
      priceGem: data['price_gem'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      rarity: data['rarity'] ?? 'normal',
      animationType: data['animation_type'] ?? 'none',
      effects: Map<String, dynamic>.from(data['effects'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'description': description,
      'price_gold': priceGold,
      'price_gem': priceGem,
      'image_url': imageUrl,
      'rarity': rarity,
      'animation_type': animationType,
      'effects': effects,
    };
  }
}