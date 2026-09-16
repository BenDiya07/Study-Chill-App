import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../analytics/analytics_state.dart';
import '../tasks/task_model.dart';
import 'pomodoro_state.dart';

final pomodoroRecorderProvider = Provider<void>((ref) {
  final taskRepo = ref.watch(taskRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);

  ref.listen(pomodoroProvider, (previous, next) {
    if (previous == null ||
        previous.mode != TimerMode.work ||
        next.mode == TimerMode.work ||
        next.completedSessions <= previous.completedSessions) {
      return;
    }

    final task = _resolveTask(taskRepo, next.activeTaskId);
    final taskId = task?.id ?? '';
    final category = task?.category ?? 'Général';

    sessionRepo.addSession(
      SessionRecord(
        id: 'session_${DateTime.now().microsecondsSinceEpoch}',
        taskId: taskId,
        category: category,
        durationSeconds: previous.workDuration,
        mode: TimerMode.work,
        timestamp: DateTime.now(),
      ),
    );

    if (taskId.isNotEmpty) {
      unawaited(taskRepo.incrementPomodoro(taskId));
    }
  });

  return;
});

Task? _resolveTask(TaskRepository repo, String? activeTaskId) {
  if (activeTaskId != null && activeTaskId.isNotEmpty) {
    try {
      return repo.getAll().firstWhere((t) => t.id == activeTaskId);
    } on StateError {
      return null;
    }
  }
  final open = repo.getAll(completed: false);
  return open.isNotEmpty ? open.first : null;
}
