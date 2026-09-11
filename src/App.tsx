import React, { useState, useEffect } from 'react';
import { Navbar } from './components/Navbar';
import { OfflineBanner } from './components/OfflineBanner';
import { PomodoroScreen } from './components/PomodoroScreen';
import { SoundboardScreen } from './components/SoundboardScreen';
import { TasksScreen } from './components/TasksScreen';
import { AnalyticsScreen } from './components/AnalyticsScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { TestSuiteScreen } from './components/TestSuiteScreen';
import { Language, Task, SoundChannel, FocusSession, AppSettings, PomodoroMode } from './types';
import { soundEngine } from './audio/soundEngine';

export default function App() {
  // 1. Settings state
  const [settings, setSettings] = useState<AppSettings>(() => {
    const saved = localStorage.getItem('study_chill_settings');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // Fallback
      }
    }
    return {
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
  });

  const language = settings.language;
  const setLanguage = (newLang: Language) => {
    setSettings((prev) => ({ ...prev, language: newLang }));
  };

  const theme = settings.theme;
  const toggleTheme = () => {
    setSettings((prev) => ({
      ...prev,
      theme: prev.theme === 'dark' ? 'light' : 'dark',
    }));
  };

  // Sync settings to localStorage
  useEffect(() => {
    localStorage.setItem('study_chill_settings', JSON.stringify(settings));
    soundEngine.setMasterVolume(settings.masterVolume);
  }, [settings]);

  // 2. Active Screen state ('pomodoro' | 'soundboard' | 'tasks' | 'analytics' | 'settings' | 'tests')
  const [activeScreen, setActiveScreen] = useState<string>('pomodoro');

  // 3. Sound Channels state
  const [channels, setChannels] = useState<SoundChannel[]>([
    { id: 'rain', nameKey: 'rain', icon: 'rain', isPlaying: false, volume: 0.65, color: '#38bdf8' },
    { id: 'coffee', nameKey: 'coffee', icon: 'coffee', isPlaying: false, volume: 0.45, color: '#f59e0b' },
    { id: 'white_noise', nameKey: 'whiteNoise', icon: 'white_noise', isPlaying: false, volume: 0.5, color: '#a8a29e' },
    { id: 'campfire', nameKey: 'campfire', icon: 'campfire', isPlaying: false, volume: 0.4, color: '#f97316' },
    { id: 'forest', nameKey: 'forest', icon: 'forest', isPlaying: false, volume: 0.6, color: '#10b981' },
    { id: 'ocean', nameKey: 'ocean', icon: 'ocean', isPlaying: false, volume: 0.7, color: '#0ea5e9' },
  ]);

  // 4. Tasks state (with persistent storage)
  const [tasks, setTasks] = useState<Task[]>(() => {
    const saved = localStorage.getItem('study_chill_tasks');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // Fallback
      }
    }
    return [
      {
        id: 'task_default_1',
        title: 'Valider la suite de 18 tests Flutter (100/100)',
        isCompleted: true,
        estimatedPomodoros: 4,
        completedPomodoros: 4,
        priority: 'urgent',
        category: 'code',
        createdAt: Date.now() - 3600000 * 5,
      },
      {
        id: 'task_default_2',
        title: 'Optimisation 60 FPS & flutter analyze clean',
        isCompleted: false,
        estimatedPomodoros: 3,
        completedPomodoros: 2,
        priority: 'urgent',
        category: 'code',
        createdAt: Date.now() - 3600000 * 3,
      },
      {
        id: 'task_default_3',
        title: 'Révision Architecture BLoC / Riverpod',
        isCompleted: false,
        estimatedPomodoros: 2,
        completedPomodoros: 1,
        priority: 'medium',
        category: 'study',
        createdAt: Date.now() - 3600000 * 2,
      },
      {
        id: 'task_default_4',
        title: 'Lecture des spécifications i18n FR / EN',
        isCompleted: false,
        estimatedPomodoros: 2,
        completedPomodoros: 0,
        priority: 'chill',
        category: 'reading',
        createdAt: Date.now() - 3600000,
      },
    ];
  });

  useEffect(() => {
    localStorage.setItem('study_chill_tasks', JSON.stringify(tasks));
  }, [tasks]);

  // 5. Active Task linked to Pomodoro
  const [activeTaskId, setActiveTaskId] = useState<string | null>('task_default_2');
  const activeTask = tasks.find((t) => t.id === activeTaskId) || null;

  const setActiveTask = (t: Task | null) => {
    setActiveTaskId(t ? t.id : null);
  };

  // 6. Focus Sessions state (for analytics)
  const [sessions, setSessions] = useState<FocusSession[]>(() => {
    const saved = localStorage.getItem('study_chill_sessions');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // Fallback
      }
    }
    const now = Date.now();
    return [
      { id: 'sess_1', timestamp: now - 86400000 * 2, durationMinutes: 25, mode: 'work', category: 'code', taskTitle: 'Mise en place Riverpod' },
      { id: 'sess_2', timestamp: now - 86400000 * 2, durationMinutes: 25, mode: 'work', category: 'code', taskTitle: 'Tests unitaires timer' },
      { id: 'sess_3', timestamp: now - 86400000 * 1, durationMinutes: 25, mode: 'work', category: 'study', taskTitle: 'Rédaction documentation' },
      { id: 'sess_4', timestamp: now - 86400000 * 1, durationMinutes: 25, mode: 'work', category: 'code', taskTitle: 'Pipeline CI/CD GitHub' },
      { id: 'sess_5', timestamp: now - 3600000 * 3, durationMinutes: 25, mode: 'work', category: 'code', taskTitle: 'Tests widgets OfflineBanner' },
      { id: 'sess_6', timestamp: now - 3600000 * 1, durationMinutes: 25, mode: 'work', category: 'reading', taskTitle: 'Revue de code flutter analyze' },
    ];
  });

  useEffect(() => {
    localStorage.setItem('study_chill_sessions', JSON.stringify(sessions));
  }, [sessions]);

  // 7. Network / Offline monitoring
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const isOffline = !isOnline || settings.simulateOffline;

  // Session completion handler
  const handleSessionComplete = (durationMinutes: number, mode: PomodoroMode, task?: Task | null) => {
    const newSession: FocusSession = {
      id: `session_${Date.now()}`,
      timestamp: Date.now(),
      durationMinutes,
      mode,
      taskId: task?.id,
      taskTitle: task?.title,
      category: task?.category || 'study',
    };

    setSessions((prev) => [...prev, newSession]);

    // If work mode and linked task, increment task pomodoro
    if (mode === 'work' && task) {
      setTasks((prev) =>
        prev.map((t) => {
          if (t.id === task.id) {
            return { ...t, completedPomodoros: t.completedPomodoros + 1 };
          }
          return t;
        })
      );
    }
  };

  const handleSelectAndStart = (task: Task) => {
    setActiveTask(task);
    setActiveScreen('pomodoro');
  };

  const todayStart = new Date().setHours(0, 0, 0, 0);
  const todaySessionsCount = sessions.filter((s) => s.timestamp >= todayStart && s.mode === 'work').length;
  const activeSoundCount = channels.filter((c) => c.isPlaying).length;

  return (
    <div
      className={`min-h-screen transition-colors duration-300 ${
        theme === 'dark'
          ? 'bg-stone-900 text-stone-100'
          : 'bg-stone-100 text-stone-900'
      }`}
    >
      {/* Offline Alert Banner */}
      <OfflineBanner isOffline={isOffline} language={language} />

      {/* Main Top Navigation Header */}
      <Navbar
        activeScreen={activeScreen}
        setActiveScreen={setActiveScreen}
        language={language}
        setLanguage={setLanguage}
        theme={theme}
        toggleTheme={toggleTheme}
        isOffline={isOffline}
        activeSoundCount={activeSoundCount}
      />

      {/* Main Content Area (Indexed Screen Rendering) */}
      <main className="pb-20 md:pb-12">
        {activeScreen === 'pomodoro' && (
          <PomodoroScreen
            language={language}
            settings={settings}
            activeTask={activeTask}
            setActiveTask={setActiveTask}
            onSessionComplete={handleSessionComplete}
            onNavigateToTasks={() => setActiveScreen('tasks')}
            todaySessionsCount={todaySessionsCount}
          />
        )}

        {activeScreen === 'soundboard' && (
          <SoundboardScreen
            language={language}
            channels={channels}
            setChannels={setChannels}
            masterVolume={settings.masterVolume}
            setMasterVolume={(vol) => setSettings((s) => ({ ...s, masterVolume: vol }))}
          />
        )}

        {activeScreen === 'tasks' && (
          <TasksScreen
            language={language}
            tasks={tasks}
            setTasks={setTasks}
            activeTask={activeTask}
            setActiveTask={setActiveTask}
            onSelectAndStart={handleSelectAndStart}
          />
        )}

        {activeScreen === 'analytics' && (
          <AnalyticsScreen
            language={language}
            sessions={sessions}
            settings={settings}
          />
        )}

        {activeScreen === 'settings' && (
          <SettingsScreen
            language={language}
            setLanguage={setLanguage}
            settings={settings}
            setSettings={setSettings}
            theme={theme}
            setTheme={(th) => setSettings((s) => ({ ...s, theme: th }))}
          />
        )}

        {activeScreen === 'tests' && (
          <TestSuiteScreen language={language} />
        )}
      </main>
    </div>
  );
}
