// =======================================================
// 🎒 InventoryProvider — 유저 인벤토리 상태 관리 Provider
// -------------------------------------------------------
// - 인벤토리 로드 / 보유 확인
// - 아이템 추가 / 장착 / 강화
// - 구매 처리 (골드·젬 트랜잭션)
// - 캐릭터 이펙트 + 셋트 이펙트(7종) 계산/저장 자동화
// =======================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async' show unawaited;

import '../models/item_model.dart';
import '../models/user_item_model.dart';
import '../services/inventory_service.dart';
import 'user_provider.dart';
import '../providers/item_provider.dart';
import '../main.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  List<UserItemModel> _inventory = [];
  bool _isLoading = false;

  List<UserItemModel> get inventory => _inventory;
  bool get isLoading => _isLoading;

  // =======================================================
  // 🔹 인벤토리 로드 / 추가 / 장착 / 구매 관련
  // =======================================================

  Future<void> loadInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 비동기 Firestore 호출은 unawaited로 백그라운드 처리
      unawaited(_service.getInventory(user.uid).then((loadedInventory) {
        _inventory = loadedInventory;
        _isLoading = false;
        notifyListeners();
      }).catchError((e, stacktrace) {
        debugPrint("❌ [InventoryProvider.loadInventory] 실패: $e");
        debugPrint("Stacktrace: $stacktrace");
        _inventory = [];
        _isLoading = false;
        notifyListeners();
      }));
    } catch (e, stacktrace) {
      debugPrint("❌ [InventoryProvider.loadInventory] 실패: $e");
      debugPrint("Stacktrace: $stacktrace");
      _inventory = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasItem(String itemId) {
    return _inventory.any((item) => item.itemId == itemId);
  }

  Future<void> addItem(UserItemModel userItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // 우선 로컬에 추가 반영
      _inventory.add(userItem);
      notifyListeners();

      // Firestore 저장은 백그라운드 처리
      unawaited(_service.addItem(user.uid, userItem).then((_) {
        // 재로딩 없이도 로컬 반영 유지
      }).catchError((e) {
        debugPrint("❌ [InventoryProvider.addItem] 실패: $e");
      }));
    } catch (e) {
      debugPrint("❌ [InventoryProvider.addItem] 실패: $e");
    }
  }

  Future<void> setEquipped(String itemId, bool equipped) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 로컬에서 즉시 변경
    final index = _inventory.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      _inventory[index] = _inventory[index].copyWith(equipped: equipped);
      notifyListeners();
    }

    try {
      // Firestore 저장은 백그라운드 처리
      unawaited(_service.setEquipped(user.uid, itemId, equipped).then((_) async {
        // 장착/해제 시, 캐릭터+셋트 이펙트 자동 재계산/저장 (비동기 병렬 처리)
        if (navigatorKey.currentContext != null) {
          final itemProvider = Provider.of<ItemProvider>(
            navigatorKey.currentContext!,
            listen: false,
          );
          unawaited(applySetEffects(itemProvider.items));
        }
      }).catchError((e) {
        debugPrint("❌ [InventoryProvider.setEquipped] 실패: $e");
      }));
    } catch (e) {
      debugPrint("❌ [InventoryProvider.setEquipped] 실패: $e");
    }
  }

  Future<void> updateEnhanceLevel(String itemId, int newLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 로컬에서 즉시 변경
    final index = _inventory.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      _inventory[index] = _inventory[index].copyWith(upgradeLevel: newLevel);
      notifyListeners();
    }

    try {
      // Firestore 저장은 백그라운드 처리
      unawaited(_service.updateEnhanceLevel(user.uid, itemId, newLevel).then((_) async {
        // 레벨 변화도 효과에 영향을 주므로 재계산 (비동기 병렬 처리)
        if (navigatorKey.currentContext != null) {
          final itemProvider = Provider.of<ItemProvider>(
            navigatorKey.currentContext!,
            listen: false,
          );
          unawaited(applySetEffects(itemProvider.items));
        }
      }).catchError((e) {
        debugPrint("❌ [InventoryProvider.updateEnhanceLevel] 실패: $e");
      }));
    } catch (e) {
      debugPrint("❌ [InventoryProvider.updateEnhanceLevel] 실패: $e");
    }
  }

  Future<String> purchaseItem(ItemModel item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '로그인이 필요합니다.';

      await _service.purchaseItemWithCurrency(user.uid, item);
      await loadInventory();

      // AppBar 재화 반영
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

      // 로컬 즉시 반영
      for (var doc in snapshot.docs) {
        final index = _inventory.indexWhere((item) => item.itemId == (doc.data()['item_id'] as String?));
        if (index != -1) {
          _inventory[index] = _inventory[index].copyWith(equipped: false);
        }
      }
      notifyListeners();

      // Firestore 업데이트는 백그라운드 처리
      unawaited(Future.wait(snapshot.docs.map((doc) => doc.reference.update({'equipped': false}))).then((_) async {
        // 해제 후에도 효과 재계산 (비동기 병렬 처리)
        if (navigatorKey.currentContext != null) {
          final itemProvider = Provider.of<ItemProvider>(
            navigatorKey.currentContext!,
            listen: false,
          );
          unawaited(applySetEffects(itemProvider.items));
        }
      }).catchError((e) {
        debugPrint("❌ [InventoryProvider.unequipCategory] 실패: $e");
      }));
    } catch (e) {
      debugPrint("❌ [InventoryProvider.unequipCategory] 실패: $e");
    }
  }

  Future<void> refresh() async => loadInventory();

  // =======================================================
  // 🧩 셋트 감지 도우미(선택적)
  // =======================================================

  String? getEquippedSetId() {
    final equippedItems = _inventory.where((i) => i.equipped).toList();
    if (equippedItems.isEmpty) return null;
    final setIds = equippedItems.map((i) => i.setId).whereType<String>().toSet();
    if (setIds.length == 1) return setIds.first;
    return null;
  }

  String? checkCompletedSet() {
    final equippedItems = _inventory.where((i) => i.equipped).toList();
    if (equippedItems.isEmpty) return null;
    final setIds = equippedItems.map((i) => i.setId).whereType<String>().toSet();

    for (final id in setIds) {
      final setItems = _inventory.where((i) => i.setId == id).toList();
      final equippedCount = setItems.where((i) => i.equipped).length;
      if (setItems.isNotEmpty && equippedCount == setItems.length) {
        return id;
      }
    }
    return null;
  }

  // =======================================================
  // 💾 캐릭터 + 셋트 이펙트(7종) 계산 → Firestore 저장 → UserProvider 동기화
  // =======================================================

  /// allItems: ItemProvider.items (전체 아이템 모델)
  Future<void> applySetEffects(List<ItemModel> allItems) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 기본값(0)으로 초기화
      Map<String, num> sum = {
        'time_limit_bonus': 0.0, // double
        'gold_bonus': 0.0,       // double
        'revive': 0,             // int
        'shuffle': 0,            // int
        'hint_bonus': 0,         // int
        'bomb_bonus': 0,         // int
        'obstacle_remove': 0,    // int
      };

      // 1) 현재 장착된 user_items 로드
      final equippedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_items')
          .where('equipped', isEqualTo: true)
          .get();

      if (equippedSnap.docs.isEmpty) {
        // 아무것도 장착 안했으면 0 저장
        unawaited(FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'set_effects': sum,
        }).then((_) async {
          debugPrint("✅ [applySetEffects] 장착 없음 → 효과 0 저장");
          if (navigatorKey.currentContext != null) {
            final userProvider = Provider.of<UserProvider>(navigatorKey.currentContext!, listen: false);
            await userProvider.loadUser();
          }
          notifyListeners();
        }).catchError((e) {
          debugPrint("❌ [applySetEffects] 장착 없음 저장 실패: $e");
        }));
        return;
      }

      // 2) 캐릭터 이펙트(장착된 캐릭터 1개) 먼저 합산
      QueryDocumentSnapshot<Map<String, dynamic>>? charDoc;
      try {
        charDoc = equippedSnap.docs.firstWhere(
          (d) => (d['category'] as String?) == ItemCategory.character.value,
        );
      } catch (_) {
        charDoc = null;
      }

      if (charDoc != null) {
        final charItemId = charDoc['item_id'] as String?;
        final upgradeLevel = (charDoc['upgrade_level'] as int?) ?? 1;
        if (charItemId != null && charItemId.isNotEmpty) {
          // 캐릭터 아이템 로직 그대로 유지
          ItemModel? charModel;
          try {
            charModel = allItems.firstWhere((m) => m.id == charItemId);
          } catch (_) {
            final fetched = await FirebaseFirestore.instance
                .collection('items')
                .doc(charItemId)
                .get();
            if (fetched.exists) {
              charModel = ItemModel.fromDoc(fetched);
            }
          }

          if (charModel != null && charModel.levels.isNotEmpty) {
            final eff = charModel.effectsForLevel(upgradeLevel);
            sum['time_limit_bonus'] = (sum['time_limit_bonus'] as double) + eff.timeLimitBonus;
            sum['gold_bonus']       = (sum['gold_bonus']       as double) + eff.goldBonus;
            sum['revive']           = (sum['revive']           as int)    + eff.revive;
            sum['shuffle']          = (sum['shuffle']          as int)    + eff.shuffle;
            sum['hint_bonus']       = (sum['hint_bonus']       as int)    + eff.hintBonus;
            sum['bomb_bonus']       = (sum['bomb_bonus']       as int)    + eff.bombBonus;
            sum['obstacle_remove']  = (sum['obstacle_remove']  as int)    + eff.obstacleRemove;
          }
        }
      }

      // 3) 셋트 완성 시 item_sets/{set_id}.effects 7종 추가 합산
      // 장착된 항목들을 set_id 기준으로 그룹핑하기 위해 items/{itemId}에서 set_id를 읽음
      final Map<String, Set<String>> setIdToEquippedItemIds = {};
      final List<Future<void>> setIdFutures = [];

      for (final d in equippedSnap.docs) {
        final itemId = d['item_id'] as String?;
        if (itemId == null || itemId.isEmpty) continue;

        setIdFutures.add(Future(() async {
          String? setId;
          try {
            final cached = allItems.firstWhere((m) => m.id == itemId);
            if (cached != null) {
              // cached에 set_id가 누락된 스키마라면 아래로 폴백
              final snap = await FirebaseFirestore.instance.collection('items').doc(itemId).get();
              setId = snap.data()?['set_id'] as String?;
            }
          } catch (_) {
            final snap = await FirebaseFirestore.instance.collection('items').doc(itemId).get();
            setId = snap.data()?['set_id'] as String?;
          }

          if (setId == null || setId.isEmpty) return;

          setIdToEquippedItemIds.putIfAbsent(setId, () => <String>{}).add(itemId);
        }));
      }

      await Future.wait(setIdFutures);

      final List<Future<void>> effectFutures = [];

      for (final entry in setIdToEquippedItemIds.entries) {
        effectFutures.add(Future(() async {
          final setId = entry.key;
          final equippedIds = entry.value;

          final setDoc = await FirebaseFirestore.instance.collection('item_sets').doc(setId).get();
          if (!setDoc.exists) return;

          final required = (setDoc.data()?['required_items'] as List?)?.whereType<String>().toSet() ?? <String>{};
          if (required.isEmpty) return;

          final isComplete = required.difference(equippedIds).isEmpty;
          if (!isComplete) return;

          final fx = (setDoc.data()?['effects'] as Map?)?.cast<String, dynamic>() ?? const {};
          double fxTime   = (fx['time_limit_bonus'] as num?)?.toDouble() ?? 0.0;
          double fxGold   = (fx['gold_bonus']       as num?)?.toDouble() ?? 0.0;
          int    fxRev    = (fx['revive']           as num?)?.toInt()    ?? 0;
          int    fxShuffle= (fx['shuffle']          as num?)?.toInt()    ?? 0;
          int    fxHint   = (fx['hint_bonus']       as num?)?.toInt()    ?? 0;
          int    fxBomb   = (fx['bomb_bonus']       as num?)?.toInt()    ?? 0;
          int    fxObs    = (fx['obstacle_remove']  as num?)?.toInt()    ?? 0;

          sum['time_limit_bonus'] = (sum['time_limit_bonus'] as double) + fxTime;
          sum['gold_bonus']       = (sum['gold_bonus']       as double) + fxGold;
          sum['revive']           = (sum['revive']           as int)    + fxRev;
          sum['shuffle']          = (sum['shuffle']          as int)    + fxShuffle;
          sum['hint_bonus']       = (sum['hint_bonus']       as int)    + fxHint;
          sum['bomb_bonus']       = (sum['bomb_bonus']       as int)    + fxBomb;
          sum['obstacle_remove']  = (sum['obstacle_remove']  as int)    + fxObs;
        }));
      }

      await Future.wait(effectFutures);

      // 4) Firestore 저장 (백그라운드 처리)
      unawaited(FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'set_effects': sum,
      }).then((_) async {
        debugPrint("✅ [applySetEffects] 최종 저장 set_effects: $sum");

        // 5) UserProvider 동기화
        if (navigatorKey.currentContext != null) {
          final userProvider = Provider.of<UserProvider>(navigatorKey.currentContext!, listen: false);
          await userProvider.loadUser();
        }

        notifyListeners();
      }).catchError((e) {
        debugPrint("❌ [applySetEffects] 실패: $e");
      }));
    } catch (e) {
      debugPrint("❌ [applySetEffects] 실패: $e");
    }
  }
}