import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: SichuanTestGame()));
}

class SichuanTestGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  Future<void> onLoad() async {
    // 초기 로드 시 간단한 안내 로그
    debugPrint("✅ Flame 엔진 로드 완료 (Sichuan Test Game)");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 중앙에 초록색 사각형
    final paint = Paint()..color = const Color(0xFF4CAF50);
    final size = 100.0;
    final center = canvasSize / 2;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.x, center.y), width: size, height: size),
      paint,
    );
  }
}