
// =======================================================
// 🎒 InventoryProvider — 유저 인벤토리 상태 관리 Provider
// -------------------------------------------------------
// - 인벤토리 로드 / 보유 확인
// - 아이템 추가 / 장착 / 강화
// - 구매 처리 (골드·젬 트랜잭션)
// =======================================================
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../models/user_item_model.dart';
import '../services/inventory_service.dart';
import 'user_provider.dart';
import '../main.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  List<UserItemModel> _inventory = [];
  bool _isLoading = false;

  List<UserItemModel> get inventory => _inventory;
  bool get isLoading => _isLoading;

  /// ✅ 인벤토리 전체 로드
  Future<void> loadInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _inventory = await _service.getInventory(user.uid);
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.loadInventory] 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
      _inventory = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ 보유 여부 확인
  bool hasItem(String itemId) {
    return _inventory.any((item) => item.itemId == itemId);
  }

  /// ✅ 아이템 추가 (획득)
  Future<void> addItem(UserItemModel userItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.addItem(user.uid, userItem);
      await loadInventory();
    } catch (e) {
      debugPrint("❌ [InventoryProvider.addItem] 실패: $e");
    }
  }

  /// ✅ 장착 상태 변경
  Future<void> setEquipped(String itemId, bool equipped) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.setEquipped(user.uid, itemId, equipped);
      await loadInventory();
    } catch (e) {
      debugPrint("❌ [InventoryProvider.setEquipped] 실패: $e");
    }
  }

  /// ✅ 강화 레벨 변경
  Future<void> updateEnhanceLevel(String itemId, int newLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.updateEnhanceLevel(user.uid, itemId, newLevel);
      await loadInventory();
    } catch (e) {
      debugPrint("❌ [InventoryProvider.updateEnhanceLevel] 실패: $e");
    }
  }

  /// ✅ 구매 (골드/젬 차감 + 인벤토리 반영)
  Future<String> purchaseItem(ItemModel item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '로그인이 필요합니다.';

      await _service.purchaseItemWithCurrency(user.uid, item);

      // 인벤토리 갱신
      await loadInventory();

      // ✅ 유저 정보 갱신 (AppBar의 골드/젬 즉시 반영)
      if (navigatorKey.currentContext != null) {
        final userProvider = Provider.of<UserProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );
        await userProvider.loadUser();
      }

      return '구매가 완료되었습니다.';
    } catch (e) {
      debugPrint("❌ [InventoryProvider.purchaseItem] 실패: $e");
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> unequipCategory(ItemCategory category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_items')
          .where('category', isEqualTo: category.value)
          .where('equipped', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'equipped': false});
      }

      await loadInventory();
    } catch (e) {
      debugPrint("❌ [InventoryProvider.unequipCategory] 실패: $e");
    }
  }

  /// ✅ 전체 새로고침
  Future<void> refresh() async => loadInventory();
}