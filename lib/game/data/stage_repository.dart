// lib/game/data/stage_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class StageMeta {
  final String id;
  final String name;
  final String filePath;
  final String thumbnail;
  final String difficulty;
  final bool unlocked;
  final String? unlockCondition;
  final Map<String, dynamic> rewards;
  final String description;

  StageMeta({
    required this.id,
    required this.name,
    required this.filePath,
    required this.thumbnail,
    required this.difficulty,
    required this.unlocked,
    required this.rewards,
    required this.description,
    this.unlockCondition,
  });

  factory StageMeta.fromMap(Map<String, dynamic> m) => StageMeta(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        // 인덱스는 file_path 또는 jsonPath 둘 중 하나만 올 수도 있음 → file_path 우선
        filePath: (m['file_path'] ?? m['jsonPath'] ?? '') as String,
        thumbnail: m['thumbnail'] ?? '',
        difficulty: m['difficulty'] ?? 'easy',
        unlocked: m['unlocked'] == true,
        rewards: Map<String, dynamic>.from(m['rewards'] ?? {}),
        description: m['description'] ?? '',
        unlockCondition: m['unlock_condition'],
      );
}

class StageRepository {
  static const String indexPath = 'assets/game/data/stage_index.json';

  Future<List<StageMeta>> fetchIndex() async {
    final raw = await rootBundle.loadString(indexPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = List<Map<String, dynamic>>.from(data['stages'] ?? []);
    return list.map(StageMeta.fromMap).toList();
  }

  /// 선택: 현재 id의 다음 스테이지 file_path/jsonPath 반환
  Future<String?> nextPathOf(String currentId) async {
    final raw = await rootBundle.loadString(indexPath);
    final data = json.decode(raw) as Map<String, dynamic>;
    final List<dynamic> stages = (data['stages'] as List<dynamic>? ?? []);
    final idx = stages.indexWhere((e) => (e as Map)['id'] == currentId);
    if (idx == -1 || idx + 1 >= stages.length) return null;
    final m = stages[idx + 1] as Map<String, dynamic>;
    return (m['file_path'] as String?) ?? (m['jsonPath'] as String?);
  }
}