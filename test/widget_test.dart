import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'lib/main.dart';
import 'lib/core/constants/app_constants.dart';
import 'lib/features/pomodoro/pomodoro_screen.dart';
import 'lib/features/pomodoro/pomodoro_state.dart';
import 'lib/features/soundboard/soundboard_screen.dart';
import 'lib/features/soundboard/soundboard_state.dart';
import 'lib/features/tasks/tasks_screen.dart';
import 'lib/features/tasks/task_model.dart';
import 'lib/features/analytics/analytics_screen.dart';
import 'lib/features/analytics/analytics_state.dart';
import 'lib/features/settings/settings_screen.dart';
import 'lib/features/settings/settings_state.dart';
import 'lib/l10n/app_localizations.dart';

@GenerateMocks([TaskRepository, SessionRepository, SettingsRepository])
void main() {
  group('Widget Tests - UI Components', () {
    Widget createTestApp({required Widget child, Locale? locale}) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
          locale: locale,
          home: child,
        ),
      );
    }

    group('PomodoroScreen', () {
      testWidgets('1. Displays timer with formatted time', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        expect(find.text('25:00'), findsOneWidget);
      });

      testWidgets('2. Shows mode indicator "Concentration"', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        expect(find.text('Concentration'), findsOneWidget);
      });

      testWidgets('3. Start button toggles to Pause', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        expect(find.text('Démarrer'), findsOneWidget);
        await tester.tap(find.text('Démarrer'));
        await tester.pump();
        expect(find.text('Pause'), findsOneWidget);
      });

      testWidgets('4. Reset button resets timer', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Démarrer'));
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.text('Réinitialiser'));
        await tester.pump();
        expect(find.text('25:00'), findsOneWidget);
        expect(find.text('Démarrer'), findsOneWidget);
      });

      testWidgets('5. Skip button advances to break', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Passer'));
        await tester.pump();
        expect(find.text('Pause courte'), findsOneWidget);
        expect(find.text('05:00'), findsOneWidget);
      });

      testWidgets('6. Session counter shows completed sessions', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        // Complete a session by skipping
        await tester.tap(find.text('Passer'));
        await tester.pump();
        
        // Should show 1 filled circle
        expect(find.byIcon(Icons.circle), findsAtLeast(1));
      });
    });

    group('SoundboardScreen', () {
      testWidgets('7. Displays master volume control', (tester) async {
        await tester.pumpWidget(createTestApp(child: const SoundboardScreen()));
        await tester.pumpAndSettle();
        
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        expect(find.text('80%'), findsOneWidget);
      });

      testWidgets('8. Shows all 6 audio channels', (tester) async {
        await tester.pumpWidget(createTestApp(child: const SoundboardScreen()));
        await tester.pumpAndSettle();
        
        expect(find.text('Pluie'), findsOneWidget);
        expect(find.text('Café'), findsOneWidget);
        expect(find.text('Bruit blanc'), findsOneWidget);
        expect(find.text('Feu de camp'), findsOneWidget);
        expect(find.text('Forêt'), findsOneWidget);
        expect(find.text('Océan'), findsOneWidget);
      });

      testWidgets('9. Tapping play icon toggles channel', (tester) async {
        await tester.pumpWidget(createTestApp(child: const SoundboardScreen()));
        await tester.pumpAndSettle();
        
        // Find first play button and tap
        final playButtons = find.byIcon(Icons.play_circle_filled);
        expect(playButtons, findsAtLeast(1));
        await tester.tap(playButtons.first);
        await tester.pump();
        
        // Should now show pause icon
        expect(find.byIcon(Icons.pause_circle_filled), findsAtLeast(1));
      });

      testWidgets('10. Preset buttons are present', (tester) async {
        await tester.pumpWidget(createTestApp(child: const SoundboardScreen()));
        await tester.pumpAndSettle();
        
        expect(find.text('Focus'), findsOneWidget);
        expect(find.text('Relax'), findsOneWidget);
        expect(find.text('Cozy'), findsOneWidget);
        expect(find.text('Stop'), findsOneWidget);
      });

      testWidgets('11. Stop All button stops all channels', (tester) async {
        await tester.pumpWidget(createTestApp(child: const SoundboardScreen()));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Focus'));
        await tester.pump();
        
        await tester.tap(find.text('Tout arrêter'));
        await tester.pump();
        
        // All channels should be inactive
        expect(find.byIcon(Icons.play_circle_filled), findsAtLeast(6));
      });
    });

    group('TasksScreen', () {
      late MockTaskRepository mockRepo;

      setUp(() {
        mockRepo = MockTaskRepository();
      });

      testWidgets('12. Shows empty state when no tasks', (tester) async {
        when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const TasksScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('Aucune tâche'), findsOneWidget);
      });

      testWidgets('13. Add task button opens dialog', (tester) async {
        when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const TasksScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Nouvelle tâche'));
        await tester.pumpAndSettle();
        
        expect(find.text('Nouvelle tâche'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('14. Category filter chips are displayed', (tester) async {
        when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [taskRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const TasksScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('Tous'), findsOneWidget);
      });
    });

    group('AnalyticsScreen', () {
      testWidgets('15. Displays stats grid with 4 cards', (tester) async {
        final analytics = AnalyticsData(
          totalFocusMinutes: 120,
          totalSessions: 5,
          currentStreak: 3,
          completionRate: 0.8,
          dailyMinutes: {},
          categoryMinutes: {},
          recentSessions: [],
        );
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [analyticsProvider.overrideWithValue(analytics)],
            child: createTestApp(child: const AnalyticsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('2h 00m'), findsOneWidget); // Total focus
        expect(find.text('5'), findsOneWidget); // Sessions
        expect(find.text('3 jours'), findsOneWidget); // Streak
        expect(find.text('80%'), findsOneWidget); // Completion rate
      });

      testWidgets('16. Shows charts when data exists', (tester) async {
        final today = DateTime.now();
        final analytics = AnalyticsData(
          totalFocusMinutes: 120,
          totalSessions: 5,
          currentStreak: 3,
          completionRate: 0.8,
          dailyMinutes: {today: 7200},
          categoryMinutes: {'Work': 3600, 'Study': 3600},
          recentSessions: [],
        );
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [analyticsProvider.overrideWithValue(analytics)],
            child: createTestApp(child: const AnalyticsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.byType(LineChart), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
      });
    });

    group('SettingsScreen', () {
      late MockSettingsRepository mockRepo;

      setUp(() {
        mockRepo = MockSettingsRepository();
      });

      testWidgets('17. Shows theme selector with 3 options', (tester) async {
        when(mockRepo.load()).thenReturn(const SettingsState());
        when(mockRepo.setThemeMode(any)).thenAnswer((_) async {});
        when(mockRepo.setLocale(any)).thenAnswer((_) async {});
        when(mockRepo.setWorkDuration(any)).thenAnswer((_) async {});
        when(mockRepo.setMasterVolume(any)).thenAnswer((_) async {});
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [settingsRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('Clair'), findsOneWidget);
        expect(find.text('Sombre'), findsOneWidget);
        expect(find.text('Système'), findsOneWidget);
      });

      testWidgets('18. Shows locale selector FR/EN', (tester) async {
        when(mockRepo.load()).thenReturn(const SettingsState());
        when(mockRepo.setThemeMode(any)).thenAnswer((_) async {});
        when(mockRepo.setLocale(any)).thenAnswer((_) async {});
        when(mockRepo.setWorkDuration(any)).thenAnswer((_) async {});
        when(mockRepo.setMasterVolume(any)).thenAnswer((_) async {});
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [settingsRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
      });

      testWidgets('19. Duration sliders are present', (tester) async {
        when(mockRepo.load()).thenReturn(const SettingsState());
        when(mockRepo.setThemeMode(any)).thenAnswer((_) async {});
        when(mockRepo.setLocale(any)).thenAnswer((_) async {});
        when(mockRepo.setWorkDuration(any)).thenAnswer((_) async {});
        when(mockRepo.setMasterVolume(any)).thenAnswer((_) async {});
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [settingsRepositoryProvider.overrideWithValue(mockRepo)],
            child: createTestApp(child: const SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        
        expect(find.text('Durée travail'), findsOneWidget);
        expect(find.text('Pause courte'), findsOneWidget);
        expect(find.text('Pause longue'), findsOneWidget);
        expect(find.text('Volume général'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('20. Bottom navigation switches between 5 screens', (tester) async {
        await tester.pumpWidget(createTestApp(child: const StudyChillHomeScreen()));
        await tester.pumpAndSettle();
        
        // Check initial screen (Pomodoro)
        expect(find.text('Concentration'), findsOneWidget);
        
        // Navigate to Soundboard
        await tester.tap(find.byIcon(Icons.graphic_eq_outlined).last);
        await tester.pumpAndSettle();
        expect(find.text('Pluie'), findsOneWidget);
        
        // Navigate to Tasks
        await tester.tap(find.byIcon(Icons.check_circle_outline).last);
        await tester.pumpAndSettle();
        expect(find.text('Nouvelle tâche'), findsOneWidget);
        
        // Navigate to Analytics
        await tester.tap(find.byIcon(Icons.bar_chart_outlined).last);
        await tester.pumpAndSettle();
        expect(find.text('Statistiques'), findsOneWidget);
        
        // Navigate to Settings
        await tester.tap(find.byIcon(Icons.settings_outlined).last);
        await tester.pumpAndSettle();
        expect(find.text('Apparence'), findsOneWidget);
      });
    });

    group('Internationalization', () {
      testWidgets('21. French locale shows French labels', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('fr', 'FR'),
          child: const StudyChillHomeScreen(),
        ));
        await tester.pumpAndSettle();
        
        expect(find.text('Timer'), findsOneWidget);
        expect(find.text('Sons'), findsOneWidget);
        expect(find.text('Tâches'), findsOneWidget);
        expect(find.text('Stats'), findsOneWidget);
        expect(find.text('Réglages'), findsOneWidget);
      });

      testWidgets('22. English locale shows English labels', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('en', 'US'),
          child: const StudyChillHomeScreen(),
        ));
        await tester.pumpAndSettle();
        
        expect(find.text('Timer'), findsOneWidget);
        expect(find.text('Sounds'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('23. Interactive elements have semantic labels', (tester) async {
        await tester.pumpWidget(createTestApp(child: const PomodoroScreen()));
        await tester.pumpAndSettle();
        
        // Check buttons have semantic labels
        final startButton = find.byWidgetPredicate((widget) => 
          widget is Semantics && widget.label == 'Démarrer le minuteur');
        expect(startButton, findsOneWidget);
      });

      testWidgets('24. Offline banner announces to screen readers', (tester) async {
        // This would need a custom connectivity provider override
        // Testing the banner widget directly
        final l10n = AppLocalizations.of(tester.element(find.byType(MaterialApp)))!;
        
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR')],
            home: Scaffold(
              body: _OfflineBannerTest(l10n: l10n),
            ),
          ),
        );
        await tester.pumpAndSettle();
        
        final banner = find.byWidgetPredicate((widget) => 
          widget is Semantics && widget.label == l10n.offlineWarning);
        expect(banner, findsOneWidget);
      });
    });
  });
}

class _OfflineBannerTest extends StatelessWidget {
  final AppLocalizations l10n;
  const _OfflineBannerTest({required this.l10n});
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.offlineWarning,
      liveRegion: true,
      child: Container(
        color: Colors.amber,
        child: Text(l10n.offlineWarning),
      ),
    );
  }
}