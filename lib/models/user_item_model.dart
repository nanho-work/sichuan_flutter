import 'package:cloud_firestore/cloud_firestore.dart';

class UserItemModel {
  final String uid;
  final String itemId;
  final String category;
  final bool equipped;
  final String source;
  final int upgradeLevel;
  final DateTime ownedAt;

  UserItemModel({
    required this.uid,
    required this.itemId,
    required this.category,
    required this.equipped,
    required this.source,
    required this.upgradeLevel,
    required this.ownedAt,
  });

  factory UserItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserItemModel(
      uid: data['uid'] ?? '',
      itemId: data['item_id'] ?? '',
      category: data['category'] ?? '',
      equipped: data['equipped'] ?? false,
      source: data['source'] ?? 'shop',
      upgradeLevel: data['upgrade_level'] ?? 1,
      ownedAt: (data['owned_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'item_id': itemId,
      'category': category,
      'equipped': equipped,
      'source': source,
      'upgrade_level': upgradeLevel,
      'owned_at': ownedAt,
    };
  }
}