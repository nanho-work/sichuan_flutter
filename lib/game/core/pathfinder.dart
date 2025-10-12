import '../models/tile_model.dart';
import 'dart:collection';

// 단순 2D Pathfinder (최상단 블록만 활성화)
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

  bool _vValid(int vx, int vy) =>
      (vx >= 0 && vx < cols + 1 && vy >= 0 && vy < rows + 1) ||
      vx == -1 || vy == -1 || vx == cols || vy == rows;

  static const _DX = [0, 1, 0, -1];
  static const _DY = [-1, 0, 1, 0];

  List<(int vx, int vy)> _startVertices(Tile t) {
    final x = t.x, y = t.y;
    final layer = layerGetter(x, y);
    final out = <(int,int)>[];

    bool isEmptyOrLowerLayer(int nx, int ny) {
      if (nx < 0 || ny < 0 || nx >= cols || ny >= rows) return true;
      if (!isBlocked(nx, ny)) return true;
      final nLayer = layerGetter(nx, ny);
      if (nLayer < layer) {
        // Check if lower layer tile has at least one open face
        for (int d = 0; d < 4; d++) {
          final adjX = nx + _DX[d];
          final adjY = ny + _DY[d];
          if (adjX < 0 || adjY < 0 || adjX >= cols || adjY >= rows) return true;
          if (!isBlocked(adjX, adjY)) return true;
          final adjLayer = layerGetter(adjX, adjY);
          if (adjLayer < nLayer) return true;
        }
        return false;
      }
      return false;
    }

    final leftEmpty  = isEmptyOrLowerLayer(x - 1, y);
    final rightEmpty = isEmptyOrLowerLayer(x + 1, y);
    final upEmpty    = isEmptyOrLowerLayer(x, y - 1);
    final downEmpty  = isEmptyOrLowerLayer(x, y + 1);

    if (leftEmpty)  { out.add((x,   y));   out.add((x,   y+1)); }
    if (rightEmpty) { out.add((x+1, y));   out.add((x+1, y+1)); }
    if (upEmpty)    { out.add((x,   y));   out.add((x+1, y));   }
    if (downEmpty)  { out.add((x,   y+1)); out.add((x+1, y+1)); }

    final set = <String>{};
    final uniq = <(int,int)>[];
    for (final p in out) {
      final k = '${p.$1},${p.$2}';
      if (set.add(k)) uniq.add(p);
    }
    return uniq.where((p) => _vValid(p.$1, p.$2)).toList();
  }

  bool canConnect(Tile a, Tile b) {
    if (identical(a, b)) return false;
    if (a.type.isEmpty || a.type != b.type) return false;

    final ax = a.x, ay = a.y, bx = b.x, by = b.y;
    final aLayer = layerGetter(ax, ay);
    final bLayer = layerGetter(bx, by);

    // Adjacent check on same layer (direct adjacency)
    final dx = (ax - bx).abs();
    final dy = (ay - by).abs();
    if (aLayer == bLayer && ((dx == 1 && dy == 0) || (dx == 0 && dy == 1))) {
      return true;
    }

    final starts = _startVertices(a);
    final goals  = _startVertices(b);
    if (starts.isEmpty || goals.isEmpty) return false;
    final goalSet = <String>{ for (final g in goals) '${g.$1},${g.$2}' };

    final visited = List.generate(
      cols + 3,
      (_) => List.generate(rows + 3, (_) => List<bool>.filled(5, false)),
    );

    final queue = Queue<(int vx, int vy, int dir, int turns)>();
    for (final s in starts) {
      final sx = s.$1 + 1;
      final sy = s.$2 + 1;
      queue.addLast((sx, sy, -1, 0));
      visited[sx][sy][4] = true;
    }

    bool isOpen(int x, int y, int fromLayer) {
      final cx = x - 1;
      final cy = y - 1;
      if (cx < 0 || cy < 0 || cx >= cols || cy >= rows) return true;
      final blocked = isBlocked(cx, cy);
      final cellLayer = layerGetter(cx, cy);
      if (!blocked) return true;
      if (cellLayer < fromLayer) {
        // allow if higher layer tile has no blocking tile above it
        // check tile above current cell
        if (cy - 1 < 0) return true;
        final aboveBlocked = isBlocked(cx, cy - 1);
        if (!aboveBlocked) return true;
      }
      return false;
    }

    while (queue.isNotEmpty) {
      final (vx, vy, dir, turns) = queue.removeFirst();
      if (goalSet.contains('${vx - 1},${vy - 1}')) return true;

      for (int nd = 0; nd < 4; nd++) {
        final nx = vx + _DX[nd];
        final ny = vy + _DY[nd];
        if (nx < 0 || ny < 0 || nx > cols + 1 || ny > rows + 1) continue;

        final nTurns = (dir == -1 || dir == nd) ? turns : turns + 1;
        if (nTurns > 2) continue;

        if (visited[nx][ny][nd]) continue;

        final fromLayer = (nx - 1 >= 0 && ny - 1 >= 0 && nx - 1 < cols && ny - 1 < rows)
            ? layerGetter(nx - 1, ny - 1)
            : -1;

        if (!goalSet.contains('${nx - 1},${ny - 1}') && !isOpen(nx, ny, fromLayer)) continue;

        visited[nx][ny][nd] = true;
        queue.addLast((nx, ny, nd, nTurns));
      }
    }
    return false;
  }
}