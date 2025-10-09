import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/stage_model.dart';
import '../models/record_model.dart';
import '../models/shop_item_model.dart';
import '../models/user_item_model.dart';
import '../models/attendance_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================
  // 🔹 USERS
  // =======================================================
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('createUser error: $e');
    }
  }

  /// getUser: 자동 last_login 갱신 + SharedPreferences 캐시 반영 + null-safe 처리
  Future<UserModel?> getUser(String uid) async {
    try {
      // 1. 캐시에서 먼저 시도
      final prefs = await SharedPreferences.getInstance();
      final cachedUser = prefs.getString('user_$uid');
      if (cachedUser != null) {
        try {
          final user = UserModel.fromJsonString(cachedUser);
          // Firestore에서 최신 last_login 갱신
          await updateUser(uid, {'last_login': FieldValue.serverTimestamp()});
          // Firestore에서 새로 받아오기(동기화)
          final doc = await _db.collection('users').doc(uid).get();
          if (doc.exists) {
            final freshUser = UserModel.fromDoc(doc);
            await prefs.setString('user_$uid', freshUser.toJsonString());
            return freshUser;
          }
          return user;
        } catch (e) {
          print('getUser cache decode error: $e');
        }
      }
      // 2. 캐시 없을 때 Firestore에서 받아오기
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromDoc(doc);
        // last_login 자동 갱신
        await updateUser(uid, {'last_login': FieldValue.serverTimestamp()});
        // 캐시 저장
        await prefs.setString('user_$uid', user.toJsonString());
        return user;
      }
      return null;
    } catch (e) {
      print('getUser error: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      print('updateUser error: $e');
    }
  }

  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromDoc(doc);
      return null;
    });
  }

  // =======================================================
  // 🔹 STAGES
  // =======================================================
  Future<List<StageModel>> getStages(String difficulty) async {
    try {
      final snapshot = await _db
          .collection('stages')
          .where('difficulty', isEqualTo: difficulty)
          .get();
      return snapshot.docs.map((e) => StageModel.fromDoc(e)).toList();
    } catch (e) {
      print('getStages error: $e');
      return [];
    }
  }

  Future<StageModel?> getStage(String stageId, String difficulty) async {
    try {
      final snapshot = await _db
          .collection('stages')
          .where('stage_id', isEqualTo: stageId)
          .where('difficulty', isEqualTo: difficulty)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return StageModel.fromDoc(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('getStage error: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 RECORDS
  // =======================================================
  Future<void> saveRecord(RecordModel record) async {
    try {
      await _db.collection('records').add(record.toMap());
    } catch (e) {
      print('saveRecord error: $e');
    }
  }

  Future<List<RecordModel>> getUserRecords(String uid) async {
    try {
      final snapshot =
          await _db.collection('records').where('uid', isEqualTo: uid).get();
      return snapshot.docs.map((e) => RecordModel.fromDoc(e)).toList();
    } catch (e) {
      print('getUserRecords error: $e');
      return [];
    }
  }

  Future<List<RecordModel>> getRanking(String stageId, String difficulty) async {
    try {
      final snapshot = await _db
          .collection('records')
          .where('stage_id', isEqualTo: stageId)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('score', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((e) => RecordModel.fromDoc(e)).toList();
    } catch (e) {
      print('getRanking error: $e');
      return [];
    }
  }

  // =======================================================
  // 🔹 SHOP ITEMS
  // =======================================================
  Future<List<ShopItemModel>> getShopItems(String category) async {
    try {
      final snapshot = await _db
          .collection('shop_items')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((e) => ShopItemModel.fromDoc(e)).toList();
    } catch (e) {
      print('getShopItems error: $e');
      return [];
    }
  }

  Future<ShopItemModel?> getShopItemById(String itemId) async {
    try {
      final doc = await _db.collection('shop_items').doc(itemId).get();
      if (doc.exists) return ShopItemModel.fromDoc(doc);
      return null;
    } catch (e) {
      print('getShopItemById error: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 USER ITEMS
  // =======================================================
  Future<List<UserItemModel>> getUserItems(String uid) async {
    try {
      final snapshot =
          await _db.collection('user_items').where('uid', isEqualTo: uid).get();
      return snapshot.docs.map((e) => UserItemModel.fromDoc(e)).toList();
    } catch (e) {
      print('getUserItems error: $e');
      return [];
    }
  }

  Future<void> addUserItem(UserItemModel item) async {
    try {
      await _db.collection('user_items').add(item.toMap());
    } catch (e) {
      print('addUserItem error: $e');
    }
  }

  Future<void> updateUserItem(
      String uid, String itemId, Map<String, dynamic> data) async {
    try {
      final snapshot = await _db
          .collection('user_items')
          .where('uid', isEqualTo: uid)
          .where('item_id', isEqualTo: itemId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(data);
      }
    } catch (e) {
      print('updateUserItem error: $e');
    }
  }

  // =======================================================
  // 🔹 ATTENDANCE EVENTS
  // =======================================================
  Future<AttendanceEvent?> getActiveAttendanceEvent() async {
    try {
      final snapshot = await _db
          .collection('attendance_events')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return AttendanceEvent.fromDoc(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('getActiveAttendanceEvent error: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 USER ATTENDANCE
  // =======================================================
  Future<UserAttendance?> getUserAttendance(String uid, String eventId) async {
    try {
      final snapshot = await _db
          .collection('user_attendance')
          .where('uid', isEqualTo: uid)
          .where('event_id', isEqualTo: eventId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return UserAttendance.fromDoc(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('getUserAttendance error: $e');
      return null;
    }
  }

  Future<void> createUserAttendance(UserAttendance attendance) async {
    try {
      await _db.collection('user_attendance').add(attendance.toMap());
    } catch (e) {
      print('createUserAttendance error: $e');
    }
  }

  Future<void> updateUserAttendance(
      String uid, String eventId, Map<String, dynamic> data) async {
    try {
      final snapshot = await _db
          .collection('user_attendance')
          .where('uid', isEqualTo: uid)
          .where('event_id', isEqualTo: eventId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update(data);
      }
    } catch (e) {
      print('updateUserAttendance error: $e');
    }
  }

  // =======================================================
  // 🔹 TRANSACTION 예시 (에너지, 골드 업데이트)
  // =======================================================
  Future<void> modifyUserGold(String uid, int amount) async {
    final userRef = _db.collection('users').doc(uid);
    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(userRef);
        if (!snapshot.exists) return;
        final currentGold = (snapshot['gold'] ?? 0) as int;
        final newGold = (currentGold + amount).clamp(0, 999999999);
        tx.update(userRef, {'gold': newGold});
      });
    } catch (e) {
      print('modifyUserGold error: $e');
    }
  }

  Future<void> modifyUserEnergy(String uid, int delta) async {
    final userRef = _db.collection('users').doc(uid);
    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(userRef);
        if (!snapshot.exists) return;
        final currentEnergy = (snapshot['energy'] ?? 0) as int;
        final newEnergy = (currentEnergy + delta).clamp(0, 999999999);
        tx.update(userRef, {'energy': newEnergy});
      });
    } catch (e) {
      print('modifyUserEnergy error: $e');
    }
  }

  // =======================================================
  // 🔹 UTILITIES
  // =======================================================
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('checkUserExists error: $e');
      return false;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      print('deleteUser error: $e');
    }
  }
}