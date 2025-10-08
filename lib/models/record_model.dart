import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String uid;
  final String stageId;
  final String difficulty;
  final int clearTime;
  final int mistakeCount;
  final int hintUsed;
  final int bombUsed;
  final int shuffleUsed;
  final int score;
  final int rank;
  final DateTime createdAt;

  RecordModel({
    required this.uid,
    required this.stageId,
    required this.difficulty,
    required this.clearTime,
    required this.mistakeCount,
    required this.hintUsed,
    required this.bombUsed,
    required this.shuffleUsed,
    required this.score,
    required this.rank,
    required this.createdAt,
  });

  factory RecordModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordModel(
      uid: data['uid'] ?? '',
      stageId: data['stage_id'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
      clearTime: data['clear_time'] ?? 0,
      mistakeCount: data['mistake_count'] ?? 0,
      hintUsed: data['hint_used'] ?? 0,
      bombUsed: data['bomb_used'] ?? 0,
      shuffleUsed: data['shuffle_used'] ?? 0,
      score: data['score'] ?? 0,
      rank: data['rank'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'stage_id': stageId,
      'difficulty': difficulty,
      'clear_time': clearTime,
      'mistake_count': mistakeCount,
      'hint_used': hintUsed,
      'bomb_used': bombUsed,
      'shuffle_used': shuffleUsed,
      'score': score,
      'rank': rank,
      'created_at': createdAt,
    };
  }
}