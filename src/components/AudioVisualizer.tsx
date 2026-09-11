import React from 'react';

interface AudioVisualizerProps {
  isPlaying: boolean;
  intensity?: number;
}

export const AudioVisualizer: React.FC<AudioVisualizerProps> = ({ isPlaying, intensity = 0.7 }) => {
  const bars = [16, 24, 40, 20, 36, 48, 28, 52, 32, 18, 44, 22];

  return (
    <div className="flex items-end justify-center gap-1 h-8 px-2" aria-hidden="true">
      {bars.map((height, i) => (
        <div
          key={i}
          className="w-1 rounded-full transition-all duration-300 bg-gradient-to-t from-amber-500 to-amber-300"
          style={{
            height: isPlaying ? `${Math.max(4, height * intensity * (0.4 + 0.6 * Math.sin(i + Date.now() / 300)))}px` : '4px',
            opacity: isPlaying ? 0.85 : 0.25,
            animation: isPlaying ? `pulse ${0.6 + (i % 4) * 0.2}s ease-in-out infinite alternate` : 'none',
          }}
        />
      ))}
    </div>
  );
};
