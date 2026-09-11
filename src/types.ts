export type Language = 'fr' | 'en';

export type PomodoroMode = 'work' | 'shortBreak' | 'longBreak';

export type TaskPriority = 'urgent' | 'medium' | 'chill';

export type TaskCategory = 'study' | 'code' | 'reading' | 'project' | 'other';

export interface Task {
  id: string;
  title: string;
  isCompleted: boolean;
  estimatedPomodoros: number;
  completedPomodoros: number;
  priority: TaskPriority;
  category: TaskCategory;
  createdAt: number;
}

export interface SoundChannel {
  id: string;
  nameKey: string;
  icon: string;
  isPlaying: boolean;
  volume: number; // 0.0 to 1.0
  color: string;
}

export interface FocusSession {
  id: string;
  timestamp: number;
  durationMinutes: number;
  mode: PomodoroMode;
  taskId?: string;
  taskTitle?: string;
  category?: TaskCategory;
}

export interface AppSettings {
  language: Language;
  theme: 'dark' | 'light';
  workDurationMinutes: number;
  shortBreakDurationMinutes: number;
  longBreakDurationMinutes: number;
  autoStartBreaks: boolean;
  soundAlerts: boolean;
  masterVolume: number;
  simulateOffline: boolean;
  dailyGoalMinutes: number;
  userName: string;
}

export type TestType = 'unit' | 'widget' | 'integration';

export interface TestCase {
  id: string;
  type: TestType;
  title: string;
  description: string;
  targetComponent: string;
  status: 'idle' | 'running' | 'passed' | 'failed';
  executionTimeMs?: number;
  assertionsCount: number;
  assertionsPassed: number;
  logs: string[];
}
