import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/stage_model.dart';

class StageLoader {
  /// ✅ 단일 스테이지 로드
  /// ✅ 단일 스테이지 로드 (file_path 기반)
  static Future<StageModel> loadStageByPath(String filePath) async {
    try {
      final jsonString = await rootBundle.loadString(filePath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return StageModel.fromMap(data);
    } catch (e) {
      throw Exception('⚠️ StageLoader Error: Failed to load $filePath — $e');
    }
  }

  /// ✅ 인덱스 로드 (전체 스테이지 메타)
  static Future<List<Map<String, dynamic>>> loadStageIndex() async {
    const path = 'assets/game/data/stage_index.json';
    try {
      final jsonString = await rootBundle.loadString(path);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final stages = List<Map<String, dynamic>>.from(data['stages'] ?? []);
      return stages;
    } catch (e) {
      throw Exception('⚠️ StageLoader Error: Failed to load index — $e');
    }
  }
}