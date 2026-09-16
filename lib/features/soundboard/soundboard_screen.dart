import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import 'soundboard_state.dart';

class SoundboardScreen extends ConsumerWidget {
  const SoundboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioMixerProvider);
    final notifier = ref.read(audioMixerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _MasterVolumeControl(
              volume: state.masterVolume,
              isMuted: state.isMasterMuted,
              onVolumeChanged: notifier.setMasterVolume,
              onMuteToggle: notifier.toggleMasterMute,
            ),
            const SizedBox(height: 16),
            _PresetButtons(onPresetSelected: notifier.loadPreset),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    for (var index = 0;
                        index < kAudioChannels.length;
                        index++) ...[
                      if (index > 0) const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final channelId = kAudioChannels[index];
                          final channel = state.channels[channelId]!;
                          return _ChannelSlider(
                            channel: channel,
                            effectiveVolume:
                                state.getEffectiveVolume(channelId),
                            onToggle: () => notifier.toggleChannel(channelId),
                            onVolumeChanged: (v) =>
                                notifier.setChannelVolume(channelId, v),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StopAllButton(onPressed: notifier.stopAll),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MasterVolumeControl extends StatelessWidget {
  final double volume;
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggle;

  const _MasterVolumeControl({
    required this.volume,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isMuted
          ? 'Volume général muet'
          : 'Volume général: ${(volume * 100).round()}%',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: onMuteToggle,
                tooltip: isMuted ? 'Activer le son' : 'Couper le son',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: onVolumeChanged,
                  divisions: 20,
                  label: '${(volume * 100).round()}%',
                ),
              ),
              Text(
                '${(volume * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButtons extends StatelessWidget {
  final void Function(String) onPresetSelected;

  const _PresetButtons({required this.onPresetSelected});

  @override
  Widget build(BuildContext context) {
    final presets = [
      ('Focus', 'focus', Icons.center_focus_strong),
      ('Relax', 'relax', Icons.spa),
      ('Cozy', 'cozy', Icons.local_fire_department),
      ('Stop', 'stop', Icons.stop),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, preset, icon) = presets[index];
          return Semantics(
            label: 'Preset $label',
            button: true,
            child: OutlinedButton.icon(
              icon: Icon(icon, size: 18),
              label: Text(label,
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500)),
              onPressed: () => onPresetSelected(preset),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChannelSlider extends StatelessWidget {
  final AudioChannel channel;
  final double effectiveVolume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  const _ChannelSlider({
    required this.channel,
    required this.effectiveVolume,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  IconData _getIcon(String name) {
    return switch (name) {
      'cloud_rain' => Icons.cloud,
      'coffee' => Icons.coffee,
      'volume_mute' => Icons.graphic_eq,
      'local_fire_department' => Icons.local_fire_department,
      'forest' => Icons.forest,
      'waves' => Icons.waves,
      _ => Icons.music_note,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          '${channel.label}, ${channel.isPlaying ? "actif" : "inactif"}, volume ${(effectiveVolume * 100).round()}%',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getIcon(channel.iconName),
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      channel.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      channel.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color:
                          channel.isPlaying ? theme.colorScheme.primary : null,
                    ),
                    onPressed: onToggle,
                    tooltip: channel.isPlaying ? 'Pause' : 'Lecture',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    effectiveVolume > 0 ? Icons.volume_up : Icons.volume_off,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: channel.volume,
                      onChanged: onVolumeChanged,
                      divisions: 20,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(channel.volume * 100).round()}%',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              if (effectiveVolume > 0) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: effectiveVolume,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StopAllButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StopAllButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Arrêter tous les sons',
      button: true,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.stop_circle, size: 20),
        label: Text(
          'Tout arrêter',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
