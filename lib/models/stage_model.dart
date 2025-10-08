import 'package:cloud_firestore/cloud_firestore.dart';

class StageModel {
  final String stageId;
  final String difficulty;
  final int tileRows;
  final int tileCols;
  final String tileSet;
  final String orientation;
  final Map<String, dynamic>? initialMap;
  final List<Map<String, dynamic>>? obstacles;
  final Map<String, dynamic>? unlockCondition;

  StageModel({
    required this.stageId,
    required this.difficulty,
    required this.tileRows,
    required this.tileCols,
    required this.tileSet,
    required this.orientation,
    this.initialMap,
    this.obstacles,
    this.unlockCondition,
  });

  factory StageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StageModel(
      stageId: data['stage_id'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
      tileRows: data['tile_rows'] ?? 10,
      tileCols: data['tile_cols'] ?? 14,
      tileSet: data['tile_set'] ?? 'fruit',
      orientation: data['orientation'] ?? 'portrait',
      initialMap: Map<String, dynamic>.from(data['initial_map'] ?? {}),
      obstacles: (data['obstacles'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      unlockCondition: Map<String, dynamic>.from(data['unlock_condition'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stage_id': stageId,
      'difficulty': difficulty,
      'tile_rows': tileRows,
      'tile_cols': tileCols,
      'tile_set': tileSet,
      'orientation': orientation,
      'initial_map': initialMap,
      'obstacles': obstacles,
      'unlock_condition': unlockCondition,
    };
  }
}