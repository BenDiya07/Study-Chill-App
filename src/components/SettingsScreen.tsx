import React, { useState } from 'react';
import { Settings, Globe, Moon, Sun, Bell, WifiOff, User, Save, RotateCcw, Volume2, Check } from 'lucide-react';
import { Language, AppSettings } from '../types';
import { translations } from '../i18n';
import { soundEngine } from '../audio/soundEngine';

interface SettingsScreenProps {
  language: Language;
  setLanguage: (lang: Language) => void;
  settings: AppSettings;
  setSettings: React.Dispatch<React.SetStateAction<AppSettings>>;
  theme: 'dark' | 'light';
  setTheme: (theme: 'dark' | 'light') => void;
}

export const SettingsScreen: React.FC<SettingsScreenProps> = ({
  language,
  setLanguage,
  settings,
  setSettings,
  theme,
  setTheme,
}) => {
  const t = translations[language];

  const [formState, setFormState] = useState<AppSettings>({ ...settings });
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleTestChime = () => {
    soundEngine.playFinishChime();
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();

    // Validation matching Widget Test #5
    if (formState.workDurationMinutes < 1 || formState.workDurationMinutes > 60) {
      setErrorMessage(language === 'fr' ? 'Entrez une durée valide entre 1 et 60 min' : 'Enter a valid duration between 1 and 60 min');
      return;
    }

    setErrorMessage(null);
    setSettings(formState);
    setLanguage(formState.language);
    setTheme(formState.theme);

    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 3000);
  };

  const handleResetDefaults = () => {
    const defaults: AppSettings = {
      language: 'fr',
      theme: 'dark',
      workDurationMinutes: 25,
      shortBreakDurationMinutes: 5,
      longBreakDurationMinutes: 15,
      autoStartBreaks: false,
      soundAlerts: true,
      masterVolume: 0.8,
      simulateOffline: false,
      dailyGoalMinutes: 120,
      userName: 'Étudiant Flutter',
    };
    setFormState(defaults);
    setSettings(defaults);
    setLanguage('fr');
    setTheme('dark');
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-extrabold text-stone-100 tracking-tight">
          {t.settingsTitle}
        </h1>
        <p className="text-sm text-stone-400 mt-1">
          {t.settingsSubtitle}
        </p>
      </div>

      {saveSuccess && (
        <div className="mb-6 p-4 rounded-xl bg-emerald-950/60 border border-emerald-500/50 text-emerald-300 flex items-center gap-3 text-sm font-semibold animate-in fade-in">
          <Check className="w-5 h-5 text-emerald-400 shrink-0" />
          <span>{t.savedSuccess}</span>
        </div>
      )}

      {errorMessage && (
        <div className="mb-6 p-4 rounded-xl bg-rose-950/60 border border-rose-500/50 text-rose-300 flex items-center gap-3 text-sm font-semibold animate-in fade-in">
          <span>{errorMessage}</span>
        </div>
      )}

      <form id="settings_form" onSubmit={handleSave} className="space-y-6">
        {/* Section 1: Internationalization & Theme */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2 mb-4">
            <Globe className="w-4 h-4 text-amber-400" />
            <span>{t.languageLabel} & {t.themeLabel}</span>
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Language Selector */}
            <div>
              <label htmlFor="settings_language_select" className="block text-xs font-semibold text-stone-300 mb-2">
                {t.languageLabel}
              </label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  id="btn-lang-fr"
                  onClick={() => setFormState({ ...formState, language: 'fr' })}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold border transition-all flex items-center justify-center gap-2 ${
                    formState.language === 'fr'
                      ? 'bg-amber-500 text-stone-950 border-amber-500 shadow-sm'
                      : 'bg-stone-900 text-stone-300 border-stone-700 hover:border-stone-600'
                  }`}
                >
                  <span>🇫🇷 Français (FR)</span>
                </button>
                <button
                  type="button"
                  id="btn-lang-en"
                  onClick={() => setFormState({ ...formState, language: 'en' })}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold border transition-all flex items-center justify-center gap-2 ${
                    formState.language === 'en'
                      ? 'bg-amber-500 text-stone-950 border-amber-500 shadow-sm'
                      : 'bg-stone-900 text-stone-300 border-stone-700 hover:border-stone-600'
                  }`}
                >
                  <span>🇬🇧 English (EN)</span>
                </button>
              </div>
            </div>

            {/* Theme Selector */}
            <div>
              <label className="block text-xs font-semibold text-stone-300 mb-2">
                {t.themeLabel}
              </label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => setFormState({ ...formState, theme: 'dark' })}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold border transition-all flex items-center justify-center gap-2 ${
                    formState.theme === 'dark'
                      ? 'bg-amber-500 text-stone-950 border-amber-500 shadow-sm'
                      : 'bg-stone-900 text-stone-300 border-stone-700 hover:border-stone-600'
                  }`}
                >
                  <Moon className="w-4 h-4" />
                  <span>{language === 'fr' ? 'Sombre' : 'Dark'}</span>
                </button>
                <button
                  type="button"
                  onClick={() => setFormState({ ...formState, theme: 'light' })}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold border transition-all flex items-center justify-center gap-2 ${
                    formState.theme === 'light'
                      ? 'bg-amber-500 text-stone-950 border-amber-500 shadow-sm'
                      : 'bg-stone-900 text-stone-300 border-stone-700 hover:border-stone-600'
                  }`}
                >
                  <Sun className="w-4 h-4" />
                  <span>{language === 'fr' ? 'Clair' : 'Light'}</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Section 2: Durations (Matching SettingsFormWidget) */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2 mb-4">
            <Settings className="w-4 h-4 text-amber-400" />
            <span>{t.durationsSection}</span>
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {/* Work Duration */}
            <div>
              <label htmlFor="work_duration_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.workDuration}
              </label>
              <input
                id="work_duration_input"
                type="number"
                min="1"
                max="60"
                value={formState.workDurationMinutes}
                onChange={(e) => setFormState({ ...formState, workDurationMinutes: parseInt(e.target.value) || 25 })}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 font-mono text-sm focus:outline-none focus:border-amber-500"
              />
              <span className="text-[10px] text-stone-400 mt-1 block">1 à 60 minutes</span>
            </div>

            {/* Short Break */}
            <div>
              <label htmlFor="short_break_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.shortBreakDuration}
              </label>
              <input
                id="short_break_input"
                type="number"
                min="1"
                max="30"
                value={formState.shortBreakDurationMinutes}
                onChange={(e) => setFormState({ ...formState, shortBreakDurationMinutes: parseInt(e.target.value) || 5 })}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 font-mono text-sm focus:outline-none focus:border-amber-500"
              />
              <span className="text-[10px] text-stone-400 mt-1 block">1 à 30 minutes</span>
            </div>

            {/* Long Break */}
            <div>
              <label htmlFor="long_break_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.longBreakDuration}
              </label>
              <input
                id="long_break_input"
                type="number"
                min="5"
                max="60"
                value={formState.longBreakDurationMinutes}
                onChange={(e) => setFormState({ ...formState, longBreakDurationMinutes: parseInt(e.target.value) || 15 })}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 font-mono text-sm focus:outline-none focus:border-amber-500"
              />
              <span className="text-[10px] text-stone-400 mt-1 block">5 à 60 minutes</span>
            </div>
          </div>
        </div>

        {/* Section 3: Audio & Alerts */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2">
                <Bell className="w-4 h-4 text-amber-400" />
                <span>{t.soundFeedback}</span>
              </h2>
              <p className="text-xs text-stone-400 mt-0.5">{t.soundFeedbackDesc}</p>
            </div>

            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={handleTestChime}
                className="px-3 py-1.5 rounded-lg text-xs font-semibold bg-stone-800 hover:bg-stone-700 text-amber-400 flex items-center gap-1.5 border border-stone-700"
              >
                <Volume2 className="w-3.5 h-3.5" />
                <span>{t.testChimeBtn}</span>
              </button>
              <input
                type="checkbox"
                checked={formState.soundAlerts}
                onChange={(e) => setFormState({ ...formState, soundAlerts: e.target.checked })}
                className="w-5 h-5 accent-amber-500 rounded cursor-pointer"
              />
            </div>
          </div>

          <div className="pt-3 border-t border-stone-800/60 flex items-center justify-between">
            <div>
              <span className="text-xs font-semibold text-stone-200">{t.autoStartBreaks}</span>
            </div>
            <input
              type="checkbox"
              checked={formState.autoStartBreaks}
              onChange={(e) => setFormState({ ...formState, autoStartBreaks: e.target.checked })}
              className="w-5 h-5 accent-amber-500 rounded cursor-pointer"
            />
          </div>
        </div>

        {/* Section 4: Offline Mode Simulator (Resilience Testing) */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-amber-500/20 backdrop-blur-sm flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h2 className="text-sm font-bold text-amber-400 flex items-center gap-2">
              <WifiOff className="w-4 h-4" />
              <span>{t.offlineSimulation}</span>
            </h2>
            <p className="text-xs text-stone-400 mt-0.5">{t.offlineSimulationDesc}</p>
          </div>

          <label className="relative inline-flex items-center cursor-pointer">
            <input
              id="toggle-offline-simulation"
              type="checkbox"
              checked={formState.simulateOffline}
              onChange={(e) => setFormState({ ...formState, simulateOffline: e.target.checked })}
              className="sr-only peer"
            />
            <div className="w-11 h-6 bg-stone-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-stone-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
          </label>
        </div>

        {/* Section 5: Profile & Daily Target */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2 mb-4">
            <User className="w-4 h-4 text-amber-400" />
            <span>{t.userProfileSection}</span>
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label htmlFor="user_name_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.studentName}
              </label>
              <input
                id="user_name_input"
                type="text"
                value={formState.userName}
                onChange={(e) => setFormState({ ...formState, userName: e.target.value })}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 text-sm focus:outline-none focus:border-amber-500"
              />
            </div>
            <div>
              <label htmlFor="daily_goal_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.dailyGoal}
              </label>
              <input
                id="daily_goal_input"
                type="number"
                min="30"
                max="600"
                step="15"
                value={formState.dailyGoalMinutes}
                onChange={(e) => setFormState({ ...formState, dailyGoalMinutes: parseInt(e.target.value) || 120 })}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 font-mono text-sm focus:outline-none focus:border-amber-500"
              />
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center justify-between gap-4 pt-4">
          <button
            type="button"
            onClick={handleResetDefaults}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-semibold text-stone-400 hover:text-stone-200 hover:bg-stone-800 transition-colors"
          >
            <RotateCcw className="w-4 h-4" />
            <span>{t.resetDefaults}</span>
          </button>

          <button
            id="save_settings_button"
            type="submit"
            className="flex items-center gap-2 px-6 py-3 rounded-xl text-xs sm:text-sm font-bold bg-amber-500 hover:bg-amber-400 text-stone-950 shadow-md shadow-amber-500/20 transition-all"
          >
            <Save className="w-4 h-4" />
            <span>{t.saveSettings}</span>
          </button>
        </div>
      </form>
    </div>
  );
};
