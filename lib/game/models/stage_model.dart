import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'tile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StageModel {
  final String id; // ← 기존 id로 복원
  final String name;
  final String difficulty;
  final int rows;
  final int cols;
  final int timeLimit;
  final String tileSet;
  final String orientation;

  final List<Tile> tiles;
  final List<Obstacle> obstacles;
  final Map<String, dynamic> rewards;
  final Map<String, dynamic>? unlockCondition;

  StageModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.timeLimit,
    required this.tileSet,
    required this.orientation,
    required this.tiles,
    required this.obstacles,
    required this.rewards,
    this.unlockCondition,
  });

  /// ✅ Firestore 문서 로드용 (유지)
  factory StageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StageModel.fromMap(data);
  }

  /// ✅ JSON(Map) 로드용
  factory StageModel.fromMap(Map<String, dynamic> data) {
    return StageModel(
      id: data['id'] ?? data['stage_id'] ?? '',
      name: data['name'] ?? 'Unknown Stage',
      difficulty: data['difficulty'] ?? 'easy',
      rows: data['rows'] ?? data['tile_rows'] ?? 8,
      cols: data['cols'] ?? data['tile_cols'] ?? 6,
      timeLimit: data['time_limit'] ?? 300,
      tileSet: data['tile_set'] ?? 'fruit',
      orientation: data['orientation'] ?? 'portrait',
      tiles: _parseTiles(data),
      obstacles: _parseObstacles(data),
      rewards: Map<String, dynamic>.from(data['rewards'] ?? {}),
      unlockCondition: data['unlock_condition'] != null
          ? Map<String, dynamic>.from(data['unlock_condition'])
          : null,
    );
  }

  /// ✅ 타일 리스트 변환
  static List<Tile> _parseTiles(Map<String, dynamic> data) {
    final list = (data['tiles']?['data'] ?? []) as List;
    return list.map((t) => Tile.fromMap(Map<String, dynamic>.from(t))).toList();
  }

  /// ✅ 장애물 리스트 변환
  static List<Obstacle> _parseObstacles(Map<String, dynamic> data) {
    final list = (data['obstacles']?['data'] ?? []) as List;
    return list.map((o) => Obstacle.fromMap(Map<String, dynamic>.from(o))).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'rows': rows,
      'cols': cols,
      'time_limit': timeLimit,
      'tile_set': tileSet,
      'orientation': orientation,
      'tiles': tiles.map((t) => t.toMap()).toList(),
      'obstacles': obstacles.map((o) => o.toMap()).toList(),
      'rewards': rewards,
      'unlock_condition': unlockCondition,
    };
  }
}

/// ✅ 장애물 모델 (엔진 호환용)
class Obstacle {
  final int x;
  final int y;
  final String type;
  final int durability;

  Obstacle({
    required this.x,
    required this.y,
    required this.type,
    this.durability = 1,
  });

  factory Obstacle.fromMap(Map<String, dynamic> data) {
    return Obstacle(
      x: data['x'] ?? 0,
      y: data['y'] ?? 0,
      type: data['type'] ?? 'unknown',
      durability: data['durability'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'type': type,
      'durability': durability,
    };
  }
}