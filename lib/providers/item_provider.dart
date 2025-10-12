// =======================================================
// 🧠 ItemProvider — 상점 데이터 상태 관리 Provider
// -------------------------------------------------------
// - Firestore에서 아이템 불러오기
// - 카테고리 필터
// - 선택 및 갱신
// =======================================================
import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> loadAllItems({bool forceRefresh = false}) async {
    if (!forceRefresh && _items.isNotEmpty) {
      // Use cached data
      return;
    }
    _isLoading = true;
    notifyListeners();

    unawaited(_loadAllItemsAsync());
  }

  Future<void> _loadAllItemsAsync() async {
    try {
      final fetchedItems = await _service.fetchAllItems();
      // Enrich items with set data if setId exists
      final List<ItemModel> enrichedItems = List.from(fetchedItems);
      final futures = <Future<void>>[];
      for (int i = 0; i < enrichedItems.length; i++) {
        final item = enrichedItems[i];
        if (item.setId != null && item.setId!.isNotEmpty) {
          futures.add(FirebaseFirestore.instance
              .collection('item_sets')
              .doc(item.setId)
              .get()
              .then((doc) {
            if (doc.exists) {
              final data = doc.data();
              if (data != null) {
                enrichedItems[i] = item.copyWith(
                  setName: data['name'] as String?,
                  setEffects: (data['effects'] as Map<String, dynamic>?),
                );
              }
            }
          }).catchError((_) {}));
        }
      }
      await Future.wait(futures);
      _items = enrichedItems;
    } catch (e) {
      debugPrint("❌ ItemProvider._loadAllItemsAsync Error: $e");
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ 카테고리별 로드
  Future<void> loadByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    unawaited(_loadByCategoryAsync(category));
  }

  Future<void> _loadByCategoryAsync(String category) async {
    try {
      final fetchedItems = await _service.fetchByCategory(category);
      // Enrich items with set data if setId exists
      final List<ItemModel> enrichedItems = List.from(fetchedItems);
      final futures = <Future<void>>[];
      for (int i = 0; i < enrichedItems.length; i++) {
        final item = enrichedItems[i];
        if (item.setId != null && item.setId!.isNotEmpty) {
          futures.add(FirebaseFirestore.instance
              .collection('item_sets')
              .doc(item.setId)
              .get()
              .then((doc) {
            if (doc.exists) {
              final data = doc.data();
              if (data != null) {
                enrichedItems[i] = item.copyWith(
                  setName: data['name'] as String?,
                  setEffects: (data['effects'] as Map<String, dynamic>?),
                );
              }
            }
          }).catchError((_) {}));
        }
      }
      await Future.wait(futures);
      _items = enrichedItems;
    } catch (e) {
      debugPrint("❌ ItemProvider._loadByCategoryAsync Error: $e");
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  Future<void> refresh() async => loadAllItems(forceRefresh: true);

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