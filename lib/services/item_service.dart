// =======================================================
// 🛒 ItemService
// Firestore의 "items" 컬렉션 관리 (상점 데이터 전용)
// =======================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

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
}