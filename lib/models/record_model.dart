import 'package:cloud_firestore/cloud_firestore.dart';

/// =============================================================
/// 🧾 RecordModel — 한 판 플레이 기록(Log) 문서
/// -------------------------------------------------------------
/// • 컬렉션 예시: `/records/{autoId}`
/// • 목적: 스테이지 1회 플레이 결과(점수/소요시간/아이템 사용량 등)를
///   그대로 저장하는 **불변 로그**. 랭킹/히스토리/통계에 활용.
/// • 주의: 난이도(difficulty)와 순위(rank)는 저장하지 않고,
///   순위는 조회 시 계산하는 편이 일반적임.
/// • 닉네임(nickname)은 플레이 당시 스냅샷으로 저장하여 랭킹 효율성에 활용.
/// =============================================================
class RecordModel {
  /// 🔑 유저 UID (플레이한 사용자)
  final String uid;

  /// 플레이 당시 유저 닉네임 스냅샷
  final String nickname;

  /// 🔑 스테이지 ID (예: "stage_001")
  final String stageId;

  /// 클리어에 걸린 시간(초) — 실패 시 0 또는 측정값 정책에 맞게 기록
  final int clearTime;

  /// 힌트 아이템 사용 횟수
  final int hintUsed;

  /// 폭탄 아이템 사용 횟수
  final int bombUsed;

  /// 셔플 아이템 사용 횟수
  final int shuffleUsed;

  /// 최종 점수 — 남은 시간/콤보/정확도 등 게임 규칙 기반 산출값
  final int score;

  /// 문서 생성 시각 — Firestore 서버 타임스탬프 기반으로 저장 권장
  final DateTime createdAt;

  RecordModel({
    required this.uid,
    required this.nickname,
    required this.stageId,
    required this.clearTime,
    required this.hintUsed,
    required this.bombUsed,
    required this.shuffleUsed,
    required this.score,
    required this.createdAt,
  });

  /// Firestore Document → Model 변환
  /// - Timestamp 안전 변환 처리
  factory RecordModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordModel(
      uid: data['uid'] ?? '',
      nickname: data['nickname'] ?? '',
      stageId: data['stage_id'] ?? '',
      clearTime: (data['clear_time'] as num?)?.toInt() ?? 0,
      hintUsed: (data['hint_used'] as num?)?.toInt() ?? 0,
      bombUsed: (data['bomb_used'] as num?)?.toInt() ?? 0,
      shuffleUsed: (data['shuffle_used'] as num?)?.toInt() ?? 0,
      score: (data['score'] as num?)?.toInt() ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Model → Firestore Map 직렬화
  /// - `created_at`은 `FieldValue.serverTimestamp()`로 쓰는 것을 권장하지만,
  ///   여기서는 `DateTime`을 그대로 넣는다. 실제 저장 시점 로직에서
  ///   서버 타임스탬프를 쓰고 싶다면 해당 레벨에서 대체할 것.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'stage_id': stageId,
      'clear_time': clearTime,
      'hint_used': hintUsed,
      'bomb_used': bombUsed,
      'shuffle_used': shuffleUsed,
      'score': score,
      'created_at': createdAt,
    };
  }
}