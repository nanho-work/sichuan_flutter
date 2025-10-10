import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// ItemService
/// ------------------------------------------------------------
/// Firestore의 "items" 컬렉션에 접근하여 아이템(캐릭터 등)을
/// 불러오거나, 단일 조회, 필터 조회 등을 담당하는 서비스 계층.
/// UI 상태는 전혀 관리하지 않고, 데이터 접근 전용 역할.
class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ 전체 아이템(예: 캐릭터, 배경 등) 조회
  Future<List<ItemModel>> fetchAllItems() async {
    final snapshot = await _db.collection('items').get();
    return snapshot.docs.map((e) => ItemModel.fromDoc(e)).toList();
  }

  /// ✅ 카테고리별 아이템 조회 (character, block_set, background 등)
  Future<List<ItemModel>> fetchByCategory(String category) async {
    final snapshot = await _db
        .collection('items')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((e) => ItemModel.fromDoc(e)).toList();
  }

  /// ✅ 단일 아이템 조회
  Future<ItemModel?> fetchById(String id) async {
    final doc = await _db.collection('items').doc(id).get();
    if (!doc.exists) return null;
    return ItemModel.fromDoc(doc);
  }

  /// ✅ 아이템 사용 가능 여부 변경 (관리자용)
  Future<void> updateAvailability(String id, bool available) async {
    await _db.collection('items').doc(id).update({'available': available});
  }

  /// ✅ 가격 변경 (관리자/개발용)
  Future<void> updatePrice(String id, int price) async {
    await _db.collection('items').doc(id).update({'price': price});
  }

  /// ✅ Firestore에 새로운 아이템 추가 (초기 세팅용)
  Future<void> addItem(ItemModel item) async {
    await _db.collection('items').doc(item.id).set(item.toMap());
  }

  /// ✅ Firestore 데이터 갱신 (레벨 수정 등)
  Future<void> updateItem(ItemModel item) async {
    await _db.collection('items').doc(item.id).update(item.toMap());
  }

  /// ✅ Firestore 삭제 (관리자용)
  Future<void> deleteItem(String id) async {
    await _db.collection('items').doc(id).delete();
  }
  /// 구매: 사용자의 인벤토리에 아이템 추가 (이미 소유한 경우 무시)
  Future<void> purchaseItem({required String userId, required ItemModel item}) async {
    final userRef = _db.collection('users').doc(userId);
    final inventoryRef = userRef.collection('inventory').doc(item.id);
    await _db.runTransaction((transaction) async {
      final inventorySnap = await transaction.get(inventoryRef);
      if (!inventorySnap.exists) {
        transaction.set(inventoryRef, {
          'item_id': item.id,
          'category': item.category,
          'name': item.name,
          'acquired_at': FieldValue.serverTimestamp(),
          'level': 1,
          'owned': true,
        });
      }
    });
  }
}