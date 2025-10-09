import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 10분마다 1회 자동 충전
  static const Duration refillInterval = Duration(minutes: 10);

  /// 자동 충전 처리
  Future<void> autoRecharge(String uid) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((t) async {
      final snapshot = await t.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final int currentEnergy = data['energy'] ?? 0;
      final int maxEnergy = data['energy_max'] ?? 0;
      final DateTime lastRefill = (data['energy_last_refill'] as Timestamp).toDate();

      if (currentEnergy >= maxEnergy) return;

      final now = DateTime.now();
      final elapsed = now.difference(lastRefill);
      final gained = elapsed.inMinutes ~/ refillInterval.inMinutes;

      if (gained <= 0) return;

      final newEnergy = (currentEnergy + gained).clamp(0, maxEnergy);
      final newRefillTime = lastRefill.add(refillInterval * gained);

      t.update(ref, {
        'energy': newEnergy,
        'energy_last_refill': newRefillTime,
      });

      await ref.collection('energy_transactions').add({
        'type': 'auto_recharge',
        'amount': gained,
        'created_at': now,
      });
    });
  }
}