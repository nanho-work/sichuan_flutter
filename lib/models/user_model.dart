import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String loginType;
  final int gold;
  final int gems;
  final int energy;
  final int energyMax;
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime energyLastRefill;
  final int hints;
  final int bombs;
  final int shuffle;
  final int currentStage;
  final int adEnergyCount;
  final DateTime? adEnergyDate;
  final ItemEffects? setEffects;

  /// ✅ 새로 추가된 필드 (optional)
  /// Firestore에 없으면 기본값 {} 으로 안전하게 동작
  final Map<String, dynamic> stageProgress;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    required this.loginType,
    required this.gold,
    required this.gems,
    required this.energy,
    required this.energyMax,
    required this.createdAt,
    required this.lastLogin,
    required this.energyLastRefill,
    required this.hints,
    required this.bombs,
    required this.shuffle,
    required this.currentStage,
    this.adEnergyCount = 0,
    this.adEnergyDate,
    this.setEffects,
    this.stageProgress = const {},
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      loginType: data['login_type'] ?? 'guest',
      gold: data['gold'] ?? 0,
      gems: data['gems'] ?? 0,
      energy: data['energy'] ?? 7,
      energyMax: data['energy_max'] ?? 7,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['last_login'] as Timestamp?)?.toDate() ?? DateTime.now(),
      energyLastRefill:
          (data['energy_last_refill'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hints: data['hints'] ?? 0,
      bombs: data['bombs'] ?? 0,
      shuffle: data['shuffle'] ?? 0,
      currentStage: data['current_stage'] ?? 1,
      adEnergyCount: data['ad_energy_count'] ?? 0,
      adEnergyDate: (data['ad_energy_date'] is Timestamp)
          ? (data['ad_energy_date'] as Timestamp).toDate()
          : null,
      setEffects: data['set_effects'] != null
          ? ItemEffects.fromMap(
              data['set_effects'] as Map<String, dynamic>,
            )
          : null,
      stageProgress: Map<String, dynamic>.from(data['stage_progress'] ?? const {}),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      loginType: data['login_type'] ?? 'guest',
      gold: data['gold'] ?? 0,
      gems: data['gems'] ?? 0,
      energy: data['energy'] ?? 7,
      energyMax: data['energy_max'] ?? 7,
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      lastLogin: (data['last_login'] is Timestamp)
          ? (data['last_login'] as Timestamp).toDate()
          : DateTime.tryParse(data['last_login'] ?? '') ?? DateTime.now(),
      energyLastRefill: (data['energy_last_refill'] is Timestamp)
          ? (data['energy_last_refill'] as Timestamp).toDate()
          : DateTime.tryParse(data['energy_last_refill'] ?? '') ?? DateTime.now(),
      hints: data['hints'] ?? 0,
      bombs: data['bombs'] ?? 0,
      shuffle: data['shuffle'] ?? 0,
      currentStage: data['current_stage'] ?? 1,
      adEnergyCount: data['ad_energy_count'] ?? 0,
      adEnergyDate: (data['ad_energy_date'] is Timestamp)
          ? (data['ad_energy_date'] as Timestamp).toDate()
          : null,
      setEffects: data['set_effects'] != null
          ? ItemEffects.fromMap(data['set_effects'] as Map<String, dynamic>)
          : null,
      stageProgress: Map<String, dynamic>.from(data['stage_progress'] ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'nickname': nickname,
      'email': email,
      'login_type': loginType,
      'gold': gold,
      'gems': gems,
      'energy': energy,
      'energy_max': energyMax,
      // 🔁 Store DateTime as ISO8601 string
      'created_at': Timestamp.fromDate(createdAt),
      'last_login': Timestamp.fromDate(lastLogin),
      'energy_last_refill': Timestamp.fromDate(energyLastRefill),
      'hints': hints,
      'bombs': bombs,
      'shuffle': shuffle,
      'current_stage': currentStage,
      'ad_energy_count': adEnergyCount,
      // 🔁 Optional date as ISO8601 string or null
      'ad_energy_date': adEnergyDate?.toIso8601String(),
    };
    if (setEffects != null) {
      map['set_effects'] = setEffects!.toMap();
    }
    if (stageProgress.isNotEmpty) {
      map['stage_progress'] = stageProgress;
    }
    return map;
  }

  String toJsonString() => jsonEncode(toMap());

  static UserModel fromJsonString(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  UserModel copyWith(Map<String, dynamic> changes) {
    return UserModel(
      uid: changes['uid'] ?? uid,
      nickname: changes['nickname'] ?? nickname,
      email: changes['email'] ?? email,
      loginType: changes['login_type'] ?? loginType,
      gold: changes['gold'] ?? gold,
      gems: changes['gems'] ?? gems,
      energy: changes['energy'] ?? energy,
      energyMax: changes['energy_max'] ?? energyMax,
      createdAt: changes['created_at'] ?? createdAt,
      lastLogin: changes['last_login'] ?? lastLogin,
      energyLastRefill: changes['energy_last_refill'] ?? energyLastRefill,
      hints: changes['hints'] ?? hints,
      bombs: changes['bombs'] ?? bombs,
      shuffle: changes['shuffle'] ?? shuffle,
      currentStage: changes['current_stage'] ?? currentStage,
      adEnergyCount: changes['ad_energy_count'] ?? adEnergyCount,
      adEnergyDate: changes['ad_energy_date'] ?? adEnergyDate,
      setEffects: changes['set_effects'] ?? setEffects,
      stageProgress: changes['stage_progress'] ?? stageProgress,
    );
  }

  bool get adLimitReached {
    if (adEnergyDate == null) return false;
    final now = DateTime.now();
    final d = adEnergyDate!;
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    return isToday && adEnergyCount >= 3;
  }

  // ---------- 진행도 헬퍼 ----------
  bool isStageUnlocked(String stageId) {
    final m = stageProgress[stageId] as Map<String, dynamic>?;
    return (m?['unlocked'] == true);
  }

  bool isStageCleared(String stageId) {
    final m = stageProgress[stageId] as Map<String, dynamic>?;
    return (m?['cleared'] == true);
  }

  int bestTime(String stageId) {
    final m = stageProgress[stageId] as Map<String, dynamic>?;
    return (m?['best_time'] as int?) ?? 9999999;
  }
}