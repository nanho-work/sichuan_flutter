import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      energyLastRefill: (data['energy_last_refill'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hints: data['hints'] ?? 0,
      bombs: data['bombs'] ?? 0,
      shuffle: data['shuffle'] ?? 0,
      currentStage: data['current_stage'] ?? 1,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'email': email,
      'login_type': loginType,
      'gold': gold,
      'gems': gems,
      'energy': energy,
      'energy_max': energyMax,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'energy_last_refill': energyLastRefill.toIso8601String(),
      'hints': hints,
      'bombs': bombs,
      'shuffle': shuffle,
      'current_stage': currentStage,
    };
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
    );
  }
}