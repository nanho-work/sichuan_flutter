import 'package:flutter/material.dart';
import '../../../../models/item_model.dart';

/// 🎯 아이템 효과 가이드 위젯 (효과 수치 시각화)
class EffectGuide extends StatelessWidget {
  final ItemEffects effects;
  const EffectGuide({super.key, required this.effects});

  Widget _buildEffect(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: Colors.white54),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💡 효과 가이드",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          _buildEffect("추가 시간", "+${effects.timeLimitBonus}s", icon: Icons.timer),
          _buildEffect("힌트 보너스", "+${effects.hintBonus}", icon: Icons.lightbulb_outline),
          _buildEffect("폭탄 보너스", "+${effects.bombBonus}", icon: Icons.bolt),
          _buildEffect("부활", "+${effects.revive}", icon: Icons.favorite),
          _buildEffect("셔플", "+${effects.shuffle}", icon: Icons.loop),
          _buildEffect("장애물 제거", "+${effects.obstacleRemove}", icon: Icons.cleaning_services),
          _buildEffect("골드 보너스", "+${effects.goldBonus}%", icon: Icons.attach_money),
        ],
      ),
    );
  }
}