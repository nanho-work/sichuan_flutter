// =======================================================
// 🎒 인벤토리 서비스 (UserItemModel 기반)
// Firestore에서 유저 인벤토리 데이터를 관리합니다.
// =======================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_item_model.dart';

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
  // 🔹 아이템 추가 (구매/획득)
  // =======================================================
  Future<void> addItem(String uid, UserItemModel userItem) async {
    final ref = _itemDocRef(uid, userItem.itemId);
    final doc = await ref.get();

    if (doc.exists) {
      // 이미 있으면 그대로 두거나 로직 추가 가능
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