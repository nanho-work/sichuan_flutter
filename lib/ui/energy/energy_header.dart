import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sichuan_flutter/providers/user_provider.dart';
import 'package:sichuan_flutter/ui/energy/energy_dialog.dart';
import '../../managers/image_manager.dart';
import 'dart:async';

class EnergyHeader extends StatefulWidget {
  const EnergyHeader({super.key});

  @override
  _EnergyHeaderState createState() => _EnergyHeaderState();
}

class _EnergyHeaderState extends State<EnergyHeader> {
  Timer? _timer;

  Duration _calculateRemaining(DateTime lastRefill, int energy, int maxEnergy) {
    if (energy >= maxEnergy) return Duration.zero;
    final now = DateTime.now();
    final elapsed = now.difference(lastRefill);
    final nextRefill = const Duration(minutes: 10) - Duration(
      minutes: elapsed.inMinutes % 10,
      seconds: elapsed.inSeconds % 60,
    );
    return nextRefill;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final remaining = _calculateRemaining(user.energyLastRefill, user.energy, user.energyMax);
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
              "${user.energy} / ${user.energyMax}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.energy < user.energyMax)
              Text(
                "$minutes:$seconds",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => const EnergyDialog(),
            );
            await userProvider.loadUser();
          },
          child: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
        ),
      ],
    );
  }
}