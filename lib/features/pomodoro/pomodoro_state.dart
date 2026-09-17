import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_formatter.dart';

class PomodoroState {
  final int timeRemaining;
  final TimerMode mode;
  final bool isRunning;
  final int completedSessions;
  final String? activeTaskId;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;

  const PomodoroState({
    this.timeRemaining = kDefaultWorkDuration,
    this.mode = TimerMode.work,
    this.isRunning = false,
    this.completedSessions = 0,
    this.activeTaskId,
    this.workDuration = kDefaultWorkDuration,
    this.shortBreakDuration = kDefaultShortBreakDuration,
    this.longBreakDuration = kDefaultLongBreakDuration,
  });

  PomodoroState copyWith({
    int? timeRemaining,
    TimerMode? mode,
    bool? isRunning,
    int? completedSessions,
    String? activeTaskId,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
  }) {
    return PomodoroState(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      mode: mode ?? this.mode,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      activeTaskId: activeTaskId ?? this.activeTaskId,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
    );
  }

  String get formattedTime => formatDuration(timeRemaining);

  double get progress {
    final total = switch (mode) {
      TimerMode.work => workDuration,
      TimerMode.shortBreak => shortBreakDuration,
      TimerMode.longBreak => longBreakDuration,
    };
    return total > 0 ? timeRemaining / total : 1.0;
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier() : super(const PomodoroState());

  void tick() {
    if (state.timeRemaining <= 1) {
      _completeSession();
    } else {
      state = state.copyWith(timeRemaining: state.timeRemaining - 1);
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _timer = null;

    if (state.mode == TimerMode.work) {
      final newCompleted = state.completedSessions + 1;
      final isLongBreak = newCompleted % kSessionsBeforeLongBreak == 0;

      state = state.copyWith(
        mode: isLongBreak ? TimerMode.longBreak : TimerMode.shortBreak,
        timeRemaining:
            isLongBreak ? state.longBreakDuration : state.shortBreakDuration,
        completedSessions: newCompleted,
        isRunning: false,
      );
    } else {
      state = state.copyWith(
        mode: TimerMode.work,
        timeRemaining: state.workDuration,
        isRunning: false,
      );
    }
  }

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = PomodoroState(
      workDuration: state.workDuration,
      shortBreakDuration: state.shortBreakDuration,
      longBreakDuration: state.longBreakDuration,
    );
  }

  void skip() {
    _completeSession();
  }

  void setActiveTask(String? taskId) {
    state = state.copyWith(activeTaskId: taskId);
  }

  void setDurations({
    int? work,
    int? shortBreak,
    int? longBreak,
  }) {
    final wasWork = state.mode == TimerMode.work;
    final wasShortBreak = state.mode == TimerMode.shortBreak;

    state = state.copyWith(
      workDuration: work ?? state.workDuration,
      shortBreakDuration: shortBreak ?? state.shortBreakDuration,
      longBreakDuration: longBreak ?? state.longBreakDuration,
      timeRemaining: wasWork
          ? (work ?? state.workDuration)
          : wasShortBreak
              ? (shortBreak ?? state.shortBreakDuration)
              : state.timeRemaining,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider =
    StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  return PomodoroNotifier();
});
