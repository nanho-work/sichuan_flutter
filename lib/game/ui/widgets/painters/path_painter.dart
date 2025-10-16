import 'package:flutter/material.dart';

/// PathPainter
/// - Pathfinder에서 반환된 경로(path)를 선으로 시각화
/// - progress(0.0~1.0)를 이용해 점진적으로 선이 그려지는 애니메이션 가능
class PathPainter extends CustomPainter {
  final List<(int, int)> path; // Pathfinder에서 받은 경로 좌표 리스트
  final double progress; // 0.0 ~ 1.0 사이의 진행률
  final double cellSize; // 셀 크기 (타일 간격)
  final Color color; // 선 색상
  final double strokeWidth; // 선 두께

  PathPainter({
    required this.path,
    required this.progress,
    this.cellSize = 48.0,
    this.color = Colors.yellowAccent,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    debugPrint('🎨 PathPainter invoked: path length = ${path.length}, progress = $progress');
    debugPrint('🎨 PathPainter points: $path');

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final p = Path();

    // 좌표를 Path로 변환
    for (int i = 0; i < path.length; i++) {
      final (x, y) = path[i];
      final dx = (x + 0.5) * cellSize;
      final dy = (y + 0.5) * cellSize;

      if (i == 0) {
        p.moveTo(dx, dy);
      } else {
        p.lineTo(dx, dy);
      }
    }

    // 진행률(progress)에 따라 Path를 부분적으로 그림
    final totalLength = _calculatePathLength(p);
    final visibleLength = totalLength * progress;

    final metrics = p.computeMetrics();
    final partial = Path();

    double drawnLength = 0.0;
    for (final metric in metrics) {
      final remaining = visibleLength - drawnLength;
      if (remaining <= 0) break;
      final extractLength = remaining.clamp(0, metric.length).toDouble();
      partial.addPath(metric.extractPath(0, extractLength), Offset.zero);
      drawnLength += extractLength;
    }

    debugPrint('🎨 Drawing partial path with visibleLength = $visibleLength / $totalLength');
    canvas.drawPath(partial, paint);
  }

  /// 경로 총 길이 계산
  double _calculatePathLength(Path path) {
    double length = 0.0;
    for (final metric in path.computeMetrics()) {
      length += metric.length;
    }
    return length;
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}