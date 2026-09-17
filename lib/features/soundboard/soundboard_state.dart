import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/constants/app_constants.dart';

class AudioChannel {
  final String id;
  final String label;
  final String assetPath;
  final String iconName;
  bool isPlaying;
  double volume;

  AudioChannel({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.iconName,
    this.isPlaying = false,
    this.volume = 0.5,
  });

  AudioChannel copyWith({
    bool? isPlaying,
    double? volume,
  }) {
    return AudioChannel(
      id: id,
      label: label,
      assetPath: assetPath,
      iconName: iconName,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}

class AudioMixerState {
  final Map<String, AudioChannel> channels;
  final double masterVolume;
  final bool isMasterMuted;

  const AudioMixerState({
    required this.channels,
    this.masterVolume = 0.8,
    this.isMasterMuted = false,
  });

  double getEffectiveVolume(String channelId) {
    final ch = channels[channelId];
    if (ch == null || !ch.isPlaying || isMasterMuted) return 0;
    return ch.volume * masterVolume;
  }

  AudioMixerState copyWith({
    Map<String, AudioChannel>? channels,
    double? masterVolume,
    bool? isMasterMuted,
  }) {
    return AudioMixerState(
      channels: channels ?? this.channels,
      masterVolume: masterVolume ?? this.masterVolume,
      isMasterMuted: isMasterMuted ?? this.isMasterMuted,
    );
  }
}

class AudioMixerNotifier extends StateNotifier<AudioMixerState> {
  AudioMixerNotifier() : super(AudioMixerState(channels: _defaultChannels()));

  static Map<String, AudioChannel> _defaultChannels() {
    return {
      kAudioRain: AudioChannel(
        id: kAudioRain,
        label: 'Pluie',
        assetPath: 'assets/audio/rain.mp3',
        iconName: 'cloud_rain',
      ),
      kAudioCoffee: AudioChannel(
        id: kAudioCoffee,
        label: 'Café',
        assetPath: 'assets/audio/coffee_shop.mp3',
        iconName: 'coffee',
      ),
      kAudioWhiteNoise: AudioChannel(
        id: kAudioWhiteNoise,
        label: 'Bruit blanc',
        assetPath: 'assets/audio/white_noise.mp3',
        iconName: 'volume_mute',
      ),
      kAudioCampfire: AudioChannel(
        id: kAudioCampfire,
        label: 'Feu de camp',
        assetPath: 'assets/audio/campfire.mp3',
        iconName: 'local_fire_department',
      ),
      kAudioForest: AudioChannel(
        id: kAudioForest,
        label: 'Forêt',
        assetPath: 'assets/audio/forest.mp3',
        iconName: 'forest',
      ),
      kAudioOcean: AudioChannel(
        id: kAudioOcean,
        label: 'Océan',
        assetPath: 'assets/audio/ocean.mp3',
        iconName: 'waves',
      ),
    };
  }

  void toggleChannel(String id) {
    final channel = state.channels[id];
    if (channel == null) return;

    state = state.copyWith(
      channels: {
        ...state.channels,
        id: channel.copyWith(isPlaying: !channel.isPlaying),
      },
    );
  }

  void setChannelVolume(String id, double volume) {
    final channel = state.channels[id];
    if (channel == null) return;

    state = state.copyWith(
      channels: {
        ...state.channels,
        id: channel.copyWith(volume: volume.clamp(0.0, 1.0)),
      },
    );
  }

  void setMasterVolume(double volume) {
    state = state.copyWith(masterVolume: volume.clamp(0.0, 1.0));
  }

  void toggleMasterMute() {
    state = state.copyWith(isMasterMuted: !state.isMasterMuted);
  }

  void stopAll() {
    final updated = <String, AudioChannel>{};
    for (final entry in state.channels.entries) {
      updated[entry.key] = entry.value.copyWith(isPlaying: false);
    }
    state = state.copyWith(channels: updated);
  }

  void loadPreset(String preset) {
    final updated = <String, AudioChannel>{};
    for (final entry in state.channels.entries) {
      final enabled = switch (preset) {
        'focus' => entry.key == kAudioWhiteNoise || entry.key == kAudioRain,
        'relax' => entry.key == kAudioForest || entry.key == kAudioOcean,
        'cozy' => entry.key == kAudioCoffee || entry.key == kAudioCampfire,
        _ => false,
      };
      updated[entry.key] = entry.value.copyWith(
        isPlaying: enabled,
        volume: enabled ? (preset == 'focus' ? 0.4 : 0.5) : null,
      );
    }
    state = state.copyWith(channels: updated);
  }
}

final audioMixerProvider =
    StateNotifierProvider<AudioMixerNotifier, AudioMixerState>((ref) {
  return AudioMixerNotifier();
});

final masterVolumeProvider = Provider<double>((ref) {
  return ref.watch(audioMixerProvider.select((s) => s.masterVolume));
});

final masterMutedProvider = Provider<bool>((ref) {
  return ref.watch(audioMixerProvider.select((s) => s.isMasterMuted));
});

final channelProviders = <String, Provider<AudioChannel>>{
  for (final id in kAudioChannels)
    id: Provider<AudioChannel>((ref) {
      return ref.watch(audioMixerProvider.select((s) => s.channels[id]!));
    }),
};
