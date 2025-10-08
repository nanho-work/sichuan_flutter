import 'package:flutter/material.dart';

/// ✅ AppHeader (게임 상단 바)
/// 프로필, 에너지, 젬, 골드 정보를 표시
class AppHeader extends StatelessWidget {
  final String profileImage;
  final int energy;
  final int maxEnergy;
  final int gems;
  final int gold;

  const AppHeader({
    super.key,
    required this.profileImage,
    required this.energy,
    required this.maxEnergy,
    required this.gems,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 첫 번째 줄 : 프로필 + 에너지 바
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(profileImage),
              ),
              const SizedBox(width: 10),
              // 에너지 표시
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Energy",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor:
                              energy / maxEnergy.clamp(1, maxEnergy).toDouble(),
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "$energy / $maxEnergy",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 두 번째 줄 : 젬 / 골드
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _currencyIconText("💎", gems.toString(), Colors.cyanAccent),
              const SizedBox(width: 12),
              _currencyIconText("🪙", gold.toString(), Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }

  /// 아이콘 + 텍스트 구성
  Widget _currencyIconText(String emoji, String value, Color color) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 20, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}