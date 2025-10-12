import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';

class GameBar extends StatelessWidget {
  const GameBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().state;
    final time = state?.timeLeft ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(color: Colors.black87),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Text('$time s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (state?.cleared == true)
            const Text('CLEAR!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          if (state?.failed == true)
            const Text('TIME OVER', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}