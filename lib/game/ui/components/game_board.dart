import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/tile_model.dart';
import '../../../managers/image_manager.dart';
import '../widgets/painters/path_painter.dart'; // ✅ 수정된 경로
import 'game_tile.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state;
    if (state == null) return const Center(child: CircularProgressIndicator());

    final rows = state.stage.rows;
    final cols = state.stage.cols;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / cols;
        final cellHeight = constraints.maxHeight / rows;

        // 🔹 경로가 생기면 애니메이션 재생
        if (state.currentPath != null) {
          _controller.forward(from: 0);
        }

        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                // ✅ 1. 장애물
                for (final obs in state.stage.obstacles)
                  Positioned(
                    top: obs.y * cellHeight,
                    left: obs.x * cellWidth,
                    width: cellWidth,
                    height: cellHeight,
                    child: Image.asset(
                      ImageManager.obstaclePaths[obs.type] ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),

                // ✅ 2. 블럭
                for (int y = 0; y < rows; y++)
                  for (int x = 0; x < cols; x++)
                    if (state.board[y][x] != null &&
                        !state.board[y][x]!.cleared)
                      Positioned(
                        top: y * cellHeight,
                        left: x * cellWidth,
                        width: cellWidth,
                        height: cellHeight,
                        child: Builder(
                          builder: (context) {
                            final tile = state.board[y][x]!;
                            final selected =
                                state.selectedA?.x == x &&
                                    state.selectedA?.y == y &&
                                    state.selectedA == tile;
                            return GestureDetector(
                              onTap: () {
                                final gp = context.read<GameProvider>();
                                if (gp.isLocked) return; // 🔒 잠금 중이면 터치 무시
                                gp.selectTile(tile);
                              },
                              child: GameTile(tile: tile, selected: selected),
                            );
                          },
                        ),
                      ),

                // ✅ 3. 연결선(PathPainter)
                if (state.currentPath != null)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: PathPainter(
                          path: state.currentPath!,
                          progress: _controller.value,
                          cellSize: cellWidth,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}