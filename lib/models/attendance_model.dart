import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceEvent {
  final String eventId;
  final String title;
  final int totalDays;
  final bool repeatable;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> rewards;
  final bool active;

  AttendanceEvent({
    required this.eventId,
    required this.title,
    required this.totalDays,
    required this.repeatable,
    required this.startDate,
    required this.endDate,
    required this.rewards,
    required this.active,
  });

  factory AttendanceEvent.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceEvent(
      eventId: data['event_id'] ?? '',
      title: data['title'] ?? '',
      totalDays: data['total_days'] ?? 7,
      repeatable: data['repeatable'] ?? true,
      startDate: (data['start_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['end_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rewards: Map<String, dynamic>.from(data['rewards'] ?? {}),
      active: data['active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'title': title,
      'total_days': totalDays,
      'repeatable': repeatable,
      'start_date': startDate,
      'end_date': endDate,
      'rewards': rewards,
      'active': active,
    };
  }
}

class UserAttendance {
  final String uid;
  final String eventId;
  final int totalChecked;
  final DateTime lastCheckDate;
  final Map<String, dynamic> rewardsStatus;
  final bool completed;
  final int restartCount;

  UserAttendance({
    required this.uid,
    required this.eventId,
    required this.totalChecked,
    required this.lastCheckDate,
    required this.rewardsStatus,
    required this.completed,
    required this.restartCount,
  });

  factory UserAttendance.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserAttendance(
      uid: data['uid'] ?? '',
      eventId: data['event_id'] ?? '',
      totalChecked: data['total_checked'] ?? 0,
      lastCheckDate: (data['last_check_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rewardsStatus: Map<String, dynamic>.from(data['rewards_status'] ?? {}),
      completed: data['completed'] ?? false,
      restartCount: data['restart_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'event_id': eventId,
      'total_checked': totalChecked,
      'last_check_date': lastCheckDate,
      'rewards_status': rewardsStatus,
      'completed': completed,
      'restart_count': restartCount,
    };
  }
}