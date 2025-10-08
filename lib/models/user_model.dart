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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'login_type': loginType,
      'gold': gold,
      'gems': gems,
      'energy': energy,
      'energy_max': energyMax,
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }
}