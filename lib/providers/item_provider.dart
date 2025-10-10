import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

/// ItemProvider
/// ------------------------------------------------------------
/// Firestore에서 가져온 아이템 데이터를 UI와 연결하는 상태관리 클래스.
/// - 전체 아이템 로딩 상태
/// - 특정 카테고리별 목록
/// - 현재 선택된 아이템
/// - 선택/갱신/필터링 처리 등
class ItemProvider extends ChangeNotifier {
  final ItemService _service = ItemService();

  bool _isLoading = false;
  List<ItemModel> _items = [];
  ItemModel? _selectedItem;

  bool get isLoading => _isLoading;
  List<ItemModel> get items => _items;
  ItemModel? get selectedItem => _selectedItem;

  /// ✅ 모든 아이템 불러오기
  Future<void> loadAllItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.fetchAllItems();
    } catch (e) {
      debugPrint("❌ ItemProvider.loadAllItems Error: $e");
      _items = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ 카테고리별 로드
  Future<void> loadByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.fetchByCategory(category);
    } catch (e) {
      debugPrint("❌ ItemProvider.loadByCategory Error: $e");
      _items = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ 단일 아이템 선택
  void selectItem(ItemModel item) {
    _selectedItem = item;
    notifyListeners();
  }

  /// ✅ 선택 해제
  void clearSelection() {
    _selectedItem = null;
    notifyListeners();
  }

  /// ✅ 특정 아이템 갱신 (FireStore 동기화)
  Future<void> refreshItem(String id) async {
    try {
      final updated = await _service.fetchById(id);
      if (updated == null) return;

      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = updated;
        if (_selectedItem?.id == id) {
          _selectedItem = updated;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ ItemProvider.refreshItem Error: $e");
    }
  }

  /// ✅ 로컬에서 즉시 갱신 (Firestore 호출 없이)
  void updateLocalItem(ItemModel item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// ✅ 캐시된 아이템 가져오기
  ItemModel? getItemById(String id) {
    return _items.firstWhere(
      (i) => i.id == id,
      orElse: () => _selectedItem ?? ItemModel(
        id: 'unknown',
        name: 'Unknown',
        category: ItemCategory.unknown,
        description: '',
        rarity: ItemRarity.unknown,
        currency: ItemCurrency.unknown,
        available: false,
        price: 0,
        levels: [],
      ),
    );
  }

  /// ✅ 모든 아이템 새로고침
  Future<void> refresh() async {
    await loadAllItems();
  }

  /// ✅ 카테고리별 아이템 반환 (필터링)
  List<ItemModel> itemsByCategory(String category) {
    return _items.where((item) {
      // ItemModel.category가 enum인 경우 value로 비교
      try {
        return item.category.value == category;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  /// ✅ 아이템 구매 및 새로고침
  Future<void> purchaseItem(ItemModel item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _service.purchaseItem(userId: user.uid, item: item);
      await refresh(); // 구매 후 리스트 갱신
    } catch (e) {
      debugPrint("❌ ItemProvider.purchaseItem Error: $e");
    }
  }
}