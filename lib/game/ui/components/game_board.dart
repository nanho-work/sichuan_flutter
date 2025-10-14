// lib/game/ui/components/game_board.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/tile_model.dart';
import 'game_tile.dart';

/// 🎮 GameBoard (좌표계 통일 버전)
/// ------------------------------------------------------------
/// - Pathfinder, Engine, StageModel 모두 0기준 좌표 공유.
/// - 셀 여백 없음, 직사각형 유지.
/// - 선택한 셀 노란색 정확 표시.
/// ------------------------------------------------------------
class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state;
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = state.stage.rows;
    final cols = state.stage.cols;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / cols;
        final cellHeight = constraints.maxHeight / rows;

        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                for (int l = 0; l < state.layersByRC.length; l++) 
                  for (int y = 0; y < rows; y++) 
                    for (int x = 0; x < cols; x++) 
                      if (state.layersByRC[l][y][x] != null && !state.layersByRC[l][y][x]!.cleared)
                        Positioned(
                          top: y * cellHeight - (l * 7),
                          left: x * cellWidth - (l * 7),
                          width: cellWidth,
                          height: cellHeight,
                          child: Builder(
                            builder: (context) {
                              final tile = state.layersByRC[l][y][x]!;
                              final selected = state.selectedA?.x == x &&
                                  state.selectedA?.y == y &&
                                  state.selectedA?.cleared == false &&
                                  state.selectedA == tile;
                              return GestureDetector(
                                onTap: () => context.read<GameProvider>().selectTile(tile),
                                child: GameTile(tile: tile, selected: selected),
                              );
                            },
                          ),
                        ),
              ],
            ),
          ),
        );
      },
    );
  }
}