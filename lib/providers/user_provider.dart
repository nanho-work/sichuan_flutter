import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _userService = UserService();
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoaded => _user != null;

  /// ✅ 초기 로드 (앱 시작 시 or 로그인 직후)
  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final model = await _userService.getUserModel(user.uid);
    if (model != null) {
      _user = model;
      notifyListeners();
    }
  }

  /// ✅ 특정 필드 업데이트
  Future<void> updateField(String key, dynamic value) async {
    if (_user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({key: value});
    _user = _user!.copyWith({key: value});
    notifyListeners();
  }

  /// ✅ 광고로 에너지 복구
  Future<void> restoreEnergyViaAd() async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _userService.restoreEnergyViaAd(uid);
    await loadUser(); // Firestore에서 최신 데이터 다시 가져오기
  }

  /// ✅ 젬으로 에너지 복구
  Future<void> restoreEnergyViaGem(int gemCost) async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _userService.restoreEnergyViaGem(uid, gemCost);
    await loadUser();
  }
}