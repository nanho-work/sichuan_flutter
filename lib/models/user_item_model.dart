import 'package:cloud_firestore/cloud_firestore.dart';

class UserItemModel {
  final String uid;
  final String itemId;
  final String category;
  final bool equipped;
  final String source;
  final int upgradeLevel;
  final DateTime ownedAt;
  final String? setId; // ✅ 기본/비셋트 아이템일 경우 null 허용

  UserItemModel({
    required this.uid,
    required this.itemId,
    required this.category,
    required this.equipped,
    required this.source,
    required this.upgradeLevel,
    required this.ownedAt,
    this.setId, // ✅ 기본/비셋트 아이템일 경우 null 허용
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
      setId: data.containsKey('set_id') ? data['set_id'] as String? : null,
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
      'set_id': setId,
    };
  }
  UserItemModel copyWith({
    String? uid,
    String? itemId,
    String? category,
    bool? equipped,
    String? source,
    int? upgradeLevel,
    DateTime? ownedAt,
    String? setId,
  }) {
    return UserItemModel(
      uid: uid ?? this.uid,
      itemId: itemId ?? this.itemId,
      category: category ?? this.category,
      equipped: equipped ?? this.equipped,
      source: source ?? this.source,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      ownedAt: ownedAt ?? this.ownedAt,
      setId: setId ?? this.setId,
    );
  }

  factory UserItemModel.empty() => UserItemModel(
        uid: '',
        itemId: '',
        category: '',
        equipped: false,
        source: 'shop',
        upgradeLevel: 1,
        ownedAt: DateTime.now(),
        setId: null,
      );
}