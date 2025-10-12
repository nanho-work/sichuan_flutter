import 'dart:math';
import '../models/stage_model.dart';
import '../models/tile_model.dart';
import 'game_state.dart';
import 'pathfinder.dart';

class GameEngine {
  late GameState state;
  late Pathfinder _finder;

  // ✅ 블럭 이미지 목록도 함께 받도록 수정
  Future<void> init(StageModel stage, List<String> equippedBlockImages) async {
    final maxLayer = stage.tiles.fold<int>(1, (m, t) => max(m, t.layer));

    // [layer][row][col]
    final layers = List.generate(
      maxLayer,
      (_) => List.generate(
        stage.rows,
        (_) => List<Tile?>.filled(stage.cols, null, growable: false),
        growable: false,
      ),
      growable: false,
    );

    // 타일 배치
    for (final t in stage.tiles) {
      layers[t.layer - 1][t.y][t.x] = t;
    }

    state = GameState(
      stage: stage,
      layersByRC: layers,
      timeLeft: stage.timeLimit,
    );

    // 착용 블럭 기반 페어링은 UI/Provider에서 처리. 엔진은 이미지에 관여하지 않음.
    _assignPairs(equippedBlockImages);

    // Pathfinder 초기화
    _finder = Pathfinder(
      rows: stage.rows,
      cols: stage.cols,
      isBlocked: (x, y) {
        final a = state.selectedA;
        final b = state.selectedB;

        // 선택된 타일은 통로로 허용
        if ((a?.x == x && a?.y == y) || (b?.x == x && b?.y == y)) return false;

        // 최상단 타일이 남아있으면 막힘
        for (int l = state.layersByRC.length - 1; l >= 0; l--) {
          final t = state.layersByRC[l][y][x];
          if (t != null && !t.cleared) return true;
        }

        // 장애물 검사
        final hasObs = stage.obstacles.any(
          (o) => o.x == x && o.y == y && o.durability > 0,
        );
        return hasObs;
      },
      layerGetter: (x, y) {
        // 가장 위에 남아 있는 타일의 레이어를 반환 (없으면 0)
        for (int l = state.layersByRC.length - 1; l >= 0; l--) {
          final t = state.layersByRC[l][y][x];
          if (t != null && !t.cleared) return l + 1;
        }
        return 0;
      },
    );
  }

  // ✅ 해당 타일이 최상단(위에 다른 블록이 없음)인지 판정
  bool isTopmostTile(Tile t) {
    for (int l = t.layer; l < state.layersByRC.length; l++) {
      final above = state.layersByRC[l][t.y][t.x];
      if (above != null && !above.cleared && !identical(above, t)) {
        return false;
      }
    }
    return true;
  }

  // ✅ 착용 블럭 기반 짝 랜덤 지정 (blockItemId 추가 반영)
  void _assignPairs(List<String> equippedBlockImages) {
    // collect all existing, not-cleared tiles
    final tiles = <Tile>[];
    for (final layer in state.layersByRC) {
      for (final row in layer) {
        for (final t in row) {
          if (t != null && !t.cleared) tiles.add(t);
        }
      }
    }
    if (tiles.length.isOdd) tiles.removeLast();

    // shuffle and assign logical pair ids ONLY
    final rng = Random();
    tiles.shuffle(rng);

    for (int i = 0; i < tiles.length; i += 2) {
      // Stable logical id (engine-only). UI decides what image to show.
      final pairId = 'pair_${i ~/ 2}';
      tiles[i].type = pairId;
      tiles[i + 1].type = pairId;

      // ✅ DO NOT touch tiles[i].imagePath / blockItemId here.
      // Those are owned by the GameProvider/InventoryProvider layer.
    }
  }

  // ✅ 선택 로직
  bool select(Tile t) {
    if (t.cleared || !isTopmostTile(t)) return false;

    if (state.selectedA == null) {
      state.selectedA = t;
      return true;
    } else if (state.selectedB == null) {
      state.selectedB = t;
      return tryClearSelected();
    } else {
      state.selectedA = t;
      state.selectedB = null;
      return true;
    }
  }

  bool tryClearSelected() {
    final a = state.selectedA, b = state.selectedB;
    if (a == null || b == null) return false;
    if (a.type.isEmpty || b.type.isEmpty || a.type != b.type) {
      state.selectedA = b;
      state.selectedB = null;
      return false;
    }

    final ok = _finder.canConnect(a, b);
    if (ok) {
      a.cleared = true;
      b.cleared = true;
      state.selectedA = null;
      state.selectedB = null;
      if (_isAllCleared()) state.cleared = true;
      return true;
    } else {
      state.selectedA = b;
      state.selectedB = null;
      return false;
    }
  }

  bool _isAllCleared() {
    for (final layer in state.layersByRC) {
      for (final row in layer) {
        for (final t in row) {
          if (t != null && !t.cleared) return false;
        }
      }
    }
    return true;
  }

  void tick() {
    if (state.cleared || state.failed) return;
    state.timeLeft = (state.timeLeft - 1).clamp(0, 99999);
    if (state.timeLeft == 0) state.failed = true;
  }
}