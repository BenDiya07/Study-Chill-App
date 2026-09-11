import React from 'react';
import { Volume2, VolumeX, CloudRain, Coffee, Wind, Flame, Trees, Waves, Sparkles } from 'lucide-react';
import { Language, SoundChannel } from '../types';
import { translations } from '../i18n';
import { soundEngine } from '../audio/soundEngine';
import { AudioVisualizer } from './AudioVisualizer';

interface SoundboardScreenProps {
  language: Language;
  channels: SoundChannel[];
  setChannels: React.Dispatch<React.SetStateAction<SoundChannel[]>>;
  masterVolume: number;
  setMasterVolume: (vol: number) => void;
}

export const SoundboardScreen: React.FC<SoundboardScreenProps> = ({
  language,
  channels,
  setChannels,
  masterVolume,
  setMasterVolume,
}) => {
  const t = translations[language];

  const activeCount = channels.filter((c) => c.isPlaying).length;

  const handleToggleChannel = (id: string) => {
    setChannels((prev) =>
      prev.map((ch) => {
        if (ch.id === id) {
          const nextPlaying = !ch.isPlaying;
          if (nextPlaying) {
            soundEngine.startChannel(ch.id, ch.volume);
          } else {
            soundEngine.stopChannel(ch.id);
          }
          return { ...ch, isPlaying: nextPlaying };
        }
        return ch;
      })
    );
  };

  const handleChannelVolume = (id: string, newVol: number) => {
    setChannels((prev) =>
      prev.map((ch) => {
        if (ch.id === id) {
          soundEngine.setChannelVolume(id, newVol);
          return { ...ch, volume: newVol };
        }
        return ch;
      })
    );
  };

  const handleMasterVolumeChange = (newVol: number) => {
    setMasterVolume(newVol);
    soundEngine.setMasterVolume(newVol);
  };

  const toggleMuteAll = () => {
    if (activeCount > 0) {
      // Mute all
      channels.forEach((c) => {
        if (c.isPlaying) soundEngine.stopChannel(c.id);
      });
      setChannels((prev) => prev.map((c) => ({ ...c, isPlaying: false })));
    } else {
      // Unmute preset (Rain + Coffee)
      setChannels((prev) =>
        prev.map((c) => {
          if (c.id === 'rain' || c.id === 'coffee') {
            soundEngine.startChannel(c.id, c.volume);
            return { ...c, isPlaying: true };
          }
          return c;
        })
      );
    }
  };

  const applyPreset = (presetName: string) => {
    // Stop all current sounds first
    channels.forEach((c) => soundEngine.stopChannel(c.id));

    setChannels((prev) =>
      prev.map((ch) => {
        let shouldPlay = false;
        let targetVol = ch.volume;

        if (presetName === 'rainy') {
          if (ch.id === 'rain') { shouldPlay = true; targetVol = 0.7; }
          if (ch.id === 'coffee') { shouldPlay = true; targetVol = 0.45; }
        } else if (presetName === 'deep') {
          if (ch.id === 'white_noise') { shouldPlay = true; targetVol = 0.65; }
          if (ch.id === 'rain') { shouldPlay = true; targetVol = 0.3; }
        } else if (presetName === 'zen') {
          if (ch.id === 'forest') { shouldPlay = true; targetVol = 0.75; }
          if (ch.id === 'campfire') { shouldPlay = true; targetVol = 0.25; }
        } else if (presetName === 'ocean') {
          if (ch.id === 'ocean') { shouldPlay = true; targetVol = 0.8; }
          if (ch.id === 'campfire') { shouldPlay = true; targetVol = 0.2; }
        }

        if (shouldPlay) {
          soundEngine.startChannel(ch.id, targetVol);
          return { ...ch, isPlaying: true, volume: targetVol };
        } else {
          return { ...ch, isPlaying: false };
        }
      })
    );
  };

  const getChannelIcon = (iconName: string) => {
    switch (iconName) {
      case 'rain': return CloudRain;
      case 'coffee': return Coffee;
      case 'white_noise': return Wind;
      case 'campfire': return Flame;
      case 'forest': return Trees;
      case 'ocean': return Waves;
      default: return Volume2;
    }
  };

  const getChannelName = (nameKey: string) => {
    const key = nameKey as keyof typeof t;
    return (t[key] as string) || nameKey;
  };

  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl sm:text-3xl font-extrabold text-stone-100 tracking-tight">
              {t.soundboardTitle}
            </h1>
            <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-amber-500/20 text-amber-300 border border-amber-500/30">
              {activeCount} {t.activeSounds}
            </span>
          </div>
          <p className="text-sm text-stone-400 mt-1">
            {t.soundboardSubtitle}
          </p>
        </div>

        {/* Audio Visualizer & Quick Mute */}
        <div className="flex items-center gap-4 bg-stone-950/60 border border-stone-800/80 p-3 rounded-2xl backdrop-blur-sm self-start md:self-auto">
          <AudioVisualizer isPlaying={activeCount > 0} intensity={masterVolume} />
          <button
            id="btn-mute-all"
            onClick={toggleMuteAll}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
              activeCount > 0
                ? 'bg-stone-800 text-stone-200 hover:bg-stone-700'
                : 'bg-amber-500 text-stone-950 hover:bg-amber-400'
            }`}
          >
            {activeCount > 0 ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
            <span>{activeCount > 0 ? t.muteAll : t.unmuteAll}</span>
          </button>
        </div>
      </div>

      {/* Master Volume Bar */}
      <div className="bg-stone-950/40 border border-stone-800/80 rounded-2xl p-5 mb-8">
        <div className="flex items-center justify-between gap-4 mb-2">
          <div className="flex items-center gap-2">
            <Volume2 className="w-5 h-5 text-amber-400" />
            <span className="text-sm font-bold text-stone-200">{t.masterVolume}</span>
          </div>
          <span className="text-xs font-mono font-bold text-amber-400">
            {Math.round(masterVolume * 100)}%
          </span>
        </div>
        <input
          id="slider-master-volume"
          type="range"
          min="0"
          max="1"
          step="0.01"
          value={masterVolume}
          onChange={(e) => handleMasterVolumeChange(parseFloat(e.target.value))}
          className="w-full h-2 bg-stone-800 rounded-lg appearance-none cursor-pointer accent-amber-500"
          aria-label={t.masterVolume}
        />
      </div>

      {/* Ambient Sound Presets */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-3">
          <Sparkles className="w-4 h-4 text-amber-400" />
          <h2 className="text-xs uppercase font-extrabold tracking-wider text-stone-400">
            {t.presets}
          </h2>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <button
            id="preset-rainy"
            onClick={() => applyPreset('rainy')}
            className="p-3 rounded-xl bg-stone-950/40 hover:bg-stone-800/60 border border-stone-800/80 text-left transition-all group"
          >
            <span className="text-base block mb-1">🌧️ ☕</span>
            <span className="text-xs font-bold text-stone-200 group-hover:text-amber-300">
              {t.presetRainyStudy}
            </span>
          </button>
          <button
            id="preset-deep"
            onClick={() => applyPreset('deep')}
            className="p-3 rounded-xl bg-stone-950/40 hover:bg-stone-800/60 border border-stone-800/80 text-left transition-all group"
          >
            <span className="text-base block mb-1">🎧 ⚡</span>
            <span className="text-xs font-bold text-stone-200 group-hover:text-amber-300">
              {t.presetDeepFocus}
            </span>
          </button>
          <button
            id="preset-zen"
            onClick={() => applyPreset('zen')}
            className="p-3 rounded-xl bg-stone-950/40 hover:bg-stone-800/60 border border-stone-800/80 text-left transition-all group"
          >
            <span className="text-base block mb-1">🌲 🔥</span>
            <span className="text-xs font-bold text-stone-200 group-hover:text-amber-300">
              {t.presetZenForest}
            </span>
          </button>
          <button
            id="preset-ocean"
            onClick={() => applyPreset('ocean')}
            className="p-3 rounded-xl bg-stone-950/40 hover:bg-stone-800/60 border border-stone-800/80 text-left transition-all group"
          >
            <span className="text-base block mb-1">🌊 🌙</span>
            <span className="text-xs font-bold text-stone-200 group-hover:text-amber-300">
              {t.presetNightOcean}
            </span>
          </button>
        </div>
      </div>

      {/* 6 Multi-Channel Sound Cards (Matching SoundSliderWidget from Widget Tests) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {channels.map((channel) => {
          const Icon = getChannelIcon(channel.icon);
          const channelName = getChannelName(channel.nameKey);

          return (
            <div
              key={channel.id}
              id={`sound-channel-card-${channel.id}`}
              className={`p-5 rounded-2xl border transition-all duration-200 flex flex-col justify-between ${
                channel.isPlaying
                  ? 'bg-stone-900/90 border-amber-500/50 shadow-lg shadow-amber-500/5'
                  : 'bg-stone-950/40 border-stone-800/70 hover:border-stone-700/70'
              }`}
            >
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center transition-colors ${
                      channel.isPlaying
                        ? 'bg-amber-500 text-stone-950 font-bold'
                        : 'bg-stone-800 text-stone-400'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-stone-100">
                      {channelName}
                    </h3>
                    <span className="text-[11px] text-stone-400">
                      {channel.isPlaying ? (language === 'fr' ? 'Actif' : 'Playing') : (language === 'fr' ? 'Silencieux' : 'Muted')}
                    </span>
                  </div>
                </div>

                {/* Toggle Button */}
                <button
                  id={`btn-toggle-sound-${channel.id}`}
                  onClick={() => handleToggleChannel(channel.id)}
                  className={`w-9 h-9 rounded-xl flex items-center justify-center transition-all ${
                    channel.isPlaying
                      ? 'bg-amber-500 text-stone-950 shadow-sm'
                      : 'bg-stone-800 hover:bg-stone-700 text-stone-300'
                  }`}
                  aria-label={`Toggle ${channelName}`}
                >
                  {channel.isPlaying ? <Volume2 className="w-4 h-4" /> : <VolumeX className="w-4 h-4" />}
                </button>
              </div>

              {/* Volume Slider */}
              <div className="mt-2">
                <div className="flex items-center justify-between text-[11px] font-mono font-medium text-stone-400 mb-1.5">
                  <span>Volume</span>
                  <span>{Math.round(channel.volume * 100)}%</span>
                </div>
                <input
                  id={`sound_slider_${channel.id}`}
                  type="range"
                  min="0"
                  max="1"
                  step="0.01"
                  value={channel.volume}
                  disabled={!channel.isPlaying}
                  onChange={(e) => handleChannelVolume(channel.id, parseFloat(e.target.value))}
                  className={`w-full h-2 rounded-lg appearance-none cursor-pointer transition-opacity ${
                    channel.isPlaying ? 'bg-stone-800 accent-amber-500 opacity-100' : 'bg-stone-900 opacity-40 cursor-not-allowed'
                  }`}
                  aria-label={`${channelName} volume`}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
