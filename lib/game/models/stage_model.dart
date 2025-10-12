import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'tile_model.dart';

class StageModel {
  final String id;
  final String name;
  final String difficulty; // 'easy' | ...
  final int rows;
  final int cols;
  final int timeLimit;

  /// modifiers: JSON 그대로 보관(플래그/수치)
  final Map<String, dynamic> modifiers; // enable_hint 등
  /// objectives: { type: 'clear_all' ... }
  final Map<String, dynamic> objectives;
  /// rewards: { gold, gem, exp }
  final Map<String, dynamic> rewards;

  final List<Tile> tiles;
  final List<Obstacle> obstacles;
  final List<SpecialTile> specialTiles;

  StageModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.timeLimit,
    required this.modifiers,
    required this.objectives,
    required this.rewards,
    required this.tiles,
    required this.obstacles,
    required this.specialTiles,
  });

  factory StageModel.fromMap(Map<String, dynamic> map) {
    final tilesData = (map['tiles']?['data'] as List? ?? []);
    final obstaclesData = (map['obstacles']?['data'] as List? ?? []);
    final specialsData = (map['special_tiles']?['data'] as List? ?? []);

    return StageModel(
      id: map['id'] as String,
      name: map['name'] as String,
      difficulty: map['difficulty'] as String,
      rows: (map['rows'] as num).toInt(),
      cols: (map['cols'] as num).toInt(),
      timeLimit: (map['time_limit'] as num).toInt(),
      modifiers: (map['modifiers'] as Map?)?.cast<String, dynamic>() ?? const {},
      objectives: (map['objectives'] as Map?)?.cast<String, dynamic>() ?? const {},
      rewards: (map['rewards'] as Map?)?.cast<String, dynamic>() ?? const {},
      tiles: tilesData.map((e) {
        final m = e as Map<String, dynamic>;
        return Tile(
          x: (m['x'] as num).toInt(),
          y: (m['y'] as num).toInt(),
          layer: (m['layer'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
      obstacles: obstaclesData.map((e) {
        final m = e as Map<String, dynamic>;
        return Obstacle(
          x: (m['x'] as num).toInt(),
          y: (m['y'] as num).toInt(),
          type: m['type'] as String,
          durability: (m['durability'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
      specialTiles: specialsData.map((e) {
        final m = e as Map<String, dynamic>;
        return SpecialTile(
          x: (m['x'] as num).toInt(),
          y: (m['y'] as num).toInt(),
          effect: m['effect'] as String,
        );
      }).toList(),
    );
  }

  static Future<StageModel> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return StageModel.fromMap(map);
  }
}