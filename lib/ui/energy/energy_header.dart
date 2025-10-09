import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sichuan_flutter/ui/energy/energy_dialog.dart';
import 'package:sichuan_flutter/services/energy_service.dart';
import '../../managers/image_manager.dart';

class EnergyHeader extends StatefulWidget {
  const EnergyHeader({super.key});

  @override
  State<EnergyHeader> createState() => _EnergyHeaderState();
}

class _EnergyHeaderState extends State<EnergyHeader> {
  final user = FirebaseAuth.instance.currentUser!;
  final energyService = EnergyService();
  Timer? _timer;

  int energy = 0;
  int maxEnergy = 0;
  DateTime? lastRefill;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadEnergy();
    _startTimer();
  }

  Future<void> _loadEnergy() async {
    await energyService.autoRecharge(user.uid);
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data()!;
    setState(() {
      energy = data['energy'];
      maxEnergy = data['energy_max'];
      lastRefill = (data['energy_last_refill'] as Timestamp).toDate();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (lastRefill == null || energy >= maxEnergy) {
        setState(() => remaining = Duration.zero);
        return;
      }

      final now = DateTime.now();
      final elapsed = now.difference(lastRefill!);
      final nextRefill = const Duration(minutes: 10) - Duration(
        minutes: elapsed.inMinutes % 10,
        seconds: elapsed.inSeconds % 60,
      );

      // 남은 시간 표시
      setState(() {
        remaining = nextRefill;
      });

      // 자동 충전 시점 도달
      if (elapsed >= const Duration(minutes: 10)) {
        await energyService.autoRecharge(user.uid);
        await _loadEnergy();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageManager.instance.getCurrencyIcon(CurrencyType.energy, size: 20),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$energy / $maxEnergy",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (energy < maxEnergy)
              Text(
                "$minutes:$seconds",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const EnergyDialog(),
            ).then((_) => _loadEnergy()); // 다이얼로그 닫히면 즉시 갱신
          },
          child: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
        ),
      ],
    );
  }
}