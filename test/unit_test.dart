import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lib/core/constants/app_constants.dart';
import 'lib/core/utils/stats_calculator.dart';
import 'lib/core/utils/time_formatter.dart';
import 'lib/features/pomodoro/pomodoro_state.dart';
import 'lib/features/soundboard/soundboard_state.dart';
import 'lib/features/tasks/task_model.dart';
import 'lib/features/analytics/analytics_state.dart';
import 'lib/features/settings/settings_state.dart';

@GenerateMocks([Box])
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(SessionRecordAdapter());
  });

  group('Unit Tests - Business Logic', () {
    group('PomodoroNotifier', () {
      late PomodoroNotifier notifier;

      setUp(() {
        notifier = PomodoroNotifier();
      });

      tearDown(() {
        notifier.dispose();
      });

      test('1. Initial state: 25 minutes work mode, not running', () {
        expect(notifier.state.timeRemaining, kDefaultWorkDuration);
        expect(notifier.state.mode, TimerMode.work);
        expect(notifier.state.isRunning, false);
        expect(notifier.state.completedSessions, 0);
      });

      test('2. tick() decrements timeRemaining', () {
        notifier.start();
        notifier.tick();
        expect(notifier.state.timeRemaining, kDefaultWorkDuration - 1);
      });

      test('3. Transitions to shortBreak when work timer reaches zero', () {
        notifier = PomodoroNotifier();
        notifier.state = PomodoroState(
          timeRemaining: 1,
          mode: TimerMode.work,
          workDuration: kDefaultWorkDuration,
        );
        notifier.tick();
        expect(notifier.state.mode, TimerMode.shortBreak);
        expect(notifier.state.timeRemaining, kDefaultShortBreakDuration);
        expect(notifier.state.completedSessions, 1);
      });

      test('4. Transitions to longBreak after 4 sessions', () {
        notifier = PomodoroNotifier();
        notifier.state = PomodoroState(
          timeRemaining: 1,
          mode: TimerMode.work,
          workDuration: kDefaultWorkDuration,
          completedSessions: 3,
        );
        notifier.tick();
        expect(notifier.state.mode, TimerMode.longBreak);
        expect(notifier.state.timeRemaining, kDefaultLongBreakDuration);
        expect(notifier.state.completedSessions, 4);
      });

      test('5. start() sets isRunning true', () {
        notifier.start();
        expect(notifier.state.isRunning, true);
      });

      test('6. pause() sets isRunning false', () {
        notifier.start();
        notifier.pause();
        expect(notifier.state.isRunning, false);
      });

      test('7. reset() restores initial state', () {
        notifier.start();
        notifier.tick();
        notifier.reset();
        expect(notifier.state.timeRemaining, kDefaultWorkDuration);
        expect(notifier.state.mode, TimerMode.work);
        expect(notifier.state.isRunning, false);
        expect(notifier.state.completedSessions, 0);
      });

      test('8. skip() transitions to next mode immediately', () {
        notifier.state = PomodoroState(
          timeRemaining: 1000,
          mode: TimerMode.work,
        );
        notifier.skip();
        expect(notifier.state.mode, TimerMode.shortBreak);
        expect(notifier.state.completedSessions, 1);
      });

      test('9. setDurations updates work duration', () {
        notifier.setDurations(work: 30 * 60);
        expect(notifier.state.workDuration, 1800);
        expect(notifier.state.timeRemaining, 1800);
      });
    });

    group('TaskRepository', () {
      late TaskRepository repo;
      late Box<Task> mockBox;

      setUp(() async {
        mockBox = MockBox();
        repo = TaskRepository();
        repo._box = mockBox;
      });

      test('10. addTask creates task with unique id and priority', () {
        when(mockBox.add(any)).thenAnswer((_) async {});
        
        final task = repo.addTask('Test Task', TaskPriority.urgent, targetPomodoros: 2, category: 'Work');
        
        expect(task.title, 'Test Task');
        expect(task.priority, TaskPriority.urgent);
        expect(task.targetPomodoros, 2);
        expect(task.category, 'Work');
        expect(task.id, startsWith('task_'));
        verify(mockBox.add(any)).called(1);
      });

      test('11. toggleTask flips completion state', () {
        final task = Task(
          id: 'task_1',
          title: 'Test',
          priority: TaskPriority.medium,
        );
        when(mockBox.values).thenReturn([task]);
        when(task.save()).thenAnswer((_) async {});
        
        repo.toggleTask('task_1');
        
        expect(task.isCompleted, true);
        expect(task.completedAt, isNotNull);
        verify(task.save()).called(1);
      });

      test('12. incrementPomodoro increases count and auto-completes at target', () {
        final task = Task(
          id: 'task_2',
          title: 'Test',
          priority: TaskPriority.medium,
          targetPomodoros: 2,
        );
        when(mockBox.values).thenReturn([task]);
        when(task.save()).thenAnswer((_) async {});
        
        repo.incrementPomodoro('task_2');
        expect(task.completedPomodoros, 1);
        expect(task.isCompleted, false);
        
        repo.incrementPomodoro('task_2');
        expect(task.completedPomodoros, 2);
        expect(task.isCompleted, true);
        expect(task.completedAt, isNotNull);
      });
    });

    group('AudioMixerNotifier', () {
      late AudioMixerNotifier notifier;

      setUp(() {
        notifier = AudioMixerNotifier();
      });

      test('13. Default state: all channels inactive, master 0.8', () {
        expect(notifier.state.masterVolume, 0.8);
        expect(notifier.state.isMasterMuted, false);
        for (final ch in notifier.state.channels.values) {
          expect(ch.isPlaying, false);
          expect(ch.volume, 0.5);
        }
      });

      test('14. toggleChannel activates/deactivates channel', () {
        expect(notifier.state.channels[kAudioRain]!.isPlaying, false);
        notifier.toggleChannel(kAudioRain);
        expect(notifier.state.channels[kAudioRain]!.isPlaying, true);
        notifier.toggleChannel(kAudioRain);
        expect(notifier.state.channels[kAudioRain]!.isPlaying, false);
      });

      test('15. setChannelVolume clamps values', () {
        notifier.setChannelVolume(kAudioRain, 1.5);
        expect(notifier.state.channels[kAudioRain]!.volume, 1.0);
        notifier.setChannelVolume(kAudioRain, -0.5);
        expect(notifier.state.channels[kAudioRain]!.volume, 0.0);
      });

      test('16. getEffectiveVolume applies master volume multiplier', () {
        notifier.toggleChannel(kAudioRain);
        notifier.setChannelVolume(kAudioRain, 0.5);
        notifier.setMasterVolume(0.8);
        expect(notifier.state.getEffectiveVolume(kAudioRain), closeTo(0.4, 0.001));
      });

      test('17. Master mute returns 0 effective volume', () {
        notifier.toggleChannel(kAudioRain);
        notifier.toggleMasterMute();
        expect(notifier.state.getEffectiveVolume(kAudioRain), 0.0);
      });

      test('18. loadPreset activates specific channels', () {
        notifier.loadPreset('focus');
        expect(notifier.state.channels[kAudioWhiteNoise]!.isPlaying, true);
        expect(notifier.state.channels[kAudioRain]!.isPlaying, true);
        expect(notifier.state.channels[kAudioCoffee]!.isPlaying, false);
      });

      test('19. stopAll deactivates all channels', () {
        notifier.loadPreset('focus');
        notifier.stopAll();
        for (final ch in notifier.state.channels.values) {
          expect(ch.isPlaying, false);
        }
      });
    });

    group('StatsCalculator', () {
      test('20. computeTotalMinutes sums seconds correctly', () {
        final durations = [1500, 1500, 1800]; // 4800 seconds = 80 minutes
        final minutes = StatsCalculator.computeTotalMinutes(durations);
        expect(minutes, 80);
      });

      test('21. computeStreakDays calculates consecutive days', () {
        final today = DateTime.now();
        final dates = [
          today,
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
        ];
        final streak = StatsCalculator.computeStreakDays(dates);
        expect(streak, 3);
      });

      test('22. computeStreakDays returns 0 for broken streak', () {
        final today = DateTime.now();
        final dates = [
          today,
          today.subtract(const Duration(days: 2)), // gap
        ];
        final streak = StatsCalculator.computeStreakDays(dates);
        expect(streak, 0);
      });

      test('23. computeDailyMinutes groups by day', () {
        final today = DateTime.now();
        final sessions = [
          SessionRecord(id: '1', taskId: 't1', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: today),
          SessionRecord(id: '2', taskId: 't1', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: today),
          SessionRecord(id: '3', taskId: 't2', category: 'Study', durationSeconds: 1800, mode: TimerMode.work, timestamp: today.subtract(const Duration(days: 1))),
        ];
        final daily = StatsCalculator.computeDailyMinutes(sessions);
        expect(daily[startOfDay(today)]!, 3000);
        expect(daily[startOfDay(today.subtract(const Duration(days: 1)))]!, 1800);
      });

      test('24. computeCategoryMinutes groups by category', () {
        final sessions = [
          SessionRecord(id: '1', taskId: 't1', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: DateTime.now()),
          SessionRecord(id: '2', taskId: 't2', category: 'Study', durationSeconds: 1800, mode: TimerMode.work, timestamp: DateTime.now()),
          SessionRecord(id: '3', taskId: 't3', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: DateTime.now()),
        ];
        final cats = StatsCalculator.computeCategoryMinutes(sessions);
        expect(cats['Work'], 3000);
        expect(cats['Study'], 1800);
      });

      test('25. computeCompletionRate calculates ratio', () {
        final sessions = [
          SessionRecord(id: '1', taskId: 't1', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: DateTime.now(), completed: true),
          SessionRecord(id: '2', taskId: 't2', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: DateTime.now(), completed: true),
          SessionRecord(id: '3', taskId: 't3', category: 'Work', durationSeconds: 1500, mode: TimerMode.work, timestamp: DateTime.now(), completed: false),
        ];
        final rate = StatsCalculator.computeCompletionRate(sessions);
        expect(rate, closeTo(2/3, 0.01));
      });
    });

    group('SettingsRepository', () {
      late SettingsRepository repo;
      late SharedPreferences prefs;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        prefs = await SharedPreferences.getInstance();
        repo = SettingsRepository();
        await repo.init();
      });

      test('26. load() returns defaults when empty', () {
        final state = repo.load();
        expect(state.locale, const Locale('fr', 'FR'));
        expect(state.themeMode, ThemeMode.system);
        expect(state.workDuration, 25);
        expect(state.masterVolume, 0.8);
      });

      test('27. save() and load() persist values', () async {
        const newState = SettingsState(
          locale: Locale('en', 'US'),
          themeMode: ThemeMode.dark,
          workDuration: 30,
          masterVolume: 0.5,
        );
        await repo.save(newState);
        final loaded = repo.load();
        expect(loaded.locale, const Locale('en', 'US'));
        expect(loaded.themeMode, ThemeMode.dark);
        expect(loaded.workDuration, 30);
        expect(loaded.masterVolume, 0.5);
      });

      test('28. setLocale updates locale only', () async {
        await repo.setLocale('en');
        final state = repo.load();
        expect(state.locale, const Locale('en', 'US'));
        expect(state.themeMode, ThemeMode.system); // unchanged
      });

      test('29. setThemeMode updates theme only', () async {
        await repo.setThemeMode(ThemeMode.light);
        final state = repo.load();
        expect(state.themeMode, ThemeMode.light);
        expect(state.locale, const Locale('fr', 'FR')); // unchanged
      });
    });

    group('TimeFormatter', () {
      test('30. formatDuration formats seconds to MM:SS', () {
        expect(formatDuration(1500), '25:00');
        expect(formatDuration(90), '01:30');
        expect(formatDuration(0), '00:00');
        expect(formatDuration(59), '00:59');
        expect(formatDuration(3600), '60:00');
      });

      test('31. formatDurationLong formats to human readable', () {
        expect(formatDurationLong(3600), '1h 00m');
        expect(formatDurationLong(5400), '1h 30m');
        expect(formatDurationLong(1800), '30m 00s');
      });
    });

    group('AuthInterceptor', () {
      test('32. intercept adds Bearer token', () {
        final interceptor = AuthInterceptor(token: 'test_token');
        final headers = interceptor.intercept({'Content-Type': 'application/json'});
        expect(headers['Authorization'], 'Bearer test_token');
      });

      test('33. handleResponse clears token on 401', () {
        final interceptor = AuthInterceptor(token: 'test_token');
        final ok = interceptor.handleResponse(401);
        expect(ok, false);
        expect(interceptor.token, isNull);
      });

      test('34. handleResponse keeps token on 200', () {
        final interceptor = AuthInterceptor(token: 'test_token');
        final ok = interceptor.handleResponse(200);
        expect(ok, true);
        expect(interceptor.token, 'test_token');
      });
    });
  });
}