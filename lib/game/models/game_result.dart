// lib/game/models/game_result.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 게임 1판의 종료 결과를 표현하는 모델
class GameResult {
  final String stageId;
  final String stageName;
  final String difficulty;

  final bool cleared;
  final bool failed;

  final int score;
  final int playTimeSec;

  /// 최종 획득 골드(세트/캐릭터 보정 반영 후)
  final int goldEarned;

  /// 보상 젬/경험치(스테이지가 정의했다면)
  final int gemEarned;
  final int expGained;

  /// 사용한 장착물(있다면)
  final String? usedCharacterId;
  final String? usedBlockSetId;
  final String? usedBackgroundId;

  /// 특정 아이템 강화 레벨 증가(선택)
  final String? enhanceItemId;
  final int? enhanceIncrement;

  final DateTime startedAt;
  final DateTime endedAt;

  GameResult({
    required this.stageId,
    required this.stageName,
    required this.difficulty,
    required this.cleared,
    required this.failed,
    required this.score,
    required this.playTimeSec,
    required this.goldEarned,
    this.gemEarned = 0,
    this.expGained = 0,
    this.usedCharacterId,
    this.usedBlockSetId,
    this.usedBackgroundId,
    this.enhanceItemId,
    this.enhanceIncrement,
    required this.startedAt,
    required this.endedAt,
  });

  Map<String, dynamic> toMap({required String uid}) {
    return {
      'uid': uid,
      'stage_id': stageId,
      'stage_name': stageName,
      'difficulty': difficulty,
      'cleared': cleared,
      'failed': failed,
      'score': score,
      'play_time_sec': playTimeSec,
      'gold_earned': goldEarned,
      'gem_earned': gemEarned,
      'exp_gained': expGained,
      'used_character_id': usedCharacterId,
      'used_block_set_id': usedBlockSetId,
      'used_background_id': usedBackgroundId,
      'enhance_item_id': enhanceItemId,
      'enhance_increment': enhanceIncrement,
      'started_at': Timestamp.fromDate(startedAt),
      'ended_at': Timestamp.fromDate(endedAt),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory GameResult.fromMap(Map<String, dynamic> m) {
    DateTime _toDT(dynamic v) =>
        v is Timestamp ? v.toDate() : (v as DateTime);

    return GameResult(
      stageId: m['stage_id'] as String,
      stageName: m['stage_name'] as String,
      difficulty: m['difficulty'] as String,
      cleared: (m['cleared'] as bool?) ?? false,
      failed: (m['failed'] as bool?) ?? false,
      score: (m['score'] as num?)?.toInt() ?? 0,
      playTimeSec: (m['play_time_sec'] as num?)?.toInt() ?? 0,
      goldEarned: (m['gold_earned'] as num?)?.toInt() ?? 0,
      gemEarned: (m['gem_earned'] as num?)?.toInt() ?? 0,
      expGained: (m['exp_gained'] as num?)?.toInt() ?? 0,
      usedCharacterId: m['used_character_id'] as String?,
      usedBlockSetId: m['used_block_set_id'] as String?,
      usedBackgroundId: m['used_background_id'] as String?,
      enhanceItemId: m['enhance_item_id'] as String?,
      enhanceIncrement: (m['enhance_increment'] as num?)?.toInt(),
      startedAt: _toDT(m['started_at']),
      endedAt: _toDT(m['ended_at']),
    );
  }
}