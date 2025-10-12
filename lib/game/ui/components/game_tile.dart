import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/tile_model.dart';

class GameTile extends StatelessWidget {
  final Tile tile;
  final bool selected;

  const GameTile({super.key, required this.tile, required this.selected});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final engine = gp.engine;
    final isActive = engine.isTopmostTile(tile); // ✅ 클릭 가능 여부 확인

    final color = tile.cleared
        ? Colors.transparent
        : (isActive
            ? Colors.blueGrey.shade700.withOpacity(0.9)
            : Colors.blueGrey.shade900.withOpacity(0.4)); // 어둡게 표시

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected
              ? Colors.amberAccent
              : isActive
                  ? Colors.white24
                  : Colors.white10,
          width: selected ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: tile.cleared
          ? const SizedBox.shrink()
          : Opacity(
              opacity: isActive ? 1.0 : 0.5,
              child: tile.imagePath != null
                  ? Image.asset(
                      tile.imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Text(
                      tile.type,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
    );
  }
}