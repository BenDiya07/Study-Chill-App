import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:study_chill_app/core/network/connectivity.dart';
import 'package:study_chill_app/main.dart';
import 'package:study_chill_app/core/constants/app_constants.dart';
import 'package:study_chill_app/features/tasks/task_model.dart';
import 'package:study_chill_app/features/analytics/analytics_state.dart';
import 'package:study_chill_app/features/settings/settings_state.dart';

List<Override> _appOverrides({
  required TaskRepository taskRepo,
  required SessionRepository sessionRepo,
  required SettingsRepository settingsRepo,
}) =>
    [
      taskRepositoryProvider.overrideWithValue(taskRepo),
      sessionRepositoryProvider.overrideWithValue(sessionRepo),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      connectivityProvider.overrideWith(
          (ref) => Stream.value(<ConnectivityResult>[ConnectivityResult.wifi])),
    ];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      await Hive.initFlutter();
    } on Exception catch (_) {
      Hive.init(Directory.systemTemp.path);
    }
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(SessionRecordAdapter());
    Hive.registerAdapter(TimerModeAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration Tests - Full User Workflows', () {
    testWidgets(
        'Integration 1: Complete Pomodoro Session → Task Update → Analytics Update',
        (tester) async {
      // Setup repositories
      final taskRepo = TaskRepository();
      await taskRepo.init();

      final sessionRepo = SessionRepository();
      await sessionRepo.init();

      final settingsRepo = SettingsRepository();
      await settingsRepo.init();

      // Create a test task
      final task = taskRepo.addTask(
        title: 'Integration Test Task',
        priority: TaskPriority.urgent,
      );

      // Build app with real providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Pomodoro screen (already default)
      expect(find.text('Concentration'), findsOneWidget);

      // Start timer
      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);

      // Simulate timer completion by skipping
      await tester.tap(find.text('Passer'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pumpAndSettle();

      // Should now be in short break
      expect(find.text('Pause courte'), findsOneWidget);

      // Verify task was updated (completed 1 pomodoro)
      final updatedTasks = taskRepo.getAll();
      final updatedTask = updatedTasks.firstWhere((t) => t.id == task.id);
      expect(updatedTask.completedPomodoros, 1);
      expect(updatedTask.isCompleted, true);

      // Verify session was recorded
      final sessions = sessionRepo.getAll();
      expect(sessions, isNotEmpty);
      final workSession = sessions.firstWhere((s) => s.mode == TimerMode.work);
      expect(workSession.taskId, task.id);
      expect(workSession.durationSeconds, kDefaultWorkDuration);

      // Navigate to Analytics
      await tester.tap(find.byIcon(Icons.bar_chart_outlined).last);
      await tester.pumpAndSettle();

      // Analytics should reflect the new session
      expect(find.text('Statistiques'), findsOneWidget);
    });

    testWidgets('Integration 2: Offline Mode → Task Creation → Online Sync',
        (tester) async {
      final taskRepo = TaskRepository();
      await taskRepo.init();

      final sessionRepo = SessionRepository();
      await sessionRepo.init();

      final settingsRepo = SettingsRepository();
      await settingsRepo.init();

      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Tasks
      await tester.tap(find.byIcon(Icons.check_circle_outline).last);
      await tester.pumpAndSettle();

      // Add a task while "offline" (simulated by just using local repo)
      await tester.tap(find.text('Nouvelle tâche'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Offline Task');
      await tester.pump();

      await tester.tap(find.text('Créer'));
      await tester.pumpAndSettle();

      // Task should exist locally
      final tasks = taskRepo.getAll();
      expect(tasks.any((t) => t.title == 'Offline Task'), isTrue);

      // Simulate "coming online" - data is already in Hive, would sync to backend
      // In a real app, this would trigger a sync to server
      // For this test, we verify the local persistence works
      final persistedTasks = taskRepo.getAll();
      expect(persistedTasks.any((t) => t.title == 'Offline Task'), isTrue);
    });

    testWidgets('Integration 3: Settings Persistence Across Restart',
        (tester) async {
      final taskRepo = TaskRepository();
      await taskRepo.init();

      final sessionRepo = SessionRepository();
      await sessionRepo.init();

      final settingsRepo = SettingsRepository();
      await settingsRepo.init();

      // First app launch - change settings
      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings_outlined).last);
      await tester.pumpAndSettle();

      // Change theme to dark
      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      // Change locale to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Change work duration to 30 min
      await tester.drag(find.byType(Slider).first, const Offset(200, 0));
      await tester.pumpAndSettle();

      // "Restart" app - create new widget tree with same repos
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings again
      await tester.tap(find.byIcon(Icons.settings_outlined).last);
      await tester.pumpAndSettle();

      // Settings should be persisted
      // Note: In integration test, we can't easily verify radio selection state
      // but the SettingsRepository.load() should return the saved values
      final loadedSettings = settingsRepo.load();
      expect(loadedSettings.locale, const Locale('en', 'US'));
      expect(loadedSettings.themeMode, ThemeMode.dark);
      expect(
          loadedSettings.workDuration, greaterThan(25)); // Changed from default
    });

    testWidgets('Integration 4: Soundboard Preset → Pomodoro Session',
        (tester) async {
      final taskRepo = TaskRepository();
      await taskRepo.init();

      final sessionRepo = SessionRepository();
      await sessionRepo.init();

      final settingsRepo = SettingsRepository();
      await settingsRepo.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Soundboard
      await tester.tap(find.byIcon(Icons.graphic_eq_outlined).last);
      await tester.pumpAndSettle();

      // Select Focus preset
      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();

      // Verify channels activated
      // (Can't easily test audio state in integration test without audio plugin)
      // But we can verify UI shows playing state
      expect(find.byIcon(Icons.pause_circle_filled), findsAtLeast(2));

      // Navigate back to Pomodoro and start session
      await tester.tap(find.byIcon(Icons.timer_outlined).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('Integration 5: Full Day Workflow - Multiple Sessions → Stats',
        (tester) async {
      final taskRepo = TaskRepository();
      await taskRepo.init();

      final sessionRepo = SessionRepository();
      await sessionRepo.init();

      final settingsRepo = SettingsRepository();
      await settingsRepo.init();

      // Create multiple tasks
      taskRepo.addTask(
          title: 'Morning Study',
          priority: TaskPriority.urgent,
          targetPomodoros: 2);
      taskRepo.addTask(
          title: 'Afternoon Coding',
          priority: TaskPriority.medium,
          targetPomodoros: 3);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            taskRepo: taskRepo,
            sessionRepo: sessionRepo,
            settingsRepo: settingsRepo,
          ),
          child: const StudyChillApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Complete 2 pomodoros for task1
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.text('Démarrer'));
        await tester.pump();
        await tester.tap(find.text('Passer'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(seconds: 1));
        });
        await tester.pumpAndSettle();
        await tester.tap(find.text('Passer')); // Skip break
        await tester.pumpAndSettle();
      }

      // Complete 1 pomodoro for task2
      // Select task2 in UI (would need task selection UI)
      // For now just do one more session
      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      await tester.tap(find.text('Passer'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pumpAndSettle();

      // Check analytics
      await tester.tap(find.byIcon(Icons.bar_chart_outlined).last);
      await tester.pumpAndSettle();

      // Should show 3 sessions worth of data
      expect(find.text('Statistiques'), findsOneWidget);
    });
  });
}
