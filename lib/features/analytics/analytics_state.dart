import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/stats_calculator.dart';
import '../../core/utils/time_formatter.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SessionRecord extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String taskId;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final int durationSeconds;
  
  @HiveField(4)
  final TimerMode mode;
  
  @HiveField(5)
  final DateTime timestamp;
  
  @HiveField(6)
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

class SessionRepository {
  static const String boxName = kHiveBoxSessions;
  late Box<SessionRecord> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SessionRecord>(boxName);
  }

  Box<SessionRecord> get box => _box;

  List<SessionRecord> getAll({DateTime? start, DateTime? end}) {
    var sessions = _box.values.toList();
    
    if (start != null) {
      sessions = sessions.where((s) => s.timestamp.isAfter(start) || s.timestamp.isAtSameMomentAs(start)).toList();
    }
    if (end != null) {
      sessions = sessions.where((s) => s.timestamp.isBefore(end) || s.timestamp.isAtSameMomentAs(end)).toList();
    }
    
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions;
  }

  Stream<List<SessionRecord>> watchAll() {
    return _box.watch().map((_) => getAll());
  }

  Future<void> addSession(SessionRecord session) async {
    await _box.add(session);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final sessionsProvider = StreamProvider<List<SessionRecord>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchAll();
});

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final sessionsAsync = ref.watch(sessionsProvider);
  return sessionsAsync.when(
    data: (sessions) => AnalyticsData.fromSessions(sessions),
    loading: () => AnalyticsData.empty(),
    error: (_, __) => AnalyticsData.empty(),
  );
});

class AnalyticsData {
  final int totalFocusMinutes;
  final int totalSessions;
  final int currentStreak;
  final double completionRate;
  final Map<DateTime, int> dailyMinutes;
  final Map<String, int> categoryMinutes;
  final List<SessionRecord> recentSessions;

  const AnalyticsData({
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.currentStreak,
    required this.completionRate,
    required this.dailyMinutes,
    required this.categoryMinutes,
    required this.recentSessions,
  });

  factory AnalyticsData.empty() => const AnalyticsData(
    totalFocusMinutes: 0,
    totalSessions: 0,
    currentStreak: 0,
    completionRate: 0,
    dailyMinutes: {},
    categoryMinutes: {},
    recentSessions: [],
  );

  factory AnalyticsData.fromSessions(List<SessionRecord> sessions) {
    final workSessions = sessions.where((s) => s.mode == TimerMode.work).toList();
    final completedSessions = sessions.where((s) => s.completed).toList();
    
    return AnalyticsData(
      totalFocusMinutes: StatsCalculator.computeTotalMinutes(workSessions.map((s) => s.durationSeconds).toList()),
      totalSessions: completedSessions.length,
      currentStreak: StatsCalculator.computeStreakDays(completedSessions.map((s) => s.timestamp).toList()),
      completionRate: StatsCalculator.computeCompletionRate(sessions),
      dailyMinutes: StatsCalculator.computeDailyMinutes(workSessions),
      categoryMinutes: StatsCalculator.computeCategoryMinutes(workSessions),
      recentSessions: sessions.take(10).toList(),
    );
  }

  String get formattedTotalFocus => formatDurationLong(totalFocusMinutes * 60);
  
  String get formattedStreak => '$currentStreak ${currentStreak > 1 ? 'jours' : 'jour'}';
  
  String get formattedCompletionRate => '${(completionRate * 100).round()}%';
}