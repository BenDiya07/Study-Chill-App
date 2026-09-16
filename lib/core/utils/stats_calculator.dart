import 'time_formatter.dart';

class StatsCalculator {
  static int computeTotalMinutes(List<int> sessionDurationsSeconds) {
    final sumSeconds = sessionDurationsSeconds.fold(0, (a, b) => a + b);
    return (sumSeconds / 60).floor();
  }

  static int computeStreakDays(List<DateTime> sessionDates) {
    if (sessionDates.isEmpty) return 0;
    final uniqueDays = sessionDates.map(startOfDay).toSet().toList()..sort();
    if (uniqueDays.isEmpty) return 0;

    final today = startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    var current = uniqueDays.last;

    if (current != today && current != yesterday) {
      return 0;
    }

    int streak = 1;
    for (var i = uniqueDays.length - 2; i >= 0; i--) {
      final expected = current.subtract(const Duration(days: 1));
      if (uniqueDays[i] != expected) {
        return 0;
      }
      streak++;
      current = uniqueDays[i];
    }
    return streak;
  }

  static Map<DateTime, int> computeDailyMinutes(
      List<int> durationsSeconds, List<DateTime> timestamps) {
    final map = <DateTime, int>{};
    for (var i = 0; i < durationsSeconds.length; i++) {
      final day = startOfDay(timestamps[i]);
      map[day] = (map[day] ?? 0) + durationsSeconds[i];
    }
    return map;
  }

  static Map<String, int> computeCategoryMinutes(
      List<String> categories, List<int> durationsSeconds) {
    final map = <String, int>{};
    for (var i = 0; i < categories.length; i++) {
      map[categories[i]] = (map[categories[i]] ?? 0) + durationsSeconds[i];
    }
    return map;
  }

  static double computeCompletionRate(List<bool> completedFlags) {
    if (completedFlags.isEmpty) return 0;
    final completed = completedFlags.where((c) => c).length;
    return completed / completedFlags.length;
  }
}
