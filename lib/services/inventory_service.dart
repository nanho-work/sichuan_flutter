// =======================================================
// 🎒 InventoryService — 유저 인벤토리 관리 (UserItemModel 기반)
// -------------------------------------------------------
// - 구매/획득/장착/강화 등 처리
// =======================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_item_model.dart';
import '../models/item_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 특정 유저의 인벤토리 컬렉션 참조
  CollectionReference<Map<String, dynamic>> _userItemsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('user_items');
  }

  /// 특정 아이템 문서 참조
  DocumentReference<Map<String, dynamic>> _itemDocRef(String uid, String itemId) {
    return _userItemsRef(uid).doc(itemId);
  }

  // =======================================================
  // 🔹 인벤토리 전체 조회
  // =======================================================
  Future<List<UserItemModel>> getInventory(String uid) async {
    final snapshot = await _userItemsRef(uid).get();
    return snapshot.docs.map((doc) => UserItemModel.fromDoc(doc)).toList();
  }

  // =======================================================
  // 🔹 특정 아이템 보유 여부 확인
  // =======================================================
  Future<bool> hasItem(String uid, String itemId) async {
    final doc = await _itemDocRef(uid, itemId).get();
    return doc.exists;
  }

  // =======================================================
  // 🔹 아이템 추가 (획득)
  // =======================================================
  Future<void> addItem(String uid, UserItemModel userItem) async {
    final ref = _itemDocRef(uid, userItem.itemId);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.update({'owned_at': DateTime.now()});
    } else {
      await ref.set(userItem.toMap());
    }
  }

  // =======================================================
  // 🔹 장착 상태 변경
  // =======================================================
  Future<void> setEquipped(String uid, String itemId, bool equipped) async {
    final ref = _itemDocRef(uid, itemId);
    await ref.update({'equipped': equipped});
  }

  // =======================================================
  // 🔹 구매 (골드/젬 차감 + 인벤토리 추가)
  // =======================================================
  Future<void> purchaseItemWithCurrency(String uid, ItemModel item) async {
    final userRef = _firestore.collection('users').doc(uid);
    final inventoryRef = _userItemsRef(uid).doc(item.id);

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final currentGold = userSnap['gold'] as int;
      final currentGems = userSnap['gems'] as int;

      // 이미 보유 중인지 확인
      final owned = await _itemDocRef(uid, item.id).get();
      if (owned.exists) throw Exception('이미 보유한 아이템입니다.');

      // 통화 유형에 따른 차감 처리
      if (item.currency == ItemCurrency.gold && currentGold < item.price) {
        throw Exception('도토리가 부족합니다.');
      } else if (item.currency == ItemCurrency.gem && currentGems < item.price) {
        throw Exception('젬이 부족합니다.');
      }

      if (item.currency == ItemCurrency.gold) {
        transaction.update(userRef, {'gold': currentGold - item.price});
      } else if (item.currency == ItemCurrency.gem) {
        transaction.update(userRef, {'gems': currentGems - item.price});
      }

      // 인벤토리에 아이템 추가
      transaction.set(inventoryRef, {
        'item_id': item.id,
        'category': item.category.value,
        'equipped': false,
        'source': 'shop',
        'upgrade_level': 1,
        'owned_at': DateTime.now(),
      });
    });
  }

  // =======================================================
  // 🔹 강화 레벨 변경
  // =======================================================
  Future<void> updateEnhanceLevel(String uid, String itemId, int newLevel) async {
    final ref = _itemDocRef(uid, itemId);
    await ref.update({'upgrade_level': newLevel});
  }

  // =======================================================
  // 🔹 실시간 스트림 조회
  // =======================================================
  Stream<List<UserItemModel>> streamInventory(String uid) {
    return _userItemsRef(uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserItemModel.fromDoc(doc)).toList());
  }
}