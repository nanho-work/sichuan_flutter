import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../../managers/ad_manager.dart';

class GameBar extends StatelessWidget {
  const GameBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().state;
    final time = state?.timeLeft ?? 0;

    return Column(
      children: [
        AdManager().gameBannerWidget(),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(
              begin: 1.0,
              end: (state?.timeLeft ?? 0) / (state?.stage.timeLimit ?? 1),
            ),
            builder: (context, value, _) {
              return Stack(
                children: [
                  // Background
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  // Progress bar
                  FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: value,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Color(0xFF80DEEA), Color(0xFFFFF59D), Color(0xFFFF8A80)],
                        ),
                      ),
                    ),
                  ),
                  // Text always visible
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          '${state?.timeLeft ?? 0}s',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Spacer(),
              if (state?.cleared == true)
                const Text('CLEAR!',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              if (state?.failed == true)
                const Text('TIME OVER',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}