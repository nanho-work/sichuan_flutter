import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/tile_model.dart';

class PathfinderResult {
  final bool canConnect;
  final List<(int, int)>? path;
  PathfinderResult(this.canConnect, [this.path]);
}

/// ✅ Pathfinder (개선/안정화 버전)
/// - 같은 타입만 연결 가능
/// - 최대 2회까지 꺾임 허용
/// - 상위(=같거나 높은) 레이어의 타일은 벽으로 간주
/// - 보드 경계 밖(-1..cols/rows+1)으로도 경로가 나갈 수 있음
class Pathfinder {
  final int rows; // 보드의 행 개수
  final int cols; // 보드의 열 개수
  final bool Function(int x, int y) isBlocked; // 특정 좌표가 막혀있는지 여부를 판단하는 함수
  final int Function(int x, int y) layerGetter; // 특정 좌표의 타일 레이어(층)를 반환하는 함수

  Pathfinder({
    required this.rows,
    required this.cols,
    required this.isBlocked,
    required this.layerGetter,
  });

  // 버텍스 유효 범위: -1 .. cols/rows + 1
  // 버텍스 좌표가 보드 경계 범위(-1부터 cols+1까지) 내에 있는지 검사
  bool _vValid(int vx, int vy) => vx >= -1 && vy >= -1 && vx <= cols + 1 && vy <= rows + 1;

  // 상하좌우 이동 방향 벡터 배열 (상, 우, 하, 좌)
  static const _DX = [0, 1, 0, -1];
  static const _DY = [-1, 0, 1, 0];
  static const _MAX_TURNS = 2; // 최대 꺾임 횟수 제한

  // visited 배열 인덱스 변환(helper): 원래 좌표 -1..N+1 → 배열 인덱스 0..N+2로 변환
  int _idx(int v) => v + 1;

  // (x, y) 위치의 타일이 현재 탐색 중인 Z층(currentZ)에 대해 경로를 막는지 여부 판단
  // - 경계 밖 좌표는 막지 않음
  // - isBlocked가 false면 막지 않음
  // - 타일 레이어 z가 currentZ 이상이면 막음 (같거나 높은 레이어는 벽으로 간주)
  bool _isTileBlocking(int x, int y) {
    // 단일 2D 가시 레이어로 판단: 보드 밖은 차단 아님, 그 외는 isBlocked()만 사용
    if (x < 0 || y < 0 || x >= cols || y >= rows) return false;
    return isBlocked(x, y);
  }

  // 현재 버텍스(vx, vy)와 다음 버텍스(nx, ny) 사이의 간선이 통과 가능한지 판단
  // 간선이 가로/세로일 때, 그 사이에 있는 셀 하나만 검사하면 됨 (BFS가 한 칸씩 전진하므로)
  bool _isPathBlockedBetween(int vx, int vy, int nx, int ny) {
    // 대각선 이동은 허용되지 않음
    if (!(vx == nx || vy == ny)) return true;

    // 경계 밖 간선은 항상 개방 (보드 바깥은 빈 공간)
    if (!_vValid(vx, vy) || !_vValid(nx, ny)) return false;

    // ✅ 수정: 간선이 지나가는 셀 좌표를 보드 경계 기준으로 정확히 계산
    final cellX = (vx + nx) ~/ 2;
    final cellY = (vy + ny) ~/ 2;

    // ✅ 셀이 보드 내부에 있을 때만 차단 검사
    if (cellX >= 0 && cellX < cols && cellY >= 0 && cellY < rows) {
      return _isTileBlocking(cellX, cellY);
    }
    return false;
  }

  // 타일의 개방면 계산
  // 타일 주변 4방향에 대해 경로가 통과 가능한지 판단하여 각 방향별 개방 여부 반환
  // 개방면: 오른쪽, 왼쪽, 아래, 위 순서로 bool 반환
  (bool right, bool left, bool down, bool up) _getOpenSides(int x, int y) {
    bool rightOpen = !_isTileBlocking(x + 1, y);
    bool leftOpen  = !_isTileBlocking(x - 1, y);
    bool downOpen  = !_isTileBlocking(x, y + 1);
    bool upOpen    = !_isTileBlocking(x, y - 1);

    // 경계 밖은 항상 개방
    if (x == cols - 1) rightOpen = true;
    if (x == 0)        leftOpen  = true;
    if (y == rows - 1) downOpen  = true;
    if (y == 0)        upOpen    = true;

    return (rightOpen, leftOpen, downOpen, upOpen);
  }

  // 타일 주변, 개방면에 인접한 버텍스(-1..N+1 범위) 수집
  // 버텍스는 타일의 모서리 좌표로 생각할 수 있음
  List<(int vx, int vy)> _getBoundaryVertices(Tile t) {
    final x = t.x, y = t.y;
    final (rightOpen, leftOpen, downOpen, upOpen) = _getOpenSides(x, y); // 개방면 확인
    final out = <(int, int)>[];

    // 각 개방면에 대해 해당 면과 인접한 버텍스 2개를 추가
    if (leftOpen)  { out.add((x,   y));   out.add((x,   y+1)); }
    if (rightOpen) { out.add((x+1, y));   out.add((x+1, y+1)); }
    if (upOpen)    { out.add((x,   y));   out.add((x+1, y));   }
    if (downOpen)  { out.add((x,   y+1)); out.add((x+1, y+1)); }

    // 중복 제거 및 유효 범위 내 버텍스만 필터링
    final seen = <String>{};
    final uniq = <(int, int)>[];
    for (final p in out) {
      final k = '${p.$1},${p.$2}';
      if (seen.add(k) && _vValid(p.$1, p.$2)) uniq.add(p);
    }
    return uniq;
  }

  // 두 타일 a, b가 연결 가능한지 여부 판단
  // - 같은 타입이어야 함
  // - 최대 2회까지 꺾임 허용
  // - 상위 레이어 타일은 벽으로 간주
  // - 보드 경계 밖으로도 경로가 나갈 수 있음
  bool canConnect(Tile a, Tile b) {
    // 같은 객체이거나 타입이 다르거나 빈 타입이면 연결 불가
    if (identical(a, b) || a.type.isEmpty || a.type != b.type) return false;

    final ax = a.x, ay = a.y, bx = b.x, by = b.y;
    // 단일 2D 가시 레이어 기준으로 탐색
    const int currentZ = 1;

    // 같은 레이어에서 인접(상하좌우 1칸)하면 즉시 연결 가능
    final dx = (ax - bx).abs();
    final dy = (ay - by).abs();
    if (currentZ == currentZ && ((dx == 1 && dy == 0) || (dx == 0 && dy == 1))) {
      if (_isPathBlockedBetween(ax, ay, bx, by)) {
        return false;
      }
      return true;
    }

    // 시작 타일과 목표 타일의 개방된 버텍스들을 수집
    final starts = _getBoundaryVertices(a);
    final goals  = _getBoundaryVertices(b);
    if (starts.isEmpty || goals.isEmpty) return false; // 개방 버텍스 없으면 연결 불가
    final goalSet = <String>{ for (final g in goals) '${g.$1},${g.$2}' }; // 목표 버텍스 집합

    // 방문 배열 생성: (cols+3) x (rows+3) x 4방향 x (MAX_TURNS+1)
    // 배열 인덱스는 _idx()로 변환하여 사용
    final visited = List.generate(
      cols + 3,
      (_) => List.generate(
        rows + 3,
        (_) => List.generate(
          4,
          (_) => List<bool>.filled(_MAX_TURNS + 1, false),
        ),
      ),
    );

    // BFS 탐색용 큐: (버텍스 x, y 좌표, 방향, 꺾임 횟수)
    final queue = Queue<(int vx, int vy, int dir, int turns)>();

    // 시작 버텍스들을 큐에 추가, 방향은 -1로 초기화(아직 방향 없음), 꺾임 횟수 0
    for (final s in starts) {
      queue.addLast((s.$1, s.$2, -1, 0));
      // 시작점은 방향(-1) 상태이므로 visited는 아직 찍지 않음
    }

    // BFS 탐색 시작
    while (queue.isNotEmpty) {
      final (vx, vy, dir, turns) = queue.removeFirst();

      // 현재 버텍스가 목표 버텍스 중 하나인지 확인
      if (goalSet.contains('$vx,$vy')) {
        debugPrint("✅ Path found between (${a.x},${a.y}) ↔ (${b.x},${b.y}) after $turns turns");
        return true; // 경로 발견
      }

      // 4방향으로 이동 시도
      for (int nd = 0; nd < 4; nd++) {
        final nx = vx + _DX[nd]; // 다음 버텍스 x 좌표
        final ny = vy + _DY[nd]; // 다음 버텍스 y 좌표
        if (!_vValid(nx, ny)) continue; // 유효 범위 밖이면 무시

        // 꺾임 횟수 계산: 방향이 바뀌면 +1, 아니면 그대로
        final nTurns = (dir == -1 || dir == nd) ? turns : turns + 1;
        if (nTurns > _MAX_TURNS) continue; // 꺾임 횟수 초과 시 무시

        // 방문 여부 검사 (배열 인덱스 변환 후)
        final ix = _idx(nx);
        final iy = _idx(ny);
        if (visited[ix][iy][nd][nTurns]) continue; // 이미 방문한 경로면 무시

        // 경로 차단 검사: 현재 버텍스와 다음 버텍스 사이 전체 경로 구간 검사
        if (_isPathBlockedBetween(vx, vy, nx, ny)) continue; // 막혀있으면 무시

        // 방문 처리 후 큐에 추가
        visited[ix][iy][nd][nTurns] = true;
        queue.addLast((nx, ny, nd, nTurns));
      }
    }

    // 모든 경로 탐색 실패 시
    debugPrint("❌ No valid path between (${a.x},${a.y}) and (${b.x},${b.y})");
    return false;
  }

  PathfinderResult canConnectAndPath(Tile a, Tile b) {
    if (identical(a, b) || a.type.isEmpty || a.type != b.type) {
      return PathfinderResult(false);
    }

    final ax = a.x, ay = a.y, bx = b.x, by = b.y;
    // 단일 2D 가시 레이어 기준으로 탐색
    const int currentZ = 1;

    final dx = (ax - bx).abs();
    final dy = (ay - by).abs();
    // ✅ 인접한 블럭은 장애물 검사 포함하여 처리
    if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1)) {
      if (_isPathBlockedBetween(ax, ay, bx, by)) {
        return PathfinderResult(false);
      }
      return PathfinderResult(true, [(ax, ay), (bx, by)]);
    }
    // ✅ 대각선 인접(1,1)인 경우: L자 경로가 비어있으면 연결 허용
    if (dx == 1 && dy == 1) {
      final mid1Blocked = _isTileBlocking(ax, by);
      final mid2Blocked = _isTileBlocking(bx, ay);
      if (!mid1Blocked || !mid2Blocked) {
        debugPrint("✅ Diagonal connection allowed between ($ax,$ay) ↔ ($bx,$by)");
        return PathfinderResult(true, [(ax, ay), (bx, by)]);
      }
    }

    final starts = _getBoundaryVertices(a);
    final goals  = _getBoundaryVertices(b);
    if (starts.isEmpty || goals.isEmpty) return PathfinderResult(false);
    final goalSet = <String>{ for (final g in goals) '${g.$1},${g.$2}' };

    // visited 배열 생성: (cols+3) x (rows+3) x 4방향 x (MAX_TURNS+1)
    final visited = List.generate(
      cols + 3,
      (_) => List.generate(
        rows + 3,
        (_) => List.generate(
          4,
          (_) => List<bool>.filled(_MAX_TURNS + 1, false),
        ),
      ),
    );

    // BFS 탐색용 큐: (vx, vy, dir, turns)
    final queue = Queue<(int vx, int vy, int dir, int turns)>();

    // 부모 추적용 map: key = 'x,y,dir,turns' -> value = (px, py, pdir, pturns)
    final parent = <String, String>{};

    String _key(int x, int y, int dir, int turns) => '$x,$y,$dir,$turns';

    // 시작 버텍스들을 큐에 추가, 방향은 -1로 초기화, 꺾임 횟수 0
    for (final s in starts) {
      queue.addLast((s.$1, s.$2, -1, 0));
      // 시작점은 방문 처리 안 함 (no direction)
    }

    List<(int, int)>? foundPath;

    while (queue.isNotEmpty) {
      final (vx, vy, dir, turns) = queue.removeFirst();

      if (goalSet.contains('$vx,$vy')) {
        // 경로 복원
        var path = <(int, int)>[];
        int cx = vx, cy = vy, cdir = dir, cturns = turns;
        while (true) {
          path.add((cx, cy));
          final k = _key(cx, cy, cdir, cturns);
          if (!parent.containsKey(k)) break;
          final pStr = parent[k]!;
          final parts = pStr.split(',');
          cx = int.parse(parts[0]);
          cy = int.parse(parts[1]);
          cdir = int.parse(parts[2]);
          cturns = int.parse(parts[3]);
        }
        // Reverse to start->goal and normalize to drop duplicate consecutive vertices
        path = path.reversed.toList();
        path = _normalizePath(path);
        debugPrint("✅ Path found between (${a.x},${a.y}) ↔ (${b.x},${b.y}) after $turns turns");
        foundPath = path;
        break;
      }

      for (int nd = 0; nd < 4; nd++) {
        final nx = vx + _DX[nd];
        final ny = vy + _DY[nd];
        if (!_vValid(nx, ny)) continue;

        final nTurns = (dir == -1 || dir == nd) ? turns : turns + 1;
        if (nTurns > _MAX_TURNS) continue;

        final ix = _idx(nx);
        final iy = _idx(ny);
        if (visited[ix][iy][nd][nTurns]) continue;

        if (_isPathBlockedBetween(vx, vy, nx, ny)) continue;

        visited[ix][iy][nd][nTurns] = true;
        queue.addLast((nx, ny, nd, nTurns));
        final fromKey = _key(vx, vy, dir, turns);
        final toKey = _key(nx, ny, nd, nTurns);
        parent[toKey] = fromKey;
      }
    }

    // ✅ 실제 경로의 방향 전환 횟수를 계산하여 허용 범위를 초과하면 무효 처리
    if (foundPath != null && foundPath.length >= 3) {
      int realTurns = _countTurns(foundPath);
      if (realTurns > _MAX_TURNS) {
        debugPrint("🚫 Path rejected: real turns = $realTurns > $_MAX_TURNS");
        return PathfinderResult(false);
      }
    }

    // ✅ 최소 2개 이상의 점으로 구성된 경로만 유효로 인정
    if (foundPath != null && foundPath.length >= 2) {
      return PathfinderResult(true, foundPath);
    }

    debugPrint("❌ No valid path between (${a.x},${a.y}) and (${b.x},${b.y})");
    return PathfinderResult(false);
  }

  List<(int,int)> _normalizePath(List<(int,int)> path) {
    if (path.isEmpty) return path;
    final out = <(int,int)>[];
    (int,int)? prev;
    for (final p in path) {
      if (prev == null || !(prev!.$1 == p.$1 && prev!.$2 == p.$2)) {
        out.add(p);
        prev = p;
      }
    }
    return out;
  }

  int _countTurns(List<(int,int)> path) {
    if (path.length < 3) return 0;
    int turns = 0;
    for (int i = 2; i < path.length; i++) {
      final (x0, y0) = path[i - 2];
      final (x1, y1) = path[i - 1];
      final (x2, y2) = path[i];
      final dx1 = x1 - x0;
      final dy1 = y1 - y0;
      final dx2 = x2 - x1;
      final dy2 = y2 - y1;
      if (dx1 != dx2 || dy1 != dy2) {
        turns++;
      }
    }
    return turns;
  }
}