import React from 'react';
import { WifiOff, Wifi, AlertTriangle } from 'lucide-react';
import { translations } from '../i18n';
import { Language } from '../types';

interface OfflineBannerProps {
  isOffline: boolean;
  language: Language;
  onDismiss?: () => void;
}

export const OfflineBanner: React.FC<OfflineBannerProps> = ({ isOffline, language }) => {
  const t = translations[language];

  if (!isOffline) return null;

  return (
    <div
      id="offline-banner-alert"
      role="alert"
      aria-live="assertive"
      className="bg-amber-950/80 border-b border-amber-600/40 px-4 py-2.5 text-amber-200 text-sm flex items-center justify-between gap-3 shadow-md backdrop-blur-md transition-all duration-300"
    >
      <div className="flex items-center gap-2.5 max-w-4xl mx-auto w-full">
        <div className="p-1 rounded bg-amber-500/20 text-amber-400 shrink-0">
          <WifiOff className="w-4 h-4 animate-pulse" />
        </div>
        <p className="text-xs md:text-sm font-medium tracking-wide">
          <span className="font-bold mr-1">[{t.offlineBadge}]</span>
          {t.offlineAlert}
        </p>
      </div>
    </div>
  );
};
