/// =======================================================
/// 🎒 InventoryProvider — 유저 인벤토리 상태 관리 Provider
///
/// - loadInventory: 인벤토리 전체 로드
/// - hasItem: 단일 아이템 보유 여부 확인
/// - addItem: 아이템 추가 (구매/획득)
/// - setEquipped: 장착 상태 변경
/// - updateEnhanceLevel: 강화 레벨 변경
/// - refresh: 전체 새로고침
/// =======================================================
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_item_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  List<UserItemModel> _inventory = [];
  bool _isLoading = false;

  List<UserItemModel> get inventory => _inventory;
  bool get isLoading => _isLoading;

  /// ✅ 인벤토리 전체 로드
  /// 유저의 전체 인벤토리 정보를 불러옵니다.
  Future<void> loadInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _inventory = await _service.getInventory(user.uid);
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.loadInventory] 인벤토리 불러오기 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
      _inventory = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ 단일 아이템 보유 여부 확인
  /// 해당 itemId의 아이템을 유저가 보유 중인지 확인합니다.
  bool hasItem(String itemId) {
    return _inventory.any((userItem) => userItem.itemId == itemId);
  }

  /// ✅ 아이템 추가 (구매/획득)
  /// 인벤토리에 새 아이템을 추가합니다.
  Future<void> addItem(UserItemModel userItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.addItem(user.uid, userItem);
      await loadInventory();
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.addItem] 아이템 추가 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }

  /// ✅ 장착 상태 변경
  /// 인벤토리 아이템의 장착 상태를 변경합니다.
  Future<void> setEquipped(String itemId, bool equipped) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.setEquipped(user.uid, itemId, equipped);
      await loadInventory();
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.setEquipped] 장착 상태 변경 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }

  /// ✅ 강화 레벨 변경
  /// 인벤토리 아이템의 강화 레벨을 변경합니다.
  Future<void> updateEnhanceLevel(String itemId, int newLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _service.updateEnhanceLevel(user.uid, itemId, newLevel);
      await loadInventory();
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.updateEnhanceLevel] 강화 레벨 변경 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }

  /// ✅ 전체 새로고침
  /// 인벤토리 전체를 새로고침합니다.
  Future<void> refresh() async => loadInventory();
}