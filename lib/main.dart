import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("🔥 Firebase initialized successfully!");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(
        game: SichuanTestGame(),
      ),
    );
  }
}

class SichuanTestGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  Future<void> onLoad() async {
    debugPrint("✅ Flame 엔진 로드 완료 (Sichuan Test Game)");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 중앙에 초록색 사각형
    final paint = Paint()..color = const Color(0xFF4CAF50);
    const size = 100.0;
    final center = canvasSize / 2;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: size,
        height: size,
      ),
      paint,
    );
  }
}