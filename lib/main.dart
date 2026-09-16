import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/network/connectivity.dart';
import 'features/pomodoro/pomodoro_recorder.dart';
import 'features/pomodoro/pomodoro_screen.dart';
import 'features/soundboard/soundboard_screen.dart';
import 'features/tasks/task_model.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/analytics/analytics_state.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_state.dart';
import 'features/settings/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(SessionRecordAdapter());
  Hive.registerAdapter(TimerModeAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());

  final taskRepo = TaskRepository();
  await taskRepo.init();

  final sessionRepo = SessionRepository();
  await sessionRepo.init();

  final settingsRepo = SettingsRepository();
  await settingsRepo.init();

  runApp(ProviderScope(
    overrides: [
      taskRepositoryProvider.overrideWithValue(taskRepo),
      sessionRepositoryProvider.overrideWithValue(sessionRepo),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
    ],
    child: const StudyChillApp(),
  ));
}

class StudyChillApp extends ConsumerWidget {
  const StudyChillApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isOnline = ref.watch(isOnlineProvider);
    ref.watch(pomodoroRecorderProvider);

    return MaterialApp(
      title: 'Study Chill',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: locale,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (!isOnline) const _OfflineBanner(),
          ],
        );
      },
      home: const StudyChillHomeScreen(),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custom = CustomColors.of(theme);
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.offlineWarning,
      liveRegion: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: custom.offlineBannerBg,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 18, color: custom.offlineBannerText),
                const SizedBox(width: 8),
                Text(
                  l10n.offlineWarning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: custom.offlineBannerText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudyChillHomeScreen extends ConsumerStatefulWidget {
  const StudyChillHomeScreen({super.key});

  @override
  ConsumerState<StudyChillHomeScreen> createState() =>
      _StudyChillHomeScreenState();
}

class _StudyChillHomeScreenState extends ConsumerState<StudyChillHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    PomodoroScreen(),
    SoundboardScreen(),
    TasksScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.pomodoro,
            tooltip: l10n.pomodoro,
          ),
          NavigationDestination(
            icon: const Icon(Icons.graphic_eq_outlined),
            selectedIcon: const Icon(Icons.graphic_eq),
            label: l10n.soundboard,
            tooltip: l10n.soundboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: l10n.tasks,
            tooltip: l10n.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.analytics,
            tooltip: l10n.analytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ],
      ),
    );
  }
}
