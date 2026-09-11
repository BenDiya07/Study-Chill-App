import 'time_formatter.dart';
import '../../constants/app_constants.dart';

class StatsCalculator {
  static int computeTotalMinutes(List<int> sessionDurationsSeconds) {
    final sumSeconds = sessionDurationsSeconds.fold(0, (a, b) => a + b);
    return (sumSeconds / 60).floor();
  }

  static int computeStreakDays(List<DateTime> sessionDates) {
    if (sessionDates.isEmpty) return 0;
    final uniqueDays = sessionDates.map(startOfDay).toSet().toList()..sort();
    if (uniqueDays.isEmpty) return 0;
    
    int streak = 1;
    final today = startOfDay(DateTime.now());
    var current = uniqueDays.last;
    
    if (current != today && current != today.subtract(const Duration(days: 1))) {
      return 0;
    }
    
    for (var i = uniqueDays.length - 2; i >= 0; i--) {
      final expected = current.subtract(const Duration(days: 1));
      if (uniqueDays[i] == expected) {
        streak++;
        current = uniqueDays[i];
      } else {
        break;
      }
    }
    return streak;
  }

  static Map<DateTime, int> computeDailyMinutes(List<SessionRecord> sessions) {
    final map = <DateTime, int>{};
    for (final s in sessions) {
      final day = startOfDay(s.timestamp);
      map[day] = (map[day] ?? 0) + s.durationSeconds;
    }
    return map;
  }

  static Map<String, int> computeCategoryMinutes(List<SessionRecord> sessions) {
    final map = <String, int>{};
    for (final s in sessions) {
      map[s.category] = (map[s.category] ?? 0) + s.durationSeconds;
    }
    return map;
  }

  static double computeCompletionRate(List<SessionRecord> sessions) {
    if (sessions.isEmpty) return 0.0;
    final completed = sessions.where((s) => s.completed).length;
    return completed / sessions.length;
  }
}

class SessionRecord {
  final String id;
  final String taskId;
  final String category;
  final int durationSeconds;
  final TimerMode mode;
  final DateTime timestamp;
  final bool completed;

  SessionRecord({
    required this.id,
    required this.taskId,
    required this.category,
    required this.durationSeconds,
    required this.mode,
    required this.timestamp,
    this.completed = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'category': category,
    'durationSeconds': durationSeconds,
    'mode': mode.name,
    'timestamp': timestamp.toIso8601String(),
    'completed': completed,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    id: json['id'] as String,
    taskId: json['taskId'] as String,
    category: json['category'] as String,
    durationSeconds: json['durationSeconds'] as int,
    mode: TimerMode.values.byName(json['mode'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    completed: json['completed'] as bool? ?? true,
  );
}