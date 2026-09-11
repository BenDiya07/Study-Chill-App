import React from 'react';
import { Timer, Headphones, CheckSquare, BarChart3, Settings, ShieldCheck, Moon, Sun, Globe } from 'lucide-react';
import { Language } from '../types';
import { translations } from '../i18n';

interface NavbarProps {
  activeScreen: string;
  setActiveScreen: (screen: string) => void;
  language: Language;
  setLanguage: (lang: Language) => void;
  theme: 'dark' | 'light';
  toggleTheme: () => void;
  isOffline: boolean;
  activeSoundCount: number;
}

export const Navbar: React.FC<NavbarProps> = ({
  activeScreen,
  setActiveScreen,
  language,
  setLanguage,
  theme,
  toggleTheme,
  isOffline,
  activeSoundCount,
}) => {
  const t = translations[language];

  const navItems = [
    { id: 'pomodoro', label: t.screen1, icon: Timer },
    { id: 'soundboard', label: t.screen2, icon: Headphones, badge: activeSoundCount > 0 ? activeSoundCount : undefined },
    { id: 'tasks', label: t.screen3, icon: CheckSquare },
    { id: 'analytics', label: t.screen4, icon: BarChart3 },
    { id: 'settings', label: t.screen5, icon: Settings },
    { id: 'tests', label: t.screenTests, icon: ShieldCheck, highlight: true },
  ];

  return (
    <header className="sticky top-0 z-40 border-b border-stone-800 bg-stone-900/90 backdrop-blur-md transition-colors duration-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 flex items-center justify-between h-16">
        {/* Logo & Brand */}
        <div 
          onClick={() => setActiveScreen('pomodoro')} 
          className="flex items-center gap-3 cursor-pointer group"
          role="button"
          tabIndex={0}
          aria-label="Study Chill Home"
        >
          <div className="w-9 h-9 rounded-xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-center text-amber-400 group-hover:bg-amber-500/20 group-hover:scale-105 transition-all">
            <span className="text-lg">🍅</span>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-bold text-base tracking-tight text-stone-100 group-hover:text-amber-300 transition-colors">
                Study Chill
              </span>
              <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                Flutter 3.x
              </span>
            </div>
            <p className="text-[11px] text-stone-400 font-normal hidden sm:block">
              {t.appSubtitle}
            </p>
          </div>
        </div>

        {/* Navigation Items (Desktop & Tablet) */}
        <nav className="hidden md:flex items-center gap-1 bg-stone-950/40 p-1 rounded-xl border border-stone-800/80" aria-label="Main Navigation">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeScreen === item.id;
            return (
              <button
                key={item.id}
                id={`nav-btn-${item.id}`}
                onClick={() => setActiveScreen(item.id)}
                className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all relative ${
                  isActive
                    ? item.highlight
                      ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 shadow-sm'
                      : 'bg-amber-500 text-stone-950 font-bold shadow-sm shadow-amber-500/20'
                    : item.highlight
                    ? 'text-emerald-400 hover:bg-emerald-500/10'
                    : 'text-stone-300 hover:text-stone-100 hover:bg-stone-800/60'
                }`}
                aria-current={isActive ? 'page' : undefined}
              >
                <Icon className="w-4 h-4 shrink-0" />
                <span>{item.label}</span>
                {item.badge !== undefined && (
                  <span className="ml-0.5 px-1.5 py-0.2 rounded-full text-[10px] font-extrabold bg-amber-400 text-stone-950 animate-pulse">
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Global Controls: Language, Theme, Offline Indicator */}
        <div className="flex items-center gap-2">
          {/* Language Switcher */}
          <button
            id="btn-toggle-language"
            onClick={() => setLanguage(language === 'fr' ? 'en' : 'fr')}
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-stone-800/80 hover:bg-stone-700/80 text-stone-200 border border-stone-700/60 transition-colors"
            title={language === 'fr' ? 'Switch to English' : 'Passer en Français'}
            aria-label={`Language selector current: ${language.toUpperCase()}`}
          >
            <Globe className="w-3.5 h-3.5 text-amber-400" />
            <span className="font-bold">{language.toUpperCase()}</span>
          </button>

          {/* Theme Switcher */}
          <button
            id="btn-toggle-theme"
            onClick={toggleTheme}
            className="p-2 rounded-lg text-stone-300 hover:text-stone-100 bg-stone-800/80 hover:bg-stone-700/80 border border-stone-700/60 transition-colors"
            title={theme === 'dark' ? 'Mode Clair' : 'Mode Sombre'}
            aria-label="Toggle visual theme"
          >
            {theme === 'dark' ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-stone-300" />}
          </button>
        </div>
      </div>

      {/* Mobile Bottom Navigation Bar (Matching Flutter BottomNavigationBar) */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-stone-950/95 border-t border-stone-800 backdrop-blur-xl px-2 py-1.5 flex justify-around items-center">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeScreen === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveScreen(item.id)}
              className={`flex flex-col items-center justify-center p-1.5 rounded-lg text-[10px] font-medium transition-all ${
                isActive
                  ? item.highlight
                    ? 'text-emerald-400 font-bold'
                    : 'text-amber-400 font-bold'
                  : 'text-stone-400 hover:text-stone-200'
              }`}
            >
              <div className="relative">
                <Icon className="w-5 h-5" />
                {item.badge !== undefined && (
                  <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-amber-400" />
                )}
              </div>
              <span className="mt-0.5 truncate max-w-[56px]">{item.label}</span>
            </button>
          );
        })}
      </div>
    </header>
  );
};
