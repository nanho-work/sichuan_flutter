import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../models/tile_model.dart';
import 'game_state.dart';
import 'pathfinder.dart';

enum MatchResultType { none, selected, deselected, wrong, matched, cleared, failed }

class MatchResult {
  final MatchResultType type;
  final Tile? a;
  final Tile? b;
  const MatchResult(this.type, {this.a, this.b});
}

class GameEngine {
  late GameState state;
  late Pathfinder _finder;

  // Cache for topmost tiles
  final Set<Tile> _topmostCache = {};

  // ✅ 블럭 이미지 목록도 함께 받도록 수정
  Future<void> init(
    StageModel stage,
    List<String> equippedBlockImages, {
    String? backgroundImage,
  }) async {
    debugPrint("🧩 Initializing GameEngine for stage: id=${stage.id}, name=${stage.name}");
    debugPrint("🧩 Stage dimensions: rows=${stage.rows}, cols=${stage.cols}");

    // [row][col]
    final grid = List.generate(
      stage.rows,
      (_) => List<Tile?>.filled(stage.cols, null, growable: false),
      growable: false,
    );

    // 타일 배치
    for (final t in stage.tiles) {
      grid[t.y][t.x] = t;
    }

    state = GameState(
      stage: stage,
      board: grid,
      timeLeft: stage.timeLimit,
    );

    // ✅ 착용 블럭 기반 짝 및 이미지 경로 지정
    _assignPairs(equippedBlockImages);

    // ✅ 가시 레이어(시각적으로 보이는 블럭만) 기준 projectedLayer 생성
    final _projectedLayer = List.generate(
      stage.rows,
      (y) => List.generate(stage.cols, (x) {
        // 장애물 우선
        final hasObstacle = stage.obstacles.any(
          (o) => o.x == x && o.y == y && o.durability > 0,
        );
        if (hasObstacle) return 'obstacle';

        final t = state.board[y][x];
        if (t != null && !t.cleared) return t;
        return null;
      }),
    );

    // Pathfinder 초기화
    _finder = Pathfinder(
      rows: stage.rows,
      cols: stage.cols,
      isBlocked: (x, y) {
        // 보드 경계 밖은 차단 아님
        if (x < 0 || x >= stage.cols || y < 0 || y >= stage.rows) return false;

        // 선택된 타일은 경로로 허용
        final a = state.selectedA;
        final b = state.selectedB;
        if ((a?.x == x && a?.y == y) || (b?.x == x && b?.y == y)) {
          return false;
        }

        // 장애물 존재 여부
        final hasObstacle = stage.obstacles.any(
          (o) => o.x == x && o.y == y && o.durability > 0,
        );
        if (hasObstacle) return true;

        final t = state.board[y][x];
        if (t != null && !t.cleared) {
          return true;
        }
        return false; // 비어있으면 통로
      },
    );

    refreshTopmostTiles();

    debugPrint("✅ GameEngine initialized with ${equippedBlockImages.length} equipped block images");
  }

  // Refresh the cache of topmost tiles
  void refreshTopmostTiles() {
    _topmostCache.clear();
    for (final row in state.board) {
      for (final t in row) {
        if (t != null && !t.cleared) {
          _topmostCache.add(t);
        }
      }
    }
  }

  // Public helper for external controllers (e.g., Provider) to clear current selections
  void clearSelections() {
    state.selectedA = null;
    state.selectedB = null;
  }

  // Wrapper to check if tile is topmost using cache
  bool isTopmost(Tile t) {
    return _topmostCache.contains(t);
  }

  // ✅ 해당 타일이 최상단(위에 다른 블록이 없음)인지 판정
  bool isTopmostTile(Tile t) {
    return true;
  }

  // ✅ 착용 블럭 기반 짝 랜덤 지정 + 절대경로 이미지 적용
  void _assignPairs(List<String> equippedBlockImages) {
    final tiles = <Tile>[];
    for (final row in state.board) {
      for (final t in row) {
        if (t != null && !t.cleared) tiles.add(t);
      }
    }

    debugPrint("🎯 _assignPairs: total tiles before pairing = ${tiles.length}");

    if (tiles.length.isOdd) {
      debugPrint("⚠️ _assignPairs: odd number of tiles (${tiles.length}), removing last tile");
      tiles.removeLast();
    }
    tiles.shuffle(Random());

    // 이미지를 기준으로 같은 이미지 = 같은 type
    for (int i = 0; i < tiles.length; i += 2) {
      final imgIndex = ((i ~/ 2) % (equippedBlockImages.isEmpty ? 1 : equippedBlockImages.length));
      final imgPath = (equippedBlockImages.isEmpty)
          ? 'default_image'
          : equippedBlockImages[imgIndex];
      final typeKey = imgPath; // 이미지 경로를 type으로 사용

      tiles[i].imagePath = imgPath;
      tiles[i].type = typeKey;

      tiles[i + 1].imagePath = imgPath;
      tiles[i + 1].type = typeKey;

      debugPrint("🧱 _assignPairs: Pair image '$imgPath' "
          "→ A(${tiles[i].x},${tiles[i].y}) type='$typeKey', "
          "B(${tiles[i+1].x},${tiles[i+1].y}) type='$typeKey'");
    }

    // 🔍 디버그 로그 (상위 5쌍만 출력)
    for (int i = 0; i < min(10, tiles.length); i += 2) {
      if (tiles[i].type != tiles[i + 1].type) {
        debugPrint("⚠️ _assignPairs: Mismatch in pair types at index $i: ${tiles[i].type} vs ${tiles[i+1].type}");
      }
      debugPrint("🧱 Pair ${tiles[i].type} → image: ${tiles[i].imagePath}");
    }
  }

  // ✅ 선택 로직
  MatchResult select(Tile t) {
    // 🚫 이미 cleared 되었거나 위에 블럭/장애물 있으면 무시
    if (t.cleared || !isTopmost(t)) return const MatchResult(MatchResultType.none);

    // 🚫 장애물 위의 타일은 선택 불가
    final hasObs = state.stage.obstacles.any(
      (o) => o.x == t.x && o.y == t.y && o.durability > 0,
    );
    if (hasObs) return const MatchResult(MatchResultType.none);

    debugPrint("🎯 select: Tile selected at (${t.x},${t.y}), type '${t.type}'");
    
    // 🚫 Same-tile double tap → toggle/deselect
    if (state.selectedA != null && identical(state.selectedA, t)) {
      debugPrint("⚠️ select: Same tile tapped twice; deselecting A at (${t.x},${t.y})");
      state.selectedA = null;
      state.selectedB = null;
      return MatchResult(MatchResultType.deselected, a: t);
    }
    if (t.cleared || !isTopmost(t)) {
      debugPrint("⚠️ select: Tile at (${t.x},${t.y}) cannot be selected (cleared: ${t.cleared}, topmost: ${isTopmost(t)})");
      return const MatchResult(MatchResultType.none);
    }

    if (state.selectedA == null) {
      state.selectedA = t;
      debugPrint("🎯 select: selectedA set to tile at (${t.x},${t.y})");
      return MatchResult(MatchResultType.selected, a: t);
    } else if (state.selectedB == null) {
      // 🚫 Prevent selecting the exact same tile as B
      if (identical(state.selectedA, t)) {
        debugPrint("⚠️ select: Attempted to set selectedB to the same tile as selectedA; ignoring");
        return const MatchResult(MatchResultType.none);
      }
      state.selectedB = t;
      debugPrint("🎯 select: selectedB set to tile at (${t.x},${t.y}), attempting to clear");
      return tryClearSelected();
    } else {
      state.selectedA = t;
      state.selectedB = null;
      debugPrint("🎯 select: Reset selections, selectedA set to tile at (${t.x},${t.y}), selectedB cleared");
      return MatchResult(MatchResultType.selected, a: t);
    }
  }

  MatchResult tryClearSelected() {
    final a = state.selectedA, b = state.selectedB;
    if (a == null || b == null) {
      debugPrint("❌ tryClearSelected: One or both selected tiles are null");
      return const MatchResult(MatchResultType.none);
    }
    // 🚫 Same tile selected for A and B
    if (identical(a, b)) {
      debugPrint("❌ tryClearSelected: A and B are the same tile (${a.x},${a.y}); cannot clear");
      // Reset to allow choosing a proper second tile
      state.selectedB = null;
      return MatchResult(MatchResultType.wrong, a: a, b: b);
    }
    debugPrint("🎯 tryClearSelected: Attempting to clear selected tiles:");
    debugPrint(
        "  🅰️ Tile A → (x:${a.x}, y:${a.y}, type:'${a.type}', cleared:${a.cleared}, imagePath:'${a.imagePath}')");
    debugPrint(
        "  🅱️ Tile B → (x:${b.x}, y:${b.y}, type:'${b.type}', cleared:${b.cleared}, imagePath:'${b.imagePath}')");

    final typeMatch = (a.type.isNotEmpty && a.type == b.type);
    final imageMatch = (a.imagePath != null && a.imagePath == b.imagePath);

    if (!(typeMatch || imageMatch)) {
      debugPrint("❌ tryClearSelected: Not matched. "
          "typeMatch=$typeMatch (A:'${a.type}', B:'${b.type}'), "
          "imageMatch=$imageMatch (A:'${a.imagePath}', B:'${b.imagePath}')");
      // Keep A/B selection so UI can show wrong feedback; Provider will clear after delay
      return MatchResult(MatchResultType.wrong, a: a, b: b);
    } else {
      debugPrint("✅ tryClearSelected: Match OK. "
          "typeMatch=$typeMatch, imageMatch=$imageMatch, "
          "using '${typeMatch ? a.type : a.imagePath}' as key");
    }

    final result = _finder.canConnectAndPath(a, b);
    debugPrint("🧭 Pathfinder.canConnectAndPath: ${result.canConnect}");
    if (result.canConnect) {
      debugPrint("🗺 Path: ${result.path}");
      a.cleared = true;
      b.cleared = true;
      state.selectedA = null;
      state.selectedB = null;
      refreshTopmostTiles();
      debugPrint("🔄 refreshTopmostTiles: cache size = ${_topmostCache.length}");
      debugPrint(
          "✅ tryClearSelected: Cleared tiles at (A: ${a.x},${a.y}) and (B: ${b.x},${b.y}) 🧩🧩");
      // Count remaining tiles
      int remaining = 0;
      for (final row in state.board) {
        for (final t in row) {
          if (t != null && !t.cleared) remaining++;
        }
      }
      debugPrint("🎯 Tiles remaining: $remaining");
      if (_isAllCleared()) {
        state.cleared = true;
        debugPrint("🎉 tryClearSelected: All tiles cleared, game cleared! 🎉");
        return MatchResult(MatchResultType.cleared, a: a, b: b);
      }
      return MatchResult(MatchResultType.matched, a: a, b: b);
    } else {
      debugPrint("❌ tryClearSelected: Pathfinder cannot connect these tiles. Clear failed.");
      // Keep A/B selection so UI can show wrong feedback; Provider will clear after delay
      return MatchResult(MatchResultType.wrong, a: a, b: b);
    }
  }

  bool _isAllCleared() {
    for (final row in state.board) {
      for (final t in row) {
        if (t != null && !t.cleared) return false;
      }
    }
    debugPrint("✅ _isAllCleared: Board fully cleared!");
    return true;
  }

  void tick() {
    if (state.cleared || state.failed) {
      debugPrint("🎯 tick: Game ended (cleared: ${state.cleared}, failed: ${state.failed}), skipping tick");
      return;
    }
    int oldTime = state.timeLeft;
    state.timeLeft = (state.timeLeft - 1).clamp(0, 99999);
    if (state.timeLeft == 0) {
      state.failed = true;
      debugPrint("⚠️ tick: Time's up! Game failed.");
    }
    if (oldTime % 10 == 0 || state.cleared || state.failed) {
      debugPrint("🎯 tick: Time left updated: ${state.timeLeft}");
    }
  }
}