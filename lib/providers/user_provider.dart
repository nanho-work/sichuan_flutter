// lib/providers/user_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _userService = UserService();
  UserModel? _user;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub; // ✅ 실시간 구독
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> get inventory => _inventory;

  Future<void> loadFromCacheIfNeeded(Future<void> Function() cacheLoader) async {
    if (_inventory.isEmpty) {
      await cacheLoader();
      notifyListeners();
    }
  }

  UserModel? get user => _user;
  bool get isLoaded => _user != null;

  /// ✅ 초기 로드 (앱 시작 시 or 로그인 직후)
  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1) 최초 1회 fetch (원본 유지)
    final model = await _userService.getUserModel(user.uid);
    if (model != null) {
      _user = model;
      notifyListeners();
      // ✅ 인벤토리 자동 캐싱
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('user_items')
          .get();

      if (itemsSnapshot.docs.isNotEmpty) {
        _inventory = itemsSnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        // 🔹 user_items가 없으면 기본 지급 아이템으로 로컬 세팅
        _inventory = [
          {
            'item_id': 'char_default',
            'category': 'character',
            'equipped': true,
            'source': 'default',
          },
          {
            'item_id': 'block_fruit',
            'category': 'block_set',
            'equipped': true,
            'source': 'default',
          },
          {
            'item_id': 'bg_basic',
            'category': 'background',
            'equipped': true,
            'source': 'default',
          },
        ];
      }
      notifyListeners();
    }

    // 2) ✅ 실시간 구독 추가 (중복 구독 방지)
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      _user = UserModel.fromDoc(doc);
      notifyListeners();
    });
  }

  /// ✅ 특정 필드 업데이트
  Future<void> updateField(String key, dynamic value) async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({key: value});
    _user = _user!.copyWith({key: value});
    notifyListeners();
  }

  /// ✅ 광고로 에너지 복구
  Future<void> restoreEnergyViaAd() async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _userService.restoreEnergyViaAd(uid);
    // ❌ 굳이 loadUser() 재호출 불필요 — 스냅샷이 알아서 반영
  }

  /// ✅ 젬으로 에너지 복구
  Future<void> restoreEnergyViaGem(int gemCost) async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _userService.restoreEnergyViaGem(uid, gemCost);
    // ❌ 스냅샷이 알아서 반영
  }

  Future<void> updateGold(int newGold) async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({'gold': newGold});
    _user = _user!.copyWith({'gold': newGold});
    notifyListeners();
  }

  Future<void> consumeEnergy(int amount) async {
    if (_user == null) throw Exception("로그인이 필요합니다.");
    final uid = _user!.uid;
    await _userService.consumeEnergy(uid, amount);
    // ❌ 스냅샷이 알아서 반영
  }

  @override
  void dispose() {
    _sub?.cancel(); // ✅ 메모리 누수 방지
    super.dispose();
  }
}