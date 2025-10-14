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

    final baseColor = tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade700.withOpacity(0.9);
    final activeColor = tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade700.withOpacity(0.9);
    final inactiveColor = tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade900.withOpacity(0.4);

    final color = selected
        ? Colors.blueGrey.shade700.withOpacity(1.0)
        : (isActive ? activeColor : inactiveColor);

    final border = selected
        ? Border.all(color: Colors.amberAccent, width: 2)
        : (isActive
            ? Border.all(color: Colors.white24, width: 1)
            : Border.all(color: Colors.transparent, width: 0));

    final scale = selected ? 1.08 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: border,
        ),
        alignment: Alignment.center,
        child: tile.cleared
            ? const SizedBox.shrink()
            : Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: tile.imagePath != null
                    ? Image.asset(
                        tile.imagePath!,
                        fit: BoxFit.fill,
                      )
                    : Text(
                        tile.type,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ),
    );
  }
}