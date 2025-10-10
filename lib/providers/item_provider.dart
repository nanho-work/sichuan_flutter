// =======================================================
// 🧠 ItemProvider — 상점 데이터 상태 관리 Provider
// -------------------------------------------------------
// - Firestore에서 아이템 불러오기
// - 카테고리 필터
// - 선택 및 갱신
// =======================================================
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

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

  /// ✅ 특정 아이템 갱신
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

  /// ✅ 로컬에서 즉시 갱신
  void updateLocalItem(ItemModel item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// ✅ 전체 새로고침
  Future<void> refresh() async => loadAllItems();

  /// ✅ 카테고리별 아이템 반환 (필터링)
  List<ItemModel> itemsByCategory(String category) {
    return _items.where((item) {
      try {
        return item.category.value == category;
      } catch (_) {
        return false;
      }
    }).toList();
  }
}