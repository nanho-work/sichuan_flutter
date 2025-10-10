import 'package:flutter/material.dart';
import '../../../../models/item_model.dart';

class EffectGrid extends StatelessWidget {
  const EffectGrid({super.key, required this.effects});
  final ItemEffects effects;

  @override
  Widget build(BuildContext context) {
    // ✅ Map 리터럴로 수정
    final map = <String, dynamic>{
      '⏱ 시간 보너스': effects.timeLimitBonus,
      '🪙 골드 보너스': effects.goldBonus,
      '💡 힌트': effects.hintBonus,
      '💥 폭탄': effects.bombBonus,
      '❤️ 리바이브': effects.revive,
      '🔀 섞기': effects.shuffle,
      '🪓 장애물 제거': effects.obstacleRemove,
    };

    // 0이 아닌 값만 필터링
    final entries = map.entries.where((e) => e.value != 0).toList();

    if (entries.isEmpty) {
      return const Text('표시할 능력치가 없어요', style: TextStyle(color: Colors.black54));
    }

    return Column(
      children: entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                  child: Text(e.key, style: const TextStyle(color: Colors.black87))),
              Text('${e.value}',
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}