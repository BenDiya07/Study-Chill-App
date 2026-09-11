import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final double masterVolume;

  const SettingsState({
    this.locale = const Locale('fr', 'FR'),
    this.themeMode = ThemeMode.system,
    this.workDuration = kDefaultWorkDuration ~/ 60,
    this.shortBreakDuration = kDefaultShortBreakDuration ~/ 60,
    this.longBreakDuration = kDefaultLongBreakDuration ~/ 60,
    this.masterVolume = 0.8,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    double? masterVolume,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      masterVolume: masterVolume ?? this.masterVolume,
    );
  }
}

class SettingsRepository {
  static const String _keyLocale = kPrefLocale;
  static const String _keyThemeMode = kPrefThemeMode;
  static const String _keyWorkDuration = kPrefWorkDuration;
  static const String _keyShortBreakDuration = kPrefShortBreakDuration;
  static const String _keyLongBreakDuration = kPrefLongBreakDuration;
  static const String _keyMasterVolume = kPrefMasterVolume;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SettingsState load() {
    final localeCode = _prefs.getString(_keyLocale) ?? 'fr';
    final themeModeIndex = _prefs.getInt(_keyThemeMode) ?? 2;
    return SettingsState(
      locale: Locale(localeCode, localeCode == 'fr' ? 'FR' : 'US'),
      themeMode: ThemeMode.values[themeModeIndex],
      workDuration: _prefs.getInt(_keyWorkDuration) ?? (kDefaultWorkDuration ~/ 60),
      shortBreakDuration: _prefs.getInt(_keyShortBreakDuration) ?? (kDefaultShortBreakDuration ~/ 60),
      longBreakDuration: _prefs.getInt(_keyLongBreakDuration) ?? (kDefaultLongBreakDuration ~/ 60),
      masterVolume: _prefs.getDouble(_keyMasterVolume) ?? 0.8,
    );
  }

  Future<void> save(SettingsState state) async {
    await _prefs.setString(_keyLocale, state.locale.languageCode);
    await _prefs.setInt(_keyThemeMode, state.themeMode.index);
    await _prefs.setInt(_keyWorkDuration, state.workDuration);
    await _prefs.setInt(_keyShortBreakDuration, state.shortBreakDuration);
    await _prefs.setInt(_keyLongBreakDuration, state.longBreakDuration);
    await _prefs.setDouble(_keyMasterVolume, state.masterVolume);
  }

  Future<void> setLocale(String languageCode) async {
    await _prefs.setString(_keyLocale, languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setWorkDuration(int minutes) async {
    await _prefs.setInt(_keyWorkDuration, minutes);
  }

  Future<void> setMasterVolume(double volume) async {
    await _prefs.setDouble(_keyMasterVolume, volume);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository());

final settingsProvider = FutureProvider<SettingsState>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  await repo.init();
  return repo.load();
});

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(settingsProvider).when(
    data: (s) => s.locale,
    loading: () => const Locale('fr', 'FR'),
    error: (_, __) => const Locale('fr', 'FR'),
  );
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).when(
    data: (s) => s.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});