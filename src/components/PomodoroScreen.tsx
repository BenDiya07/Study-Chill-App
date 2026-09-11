import React, { useEffect, useState } from 'react';
import { Play, Pause, RotateCcw, SkipForward, Plus, Minus, CheckCircle2, Flame, Award, ArrowRight } from 'lucide-react';
import confetti from 'canvas-confetti';
import { Language, PomodoroMode, Task, AppSettings } from '../types';
import { translations } from '../i18n';
import { soundEngine } from '../audio/soundEngine';

interface PomodoroScreenProps {
  language: Language;
  settings: AppSettings;
  activeTask: Task | null;
  setActiveTask: (task: Task | null) => void;
  onSessionComplete: (durationMinutes: number, mode: PomodoroMode, task?: Task | null) => void;
  onNavigateToTasks: () => void;
  todaySessionsCount: number;
}

export const PomodoroScreen: React.FC<PomodoroScreenProps> = ({
  language,
  settings,
  activeTask,
  onSessionComplete,
  onNavigateToTasks,
  todaySessionsCount,
}) => {
  const t = translations[language];

  const [mode, setMode] = useState<PomodoroMode>('work');
  const [isRunning, setIsRunning] = useState<boolean>(false);
  const [cycleIndex, setCycleIndex] = useState<number>(1);

  // Determine current mode total duration in seconds
  const getTotalSecondsForMode = (m: PomodoroMode) => {
    switch (m) {
      case 'work':
        return settings.workDurationMinutes * 60;
      case 'shortBreak':
        return settings.shortBreakDurationMinutes * 60;
      case 'longBreak':
        return settings.longBreakDurationMinutes * 60;
    }
  };

  const [secondsRemaining, setSecondsRemaining] = useState<number>(() => getTotalSecondsForMode('work'));

  // Update secondsRemaining when settings duration change and timer is paused at max
  useEffect(() => {
    if (!isRunning) {
      setSecondsRemaining(getTotalSecondsForMode(mode));
    }
  }, [settings.workDurationMinutes, settings.shortBreakDurationMinutes, settings.longBreakDurationMinutes, mode]);

  // Reactive high-precision timer loop
  useEffect(() => {
    let interval: ReturnType<typeof setInterval> | null = null;

    if (isRunning) {
      interval = setInterval(() => {
        setSecondsRemaining((prev) => {
          if (prev <= 1) {
            // Timer completed!
            handleTimerComplete();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRunning, mode, activeTask, cycleIndex]);

  const handleTimerComplete = () => {
    setIsRunning(false);

    // Audio chime
    if (settings.soundAlerts) {
      soundEngine.playFinishChime();
    }

    // Confetti on work completion!
    if (mode === 'work') {
      confetti({
        particleCount: 65,
        spread: 70,
        origin: { y: 0.65 },
        colors: ['#f59e0b', '#10b981', '#38bdf8'],
      });
    }

    const durationDone = getTotalSecondsForMode(mode) / 60;
    onSessionComplete(durationDone, mode, activeTask);

    // Transition to next mode
    if (mode === 'work') {
      const nextCycle = cycleIndex + 1;
      setCycleIndex(nextCycle);
      // Every 4 cycles -> Long Break, otherwise Short Break
      const nextMode = nextCycle % 4 === 1 ? 'longBreak' : 'shortBreak';
      setMode(nextMode);
      setSecondsRemaining(getTotalSecondsForMode(nextMode));
      if (settings.autoStartBreaks) {
        setIsRunning(true);
      }
    } else {
      setMode('work');
      setSecondsRemaining(getTotalSecondsForMode('work'));
    }
  };

  const toggleTimer = () => {
    setIsRunning((prev) => !prev);
  };

  const resetTimer = () => {
    setIsRunning(false);
    setSecondsRemaining(getTotalSecondsForMode(mode));
  };

  const switchMode = (newMode: PomodoroMode) => {
    setIsRunning(false);
    setMode(newMode);
    setSecondsRemaining(getTotalSecondsForMode(newMode));
  };

  const adjustTime = (deltaSeconds: number) => {
    setSecondsRemaining((prev) => Math.max(10, prev + deltaSeconds));
  };

  // Circular progress calculations
  const totalSeconds = getTotalSecondsForMode(mode);
  const progressRatio = Math.max(0, Math.min(1, (totalSeconds - secondsRemaining) / totalSeconds));
  const strokeDashoffset = 754 - 754 * progressRatio; // 2 * PI * 120 ≈ 754

  const minutes = Math.floor(secondsRemaining / 60);
  const seconds = secondsRemaining % 60;
  const formattedTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

  const modeColors = {
    work: {
      accent: 'amber',
      bgClass: 'bg-amber-500/10 text-amber-400 border-amber-500/30',
      stroke: '#f59e0b',
      textAccent: 'text-amber-400',
    },
    shortBreak: {
      accent: 'emerald',
      bgClass: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30',
      stroke: '#10b981',
      textAccent: 'text-emerald-400',
    },
    longBreak: {
      accent: 'sky',
      bgClass: 'bg-sky-500/10 text-sky-400 border-sky-500/30',
      stroke: '#38bdf8',
      textAccent: 'text-sky-400',
    },
  }[mode];

  return (
    <div className="max-w-4xl mx-auto px-4 py-8 flex flex-col items-center justify-center min-h-[calc(100vh-8rem)]">
      {/* Mode Selector Tabs */}
      <div 
        role="tablist"
        aria-label="Pomodoro mode selector"
        className="flex items-center gap-2 p-1.5 rounded-2xl bg-stone-950/60 border border-stone-800/80 mb-8 backdrop-blur-sm"
      >
        <button
          id="mode-tab-work"
          role="tab"
          aria-selected={mode === 'work'}
          onClick={() => switchMode('work')}
          className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all ${
            mode === 'work'
              ? 'bg-amber-500 text-stone-950 shadow-md shadow-amber-500/20 scale-102'
              : 'text-stone-400 hover:text-stone-200'
          }`}
        >
          {t.workSession} ({settings.workDurationMinutes}m)
        </button>
        <button
          id="mode-tab-shortBreak"
          role="tab"
          aria-selected={mode === 'shortBreak'}
          onClick={() => switchMode('shortBreak')}
          className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all ${
            mode === 'shortBreak'
              ? 'bg-emerald-500 text-stone-950 shadow-md shadow-emerald-500/20 scale-102'
              : 'text-stone-400 hover:text-stone-200'
          }`}
        >
          {t.shortBreak} ({settings.shortBreakDurationMinutes}m)
        </button>
        <button
          id="mode-tab-longBreak"
          role="tab"
          aria-selected={mode === 'longBreak'}
          onClick={() => switchMode('longBreak')}
          className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-bold transition-all ${
            mode === 'longBreak'
              ? 'bg-sky-500 text-stone-950 shadow-md shadow-sky-500/20 scale-102'
              : 'text-stone-400 hover:text-stone-200'
          }`}
        >
          {t.longBreak} ({settings.longBreakDurationMinutes}m)
        </button>
      </div>

      {/* Main Circular Timer Display (60 FPS Reactive) */}
      <div className="relative flex items-center justify-center my-4 group">
        <svg className="w-72 h-72 sm:w-84 sm:h-84 -rotate-90 transform" viewBox="0 0 260 260">
          {/* Background Track Circle */}
          <circle
            cx="130"
            cy="130"
            r="120"
            className="stroke-stone-800/80 fill-stone-950/40"
            strokeWidth="10"
          />
          {/* Animated Glowing Progress Ring */}
          <circle
            cx="130"
            cy="130"
            r="120"
            stroke={modeColors.stroke}
            strokeWidth="10"
            strokeDasharray="754"
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            className="fill-transparent transition-[stroke-dashoffset] duration-1000 ease-linear"
            style={{ filter: `drop-shadow(0 0 8px ${modeColors.stroke}66)` }}
          />
        </svg>

        {/* Inner Content (Formatted Time & Status) */}
        <div className="absolute flex flex-col items-center justify-center text-center select-none">
          <span className="text-[11px] uppercase tracking-widest font-extrabold text-stone-400 mb-1">
            {t.cycleCount} #{cycleIndex} • {mode === 'work' ? t.workSession : t.shortBreak}
          </span>
          <div
            id="timer-display-text"
            role="timer"
            aria-live="polite"
            className="text-6xl sm:text-7xl font-mono font-extrabold tracking-tight text-stone-100 drop-shadow-sm"
          >
            {formattedTime}
          </div>
          <div className="flex items-center gap-1.5 mt-2">
            <span className={`inline-block w-2 h-2 rounded-full ${isRunning ? 'bg-emerald-400 animate-ping' : 'bg-stone-500'}`} />
            <span className="text-xs text-stone-400 font-medium">
              {isRunning ? (language === 'fr' ? 'Concentration active' : 'Flow in progress') : (language === 'fr' ? 'En pause' : 'Paused')}
            </span>
          </div>
        </div>
      </div>

      {/* Quick Time Adjustment Buttons (+/- 5 min) */}
      <div className="flex items-center gap-3 my-2">
        <button
          id="btn-adjust-sub5"
          onClick={() => adjustTime(-300)}
          className="px-3 py-1 rounded-lg text-xs font-semibold bg-stone-800/70 hover:bg-stone-700/80 text-stone-300 border border-stone-700/50 flex items-center gap-1 transition-all"
          aria-label={t.sub5Min}
        >
          <Minus className="w-3 h-3" />
          {t.sub5Min}
        </button>
        <button
          id="btn-adjust-add5"
          onClick={() => adjustTime(300)}
          className="px-3 py-1 rounded-lg text-xs font-semibold bg-stone-800/70 hover:bg-stone-700/80 text-stone-300 border border-stone-700/50 flex items-center gap-1 transition-all"
          aria-label={t.add5Min}
        >
          <Plus className="w-3 h-3" />
          {t.add5Min}
        </button>
      </div>

      {/* Primary Action Buttons: Start/Pause, Reset, Skip */}
      <div className="flex items-center gap-4 my-6">
        <button
          id="timer-reset-button"
          onClick={resetTimer}
          className="p-3.5 rounded-2xl bg-stone-800/80 hover:bg-stone-700 text-stone-300 border border-stone-700/70 shadow-sm transition-transform active:scale-95"
          title={t.resetTimer}
          aria-label={t.resetTimer}
        >
          <RotateCcw className="w-5 h-5" />
        </button>

        <button
          id="timer-toggle-button"
          onClick={toggleTimer}
          className={`flex items-center gap-3 px-8 py-4 rounded-2xl font-extrabold text-base transition-all transform active:scale-95 shadow-lg ${
            isRunning
              ? 'bg-amber-600 hover:bg-amber-500 text-stone-950 shadow-amber-600/30'
              : 'bg-amber-500 hover:bg-amber-400 text-stone-950 shadow-amber-500/40 scale-105'
          }`}
          aria-label={isRunning ? t.pauseTimer : t.startTimer}
        >
          {isRunning ? <Pause className="w-6 h-6 fill-current" /> : <Play className="w-6 h-6 fill-current ml-0.5" />}
          <span>{isRunning ? t.pauseTimer : t.startTimer}</span>
        </button>

        <button
          id="timer-skip-button"
          onClick={handleTimerComplete}
          className="p-3.5 rounded-2xl bg-stone-800/80 hover:bg-stone-700 text-stone-300 border border-stone-700/70 shadow-sm transition-transform active:scale-95"
          title={t.skipStep}
          aria-label={t.skipStep}
        >
          <SkipForward className="w-5 h-5" />
        </button>
      </div>

      {/* Active Task Link Section */}
      <div className="w-full max-w-md bg-stone-950/50 border border-stone-800/90 rounded-2xl p-4 mt-2 backdrop-blur-sm flex items-center justify-between gap-3">
        <div className="flex items-center gap-3 overflow-hidden">
          <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20 shrink-0">
            <CheckCircle2 className="w-4 h-4" />
          </div>
          <div className="truncate">
            <div className="text-[11px] uppercase font-bold tracking-wider text-stone-400">
              {t.currentFocus}
            </div>
            <div className="text-sm font-semibold text-stone-200 truncate">
              {activeTask ? activeTask.title : t.noLinkedTask}
            </div>
          </div>
        </div>

        <button
          id="btn-link-task"
          onClick={onNavigateToTasks}
          className="shrink-0 flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold text-amber-400 hover:text-amber-300 hover:bg-amber-500/10 transition-colors"
        >
          <span>{activeTask ? (language === 'fr' ? 'Changer' : 'Switch') : (language === 'fr' ? 'Choisir' : 'Select')}</span>
          <ArrowRight className="w-3.5 h-3.5" />
        </button>
      </div>

      {/* Quick Stats Footnote (Completed today & Streak) */}
      <div className="flex items-center justify-center gap-6 mt-6 text-xs text-stone-400">
        <div className="flex items-center gap-1.5">
          <Award className="w-4 h-4 text-amber-400" />
          <span>{todaySessionsCount} {t.completedToday}</span>
        </div>
        <div className="flex items-center gap-1.5">
          <Flame className="w-4 h-4 text-orange-500 animate-pulse" />
          <span>5 {t.days} {t.consecutiveStreak}</span>
        </div>
      </div>
    </div>
  );
};
