import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/tile_model.dart';

/// ✅ Pathfinder (개선/안정화 버전)
/// - 같은 타입만 연결 가능
/// - 최대 2회까지 꺾임 허용
/// - 상위(=같거나 높은) 레이어의 타일은 벽으로 간주
/// - 보드 경계 밖(-1..cols/rows+1)으로도 경로가 나갈 수 있음
class Pathfinder {
  final int rows;
  final int cols;
  final bool Function(int x, int y) isBlocked;
  final int Function(int x, int y) layerGetter;

  Pathfinder({
    required this.rows,
    required this.cols,
    required this.isBlocked,
    required this.layerGetter,
  });

  // 버텍스 유효 범위: -1 .. cols/rows + 1
  bool _vValid(int vx, int vy) => vx >= -1 && vy >= -1 && vx <= cols + 1 && vy <= rows + 1;

  static const _DX = [0, 1, 0, -1];
  static const _DY = [-1, 0, 1, 0];
  static const _MAX_TURNS = 2;

  // visited 인덱스 변환(helper): -1..N+1  →  0..N+2
  int _idx(int v) => v + 1;

  // (x, y) 타일이 시작 Z층(currentZ)에 대해 경로를 막는지
  bool _isTileBlocking(int x, int y, int currentZ) {
    if (x < 0 || y < 0 || x >= cols || y >= rows) return false;
    if (!isBlocked(x, y)) return false;
    final z = layerGetter(x, y);
    return z >= currentZ; // 같은 층 또는 상위층이면 막음
  }

  // 타일의 개방면 계산
  (bool right, bool left, bool down, bool up) _getOpenSides(int x, int y, int z) {
    bool rightOpen = !_isTileBlocking(x + 1, y, z);
    bool leftOpen  = !_isTileBlocking(x - 1, y, z);
    bool downOpen  = !_isTileBlocking(x, y + 1, z);
    bool upOpen    = !_isTileBlocking(x, y - 1, z);

    // 경계 밖은 항상 개방
    if (x == cols - 1) rightOpen = true;
    if (x == 0)        leftOpen  = true;
    if (y == rows - 1) downOpen  = true;
    if (y == 0)        upOpen    = true;

    return (rightOpen, leftOpen, downOpen, upOpen);
  }

  // 타일 주변, 개방면에 인접한 버텍스(-1..N+1) 수집
  List<(int vx, int vy)> _getBoundaryVertices(Tile t) {
    final x = t.x, y = t.y;
    final z = layerGetter(x, y);
    final (rightOpen, leftOpen, downOpen, upOpen) = _getOpenSides(x, y, z);
    final out = <(int, int)>[];

    if (leftOpen)  { out.add((x,   y));   out.add((x,   y+1)); }
    if (rightOpen) { out.add((x+1, y));   out.add((x+1, y+1)); }
    if (upOpen)    { out.add((x,   y));   out.add((x+1, y));   }
    if (downOpen)  { out.add((x,   y+1)); out.add((x+1, y+1)); }

    final seen = <String>{};
    final uniq = <(int, int)>[];
    for (final p in out) {
      final k = '${p.$1},${p.$2}';
      if (seen.add(k) && _vValid(p.$1, p.$2)) uniq.add(p);
    }
    return uniq;
  }

  // 연결 가능 여부
  bool canConnect(Tile a, Tile b) {
    if (identical(a, b) || a.type.isEmpty || a.type != b.type) return false;

    final ax = a.x, ay = a.y, bx = b.x, by = b.y;
    final aZ = layerGetter(ax, ay);
    final bZ = layerGetter(bx, by);

    // 같은 레이어에서 인접(상하좌우 1칸)하면 즉시 통과
    final dx = (ax - bx).abs();
    final dy = (ay - by).abs();
    if (aZ == bZ && ((dx == 1 && dy == 0) || (dx == 0 && dy == 1))) {
      return true;
    }

    final starts = _getBoundaryVertices(a);
    final goals  = _getBoundaryVertices(b);
    if (starts.isEmpty || goals.isEmpty) return false;
    final goalSet = <String>{ for (final g in goals) '${g.$1},${g.$2}' };

    // visited: (cols+3) x (rows+3) x 4방향  —  인덱싱 시 반드시 _idx() 사용!
    final visited = List.generate(
      cols + 3,
      (_) => List.generate(rows + 3, (_) => List<bool>.filled(4, false)),
    );

    // BFS: 버텍스 좌표는 항상 "원시 좌표계"(-1..N+1)를 사용
    final queue = Queue<(int vx, int vy, int dir, int turns)>();

    for (final s in starts) {
      queue.addLast((s.$1, s.$2, -1, 0));
      // 시작점은 방향(-1) 상태이므로 visited는 아직 찍지 않음
    }

    while (queue.isNotEmpty) {
      final (vx, vy, dir, turns) = queue.removeFirst();

      // 목표 버텍스 도달 확인 (원시 좌표계 그대로 비교)
      if (goalSet.contains('$vx,$vy')) {
        debugPrint("✅ Path found between (${a.x},${a.y}) ↔ (${b.x},${b.y}) after $turns turns");
        return true;
      }

      for (int nd = 0; nd < 4; nd++) {
        final nx = vx + _DX[nd];
        final ny = vy + _DY[nd];
        if (!_vValid(nx, ny)) continue;

        final nTurns = (dir == -1 || dir == nd) ? turns : turns + 1;
        if (nTurns > _MAX_TURNS) continue;

        // 방문 체크 — 배열 인덱스 변환 후 접근
        final ix = _idx(nx);
        final iy = _idx(ny);
        if (visited[ix][iy][nd]) continue;

        // 경로 차단 검사:
        // (vx,vy) -> (nx,ny) 사이에 있는 셀 좌표는 min(vx,nx), min(vy,ny).
        // 이 값이 보드 밖이면 그 간선은 항상 개방으로 간주.
        final cellX = (vx < nx ? vx : nx);
        final cellY = (vy < ny ? vy : ny);
        bool blocked = false;
        if (cellX >= 0 && cellX < cols && cellY >= 0 && cellY < rows) {
          blocked = _isTileBlocking(cellX, cellY, aZ);
        }
        if (blocked) continue;

        visited[ix][iy][nd] = true;
        queue.addLast((nx, ny, nd, nTurns));
      }
    }

    debugPrint("❌ No valid path between (${a.x},${a.y}) and (${b.x},${b.y})");
    return false;
  }
}