import 'package:cloud_firestore/cloud_firestore.dart';
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
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromDoc(doc);
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
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
    final snapshot = await _db
        .collection('stages')
        .where('difficulty', isEqualTo: difficulty)
        .get();

    return snapshot.docs.map((e) => StageModel.fromDoc(e)).toList();
  }

  Future<StageModel?> getStage(String stageId, String difficulty) async {
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
  }

  // =======================================================
  // 🔹 RECORDS
  // =======================================================
  Future<void> saveRecord(RecordModel record) async {
    await _db.collection('records').add(record.toMap());
  }

  Future<List<RecordModel>> getUserRecords(String uid) async {
    final snapshot =
        await _db.collection('records').where('uid', isEqualTo: uid).get();

    return snapshot.docs.map((e) => RecordModel.fromDoc(e)).toList();
  }

  Future<List<RecordModel>> getRanking(String stageId, String difficulty) async {
    final snapshot = await _db
        .collection('records')
        .where('stage_id', isEqualTo: stageId)
        .where('difficulty', isEqualTo: difficulty)
        .orderBy('score', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((e) => RecordModel.fromDoc(e)).toList();
  }

  // =======================================================
  // 🔹 SHOP ITEMS
  // =======================================================
  Future<List<ShopItemModel>> getShopItems(String category) async {
    final snapshot = await _db
        .collection('shop_items')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((e) => ShopItemModel.fromDoc(e)).toList();
  }

  Future<ShopItemModel?> getShopItemById(String itemId) async {
    final doc = await _db.collection('shop_items').doc(itemId).get();
    if (doc.exists) return ShopItemModel.fromDoc(doc);
    return null;
  }

  // =======================================================
  // 🔹 USER ITEMS
  // =======================================================
  Future<List<UserItemModel>> getUserItems(String uid) async {
    final snapshot =
        await _db.collection('user_items').where('uid', isEqualTo: uid).get();

    return snapshot.docs.map((e) => UserItemModel.fromDoc(e)).toList();
  }

  Future<void> addUserItem(UserItemModel item) async {
    await _db.collection('user_items').add(item.toMap());
  }

  Future<void> updateUserItem(
      String uid, String itemId, Map<String, dynamic> data) async {
    final snapshot = await _db
        .collection('user_items')
        .where('uid', isEqualTo: uid)
        .where('item_id', isEqualTo: itemId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update(data);
    }
  }

  // =======================================================
  // 🔹 ATTENDANCE EVENTS
  // =======================================================
  Future<AttendanceEvent?> getActiveAttendanceEvent() async {
    final snapshot = await _db
        .collection('attendance_events')
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AttendanceEvent.fromDoc(snapshot.docs.first);
    }
    return null;
  }

  // =======================================================
  // 🔹 USER ATTENDANCE
  // =======================================================
  Future<UserAttendance?> getUserAttendance(String uid, String eventId) async {
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
  }

  Future<void> createUserAttendance(UserAttendance attendance) async {
    await _db.collection('user_attendance').add(attendance.toMap());
  }

  Future<void> updateUserAttendance(
      String uid, String eventId, Map<String, dynamic> data) async {
    final snapshot = await _db
        .collection('user_attendance')
        .where('uid', isEqualTo: uid)
        .where('event_id', isEqualTo: eventId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update(data);
    }
  }

  // =======================================================
  // 🔹 TRANSACTION 예시 (에너지, 골드 업데이트)
  // =======================================================
  Future<void> modifyUserGold(String uid, int amount) async {
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      if (!snapshot.exists) return;
      final currentGold = snapshot['gold'] ?? 0;
      tx.update(userRef, {'gold': currentGold + amount});
    });
  }

  Future<void> modifyUserEnergy(String uid, int delta) async {
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      if (!snapshot.exists) return;
      final currentEnergy = snapshot['energy'] ?? 0;
      tx.update(userRef, {'energy': currentEnergy + delta});
    });
  }

  // =======================================================
  // 🔹 UTILITIES
  // =======================================================
  Future<bool> checkUserExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}