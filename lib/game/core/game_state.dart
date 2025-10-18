import '../models/stage_model.dart';
import '../models/tile_model.dart';

class GameState {
  final StageModel stage;
  final List<List<Tile?>> board; // [row][col] → Tile?
  int timeLeft;  // 초
  bool cleared;
  bool failed;

  Tile? selectedA;
  Tile? selectedB;
  List<(int, int)>? currentPath;

  GameState({
    required this.stage,
    required this.board,
    required this.timeLeft,
    this.cleared = false,
    this.failed = false,
    this.selectedA,
    this.selectedB,
    this.currentPath,
  });
}