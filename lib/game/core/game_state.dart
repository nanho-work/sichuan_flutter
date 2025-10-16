import '../models/stage_model.dart';
import '../models/tile_model.dart';

class GameState {
  final StageModel stage;
  final List<List<List<Tile?>>> layersByRC; // [layer][row][col] → Tile?
  int timeLeft;  // 초
  bool cleared;
  bool failed;

  Tile? selectedA;
  Tile? selectedB;
  List<(int, int)>? currentPath;

  GameState({
    required this.stage,
    required this.layersByRC,
    required this.timeLeft,
    this.cleared = false,
    this.failed = false,
    this.selectedA,
    this.selectedB,
    this.currentPath,
  });

  int get layerCount {
    // 최대 레이어 계산
    int maxL = 1;
    for (final t in stage.tiles) {
      if (t.layer > maxL) maxL = t.layer;
    }
    return maxL;
  }
}