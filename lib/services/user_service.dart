import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime _toDateTime(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return v as DateTime;
  }

  // =======================================================
  // 🔹 유저 데이터 초기화 (최초 로그인 시)
  // =======================================================
  Future<UserModel> initializeUserData(User user, {String loginType = 'google'}) async {
    final usersRef = _db.collection('users').doc(user.uid);
    final doc = await usersRef.get();

    final Map<String, dynamic> baseData = {
      'uid': user.uid,
      'nickname': user.displayName ?? "게스트",
      'email': user.email ?? "guest@koofy.games",
      'login_type': loginType,
      'gold': 100,
      'gems': 3,
      'energy': 7,
      'energy_max': 7,
      'energy_last_refill': DateTime.now(),
      'hints': 3,
      'bombs': 2,
      'shuffle': 2,
      'current_stage': 1,
      'created_at': DateTime.now(),
      'last_login': DateTime.now(),
    };

    if (!doc.exists) {
      await usersRef.set(baseData);

      await usersRef.collection('user_items').doc('char_default').set({
        'item_id': 'char_default',
        'category': 'character',
        'owned_at': DateTime.now(),
        'equipped': true,
        'source': 'default',
        'upgrade_level': 1,
      });

      await usersRef.collection('energy_transactions').add({
        'type': 'init',
        'amount': 7,
        'created_at': DateTime.now(),
      });

      await usersRef.collection('user_effects_cache').doc('cache').set({
        'effects': {},
        'updated_at': DateTime.now(),
      });
    } else {
      await usersRef.update({'last_login': DateTime.now()});
    }

    final latest = await usersRef.get();
    final data = latest.data() ?? baseData;

    return UserModel(
      uid: data['uid'],
      nickname: data['nickname'],
      email: data['email'],
      loginType: data['login_type'],
      gold: (data['gold'] as num).toInt(),
      gems: (data['gems'] as num).toInt(),
      energy: (data['energy'] as num).toInt(),
      energyMax: (data['energy_max'] as num).toInt(),
      energyLastRefill: _toDateTime(data['energy_last_refill']),
      hints: (data['hints'] as num).toInt(),
      bombs: (data['bombs'] as num).toInt(),
      shuffle: (data['shuffle'] as num).toInt(),
      currentStage: (data['current_stage'] as num).toInt(),
      createdAt: _toDateTime(data['created_at']),
      lastLogin: _toDateTime(data['last_login']),
    );
  }

  // =======================================================
  // 🔹 유저 조회
  // =======================================================
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    DateTime toDT(dynamic v) => v is Timestamp ? v.toDate() : v as DateTime;

    return UserModel(
      uid: data['uid'],
      nickname: data['nickname'],
      email: data['email'],
      loginType: data['login_type'],
      gold: (data['gold'] as num).toInt(),
      gems: (data['gems'] as num).toInt(),
      energy: (data['energy'] as num).toInt(),
      energyMax: (data['energy_max'] as num).toInt(),
      energyLastRefill: toDT(data['energy_last_refill']),
      hints: (data['hints'] as num).toInt(),
      bombs: (data['bombs'] as num).toInt(),
      shuffle: (data['shuffle'] as num).toInt(),
      currentStage: (data['current_stage'] as num).toInt(),
      createdAt: toDT(data['created_at']),
      lastLogin: toDT(data['last_login']),
    );
  }

  // =======================================================
  // 🔹 유저 데이터 갱신
  // =======================================================
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // =======================================================
  // 🔹 유저 삭제
  // =======================================================
  Future<void> deleteUserData(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final subCollections = ['user_items', 'energy_transactions', 'user_effects_cache'];

    for (final sub in subCollections) {
      final snapshots = await userRef.collection(sub).get();
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }

    await userRef.delete();
  }

  // =======================================================
  // ⚡ 에너지 관련 기능
  // =======================================================

  // 1️⃣ 에너지 소모
  Future<void> consumeEnergy(String uid, int amount) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((t) async {
      final snapshot = await t.get(ref);
      final current = snapshot['energy'] as int;
      if (current < amount) throw Exception('에너지가 부족합니다.');
      t.update(ref, {'energy': current - amount});
    });
  }

  // 2️⃣ 광고로 충전 (+5)
  Future<void> restoreEnergyViaAd(String uid) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((t) async {
      final snapshot = await t.get(ref);
      final current = snapshot['energy'] as int;
      final max = snapshot['energy_max'] as int;
      final newEnergy = (current + 5).clamp(0, max);
      t.update(ref, {
        'energy': newEnergy,
        'energy_last_refill': DateTime.now(),
      });
      await ref.collection('energy_transactions').add({
        'type': 'ad_reward',
        'amount': 5,
        'created_at': DateTime.now(),
      });
    });
  }

  // 3️⃣ 젬으로 충전 (젬 10개 소모 → +5 에너지)
  Future<void> restoreEnergyViaGem(String uid, int gemCost) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((t) async {
      final snapshot = await t.get(ref);
      final currentGems = snapshot['gems'] as int;
      final currentEnergy = snapshot['energy'] as int;
      final maxEnergy = snapshot['energy_max'] as int;

      if (currentGems < gemCost) throw Exception('젬이 부족합니다.');

      final newEnergy = (currentEnergy + 5).clamp(0, maxEnergy);
      t.update(ref, {
        'gems': currentGems - gemCost,
        'energy': newEnergy,
        'energy_last_refill': DateTime.now(),
      });
      await ref.collection('energy_transactions').add({
        'type': 'gem_refill',
        'amount': 5,
        'cost_gems': gemCost,
        'created_at': DateTime.now(),
      });
    });
  }
}