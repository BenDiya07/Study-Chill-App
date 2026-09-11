import React from 'react';
import { Clock, CheckCircle, Flame, TrendingUp, Calendar, BookOpen, Layers } from 'lucide-react';
import { Language, FocusSession, AppSettings } from '../types';
import { translations } from '../i18n';

interface AnalyticsScreenProps {
  language: Language;
  sessions: FocusSession[];
  settings: AppSettings;
}

export const AnalyticsScreen: React.FC<AnalyticsScreenProps> = ({
  language,
  sessions,
  settings,
}) => {
  const t = translations[language];

  // Calculations
  const totalMinutes = sessions.reduce((acc, s) => acc + s.durationMinutes, 0);
  const totalHours = (totalMinutes / 60).toFixed(1);

  // Today's sessions
  const startOfToday = new Date().setHours(0, 0, 0, 0);
  const todaySessions = sessions.filter((s) => s.timestamp >= startOfToday);
  const todayMinutes = todaySessions.reduce((acc, s) => acc + s.durationMinutes, 0);
  const todayHours = (todayMinutes / 60).toFixed(1);

  const totalPomodorosCount = sessions.filter((s) => s.mode === 'work').length;

  // Daily target progress
  const targetProgress = Math.min(100, Math.round((todayMinutes / settings.dailyGoalMinutes) * 100));

  // Category breakdown calculation
  const categoryCounts: Record<string, number> = {};
  sessions.forEach((s) => {
    const cat = s.category || 'study';
    categoryCounts[cat] = (categoryCounts[cat] || 0) + s.durationMinutes;
  });

  const categoryEntries = Object.entries(categoryCounts);
  const categoryTotal = categoryEntries.reduce((acc, [, val]) => acc + val, 0) || 1;

  // Mock days of week bar chart data
  const daysOfWeek = language === 'fr' 
    ? ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
    : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const weeklyFocusMinutes = [120, 150, 95, 175, 140, 60, todayMinutes || 45];
  const maxDayMinutes = Math.max(...weeklyFocusMinutes, 180);

  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-extrabold text-stone-100 tracking-tight">
          {t.analyticsTitle}
        </h1>
        <p className="text-sm text-stone-400 mt-1">
          {t.analyticsSubtitle}
        </p>
      </div>

      {/* 4 Metric Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {/* Total Focus */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <div className="flex items-center justify-between text-stone-400 mb-2">
            <span className="text-xs font-semibold">{t.totalFocusHours}</span>
            <Clock className="w-4 h-4 text-amber-400" />
          </div>
          <div className="text-2xl sm:text-3xl font-extrabold font-mono text-stone-100">
            {totalHours}h
          </div>
          <div className="text-[11px] text-stone-400 mt-1">
            {totalMinutes} {t.minutes} au total
          </div>
        </div>

        {/* Today Focus */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <div className="flex items-center justify-between text-stone-400 mb-2">
            <span className="text-xs font-semibold">{t.todayFocusHours}</span>
            <Calendar className="w-4 h-4 text-emerald-400" />
          </div>
          <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-400">
            {todayMinutes}m
          </div>
          <div className="text-[11px] text-stone-400 mt-1">
            {targetProgress}% {t.dailyTargetAchieved}
          </div>
        </div>

        {/* Pomodoros Completed */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <div className="flex items-center justify-between text-stone-400 mb-2">
            <span className="text-xs font-semibold">{t.totalSessions}</span>
            <CheckCircle className="w-4 h-4 text-amber-400" />
          </div>
          <div className="text-2xl sm:text-3xl font-extrabold font-mono text-amber-400">
            {totalPomodorosCount} 🍅
          </div>
          <div className="text-[11px] text-stone-400 mt-1">
            96% {t.productivityScore}
          </div>
        </div>

        {/* Daily Streak */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 backdrop-blur-sm">
          <div className="flex items-center justify-between text-stone-400 mb-2">
            <span className="text-xs font-semibold">{t.consecutiveStreak}</span>
            <Flame className="w-4 h-4 text-orange-500" />
          </div>
          <div className="text-2xl sm:text-3xl font-extrabold font-mono text-orange-400">
            5 {t.days}
          </div>
          <div className="text-[11px] text-stone-400 mt-1">
            🔥 Série active
          </div>
        </div>
      </div>

      {/* Visual Charts: Weekly Bar Chart & Category Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Weekly Bar Chart */}
        <div className="lg:col-span-2 p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2">
              <TrendingUp className="w-4 h-4 text-amber-400" />
              <span>{t.weeklyChartTitle}</span>
            </h2>
            <span className="text-xs font-mono text-stone-400">Moyenne : 1.8h / jour</span>
          </div>

          <div className="h-44 flex items-end justify-between gap-2 sm:gap-4 pt-4 border-b border-stone-800/80 pb-2">
            {daysOfWeek.map((day, idx) => {
              const minutesVal = weeklyFocusMinutes[idx];
              const heightPercent = Math.max(8, (minutesVal / maxDayMinutes) * 100);
              const isToday = idx === daysOfWeek.length - 1;

              return (
                <div key={day} className="flex-1 flex flex-col items-center gap-2 group">
                  <span className="text-[10px] font-mono text-stone-400 opacity-0 group-hover:opacity-100 transition-opacity">
                    {minutesVal}m
                  </span>
                  <div className="w-full max-w-[36px] bg-stone-800/60 rounded-t-lg h-36 flex items-end justify-center p-1">
                    <div
                      className={`w-full rounded-t-md transition-all duration-500 ${
                        isToday
                          ? 'bg-gradient-to-t from-amber-500 to-amber-300 shadow-md shadow-amber-500/20'
                          : 'bg-stone-700 group-hover:bg-amber-500/60'
                      }`}
                      style={{ height: `${heightPercent}%` }}
                    />
                  </div>
                  <span className={`text-[11px] font-bold ${isToday ? 'text-amber-400' : 'text-stone-400'}`}>
                    {day}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Category Breakdown */}
        <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80 flex flex-col justify-between">
          <div>
            <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2 mb-4">
              <Layers className="w-4 h-4 text-amber-400" />
              <span>{t.categoryBreakdownTitle}</span>
            </h2>

            {/* Category Bars */}
            <div className="space-y-3">
              {[
                { name: t.study, color: 'bg-amber-500', share: 45 },
                { name: t.code, color: 'bg-emerald-500', share: 30 },
                { name: t.reading, color: 'bg-sky-500', share: 15 },
                { name: t.project, color: 'bg-purple-500', share: 10 },
              ].map((item) => (
                <div key={item.name}>
                  <div className="flex items-center justify-between text-xs mb-1">
                    <span className="text-stone-300 font-medium">{item.name}</span>
                    <span className="font-mono text-stone-400">{item.share}%</span>
                  </div>
                  <div className="w-full h-2 rounded-full bg-stone-800 overflow-hidden">
                    <div
                      className={`h-full rounded-full ${item.color}`}
                      style={{ width: `${item.share}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-stone-800/80 text-[11px] text-stone-400">
            Objectif journalier recommandé : 120 minutes de flow.
          </div>
        </div>
      </div>

      {/* Recent Sessions History */}
      <div className="p-5 rounded-2xl bg-stone-950/40 border border-stone-800/80">
        <h2 className="text-sm font-bold text-stone-200 flex items-center gap-2 mb-4">
          <Calendar className="w-4 h-4 text-amber-400" />
          <span>{t.sessionHistoryTitle}</span>
        </h2>

        {sessions.length === 0 ? (
          <p className="text-xs text-stone-400 italic py-4">{t.noHistoryYet}</p>
        ) : (
          <div className="divide-y divide-stone-800/60 max-h-60 overflow-y-auto">
            {sessions.slice(-8).reverse().map((session) => (
              <div key={session.id} className="py-2.5 flex items-center justify-between text-xs">
                <div className="flex items-center gap-3">
                  <span className="text-base">
                    {session.mode === 'work' ? '🍅' : '☕'}
                  </span>
                  <div>
                    <div className="font-semibold text-stone-200">
                      {session.taskTitle || (session.mode === 'work' ? t.workSession : t.shortBreak)}
                    </div>
                    <div className="text-[10px] text-stone-400">
                      {new Date(session.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} • {session.durationMinutes} min
                    </div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-500/10 text-amber-300 border border-amber-500/20">
                  + {session.durationMinutes}m
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
