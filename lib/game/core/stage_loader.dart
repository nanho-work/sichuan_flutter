import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/stage_model.dart';

class StageLoader {
  static Future<StageModel> loadStage(String stageId) async {
    final path = 'lib/game/data/$stageId.json';
    final jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString);
    return StageModel.fromJson(data);
  }
}