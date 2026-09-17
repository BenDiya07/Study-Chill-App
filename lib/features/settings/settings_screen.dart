import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: settingsAsync.when(
          data: (settings) => _SettingsContent(settings: settings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final SettingsState settings;

  const _SettingsContent({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(settingsRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Apparence',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ThemeSelector(
              current: settings.themeMode,
              onChanged: (mode) async {
                await repo.setThemeMode(mode);
                ref.invalidate(settingsProvider);
              }),
          const SizedBox(height: 24),
          Text('Langue',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _LocaleSelector(
              current: settings.locale,
              onChanged: (locale) async {
                await repo.setLocale(locale.languageCode);
                ref.invalidate(settingsProvider);
              }),
          const SizedBox(height: 24),
          Text('Minuteur Pomodoro',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _DurationSetting(
            label: 'Durée travail',
            value: settings.workDuration,
            onChanged: (v) async {
              await repo.setWorkDuration(v);
              ref.invalidate(settingsProvider);
            },
          ),
          const SizedBox(height: 12),
          _DurationSetting(
            label: 'Pause courte',
            value: settings.shortBreakDuration,
            onChanged: (v) async {
              await repo.save(settings.copyWith(shortBreakDuration: v));
              ref.invalidate(settingsProvider);
            },
          ),
          const SizedBox(height: 12),
          _DurationSetting(
            label: 'Pause longue',
            value: settings.longBreakDuration,
            onChanged: (v) async {
              await repo.save(settings.copyWith(longBreakDuration: v));
              ref.invalidate(settingsProvider);
            },
          ),
          const SizedBox(height: 24),
          Text('Audio',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _VolumeSetting(
            label: 'Volume général',
            value: settings.masterVolume,
            onChanged: (v) async {
              await repo.setMasterVolume(v);
              ref.invalidate(settingsProvider);
            },
          ),
          const SizedBox(height: 24),
          Text('À propos',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Study Chill',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              subtitle:
                  Text('Version 1.0.0', style: GoogleFonts.plusJakartaSans()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.current,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('theme_selector'),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Clair'),
            value: ThemeMode.light,
            groupValue: current,
            onChanged: (v) => onChanged(v!),
            semanticLabel: 'Thème clair',
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sombre'),
            value: ThemeMode.dark,
            groupValue: current,
            onChanged: (v) => onChanged(v!),
            semanticLabel: 'Thème sombre',
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Système'),
            value: ThemeMode.system,
            groupValue: current,
            onChanged: (v) => onChanged(v!),
            semanticLabel: 'Thème système',
          ),
        ],
      ),
    );
  }
}

class _LocaleSelector extends StatelessWidget {
  final Locale current;
  final ValueChanged<Locale> onChanged;

  const _LocaleSelector({
    required this.current,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('locale_selector'),
      child: Column(
        children: [
          RadioListTile<Locale>(
            title: Row(
              children: [
                const Text('🇫🇷 '),
                Text('Français', style: GoogleFonts.plusJakartaSans()),
              ],
            ),
            value: const Locale('fr', 'FR'),
            groupValue: current,
            onChanged: (v) => onChanged(v!),
            semanticLabel: 'Français',
          ),
          RadioListTile<Locale>(
            title: Row(
              children: [
                const Text('🇺🇸 '),
                Text('English', style: GoogleFonts.plusJakartaSans()),
              ],
            ),
            value: const Locale('en', 'US'),
            groupValue: current,
            onChanged: (v) => onChanged(v!),
            semanticLabel: 'English',
          ),
        ],
      ),
    );
  }
}
  }
}

class _DurationSetting extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _DurationSetting({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(label),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                onChanged: (v) => onChanged(v.round()),
                min: 1,
                max: 60,
                divisions: 59,
                label: '$value min',
              ),
            ),
            Text('$value min',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _VolumeSetting extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSetting({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(label),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.volume_up,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                    divisions: 20,
                    label: '${(value * 100).round()}%',
                  ),
                ),
                Text('${(value * 100).round()}%',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
