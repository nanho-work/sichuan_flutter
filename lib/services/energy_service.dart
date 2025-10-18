import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Duration refillInterval = Duration(minutes: 10);

  Future<void> autoRecharge(String uid) async {
    int gained = 0;
    DateTime now = DateTime.now();
    final ref = _db.collection('users').doc(uid);

    await _db.runTransaction((t) async {
      final snapshot = await t.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final int currentEnergy = data['energy'] ?? 0;
      final int maxEnergy = data['energy_max'] ?? 0;
      final DateTime lastRefill =
          (data['energy_last_refill'] as Timestamp).toDate();

      if (currentEnergy >= maxEnergy) return;

      final elapsed = now.difference(lastRefill);
      gained = elapsed.inMinutes ~/ refillInterval.inMinutes;

      if (gained <= 0) return;

      final newEnergy = (currentEnergy + gained).clamp(0, maxEnergy);
      final newRefillTime = lastRefill.add(refillInterval * gained);

      t.update(ref, {
        'energy': newEnergy,
        'energy_last_refill': newRefillTime,
      });
    });

    if (gained > 0) {
      await ref.collection('energy_transactions').add({
        'type': 'auto_recharge',
        'amount': gained,
        'created_at': now,
      });
    }
  }
}