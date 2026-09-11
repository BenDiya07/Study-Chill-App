import React, { useState } from 'react';
import { Plus, Check, Trash2, Tag, Play, Search, Filter, AlertCircle, CheckCircle2 } from 'lucide-react';
import { Language, Task, TaskPriority, TaskCategory } from '../types';
import { translations } from '../i18n';

interface TasksScreenProps {
  language: Language;
  tasks: Task[];
  setTasks: React.Dispatch<React.SetStateAction<Task[]>>;
  activeTask: Task | null;
  setActiveTask: (task: Task | null) => void;
  onSelectAndStart: (task: Task) => void;
}

export const TasksScreen: React.FC<TasksScreenProps> = ({
  language,
  tasks,
  setTasks,
  activeTask,
  setActiveTask,
  onSelectAndStart,
}) => {
  const t = translations[language];

  // New task form state
  const [newTitle, setNewTitle] = useState('');
  const [newPriority, setNewPriority] = useState<TaskPriority>('medium');
  const [newCategory, setNewCategory] = useState<TaskCategory>('study');
  const [newEstimatedPomos, setNewEstimatedPomos] = useState<number>(3);
  const [isFormOpen, setIsFormOpen] = useState(false);

  // Filters
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'completed'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  const handleAddTask = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;

    const task: Task = {
      id: `task_${Date.now()}`,
      title: newTitle.trim(),
      isCompleted: false,
      estimatedPomodoros: newEstimatedPomos,
      completedPomodoros: 0,
      priority: newPriority,
      category: newCategory,
      createdAt: Date.now(),
    };

    setTasks((prev) => [task, ...prev]);
    setNewTitle('');
    setIsFormOpen(false);

    // If no active task, set this one
    if (!activeTask) {
      setActiveTask(task);
    }
  };

  const handleToggleTask = (id: string) => {
    setTasks((prev) =>
      prev.map((task) => {
        if (task.id === id) {
          const nextState = !task.isCompleted;
          // If completing the active task, clear active if needed or keep it
          return { ...task, isCompleted: nextState };
        }
        return task;
      })
    );
  };

  const handleIncrementPomodoro = (id: string) => {
    setTasks((prev) =>
      prev.map((task) => {
        if (task.id === id) {
          return { ...task, completedPomodoros: task.completedPomodoros + 1 };
        }
        return task;
      })
    );
  };

  const handleDeleteTask = (id: string) => {
    setTasks((prev) => prev.filter((t) => t.id !== id));
    if (activeTask && activeTask.id === id) {
      setActiveTask(null);
    }
  };

  const filteredTasks = tasks.filter((task) => {
    const matchesFilter =
      filterStatus === 'all'
        ? true
        : filterStatus === 'active'
        ? !task.isCompleted
        : task.isCompleted;
    const matchesSearch = task.title.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  const getPriorityBadge = (priority: TaskPriority) => {
    switch (priority) {
      case 'urgent':
        return (
          <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-rose-500/20 text-rose-300 border border-rose-500/30">
            {t.urgent}
          </span>
        );
      case 'medium':
        return (
          <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-500/20 text-amber-300 border border-amber-500/30">
            {t.medium}
          </span>
        );
      case 'chill':
        return (
          <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-teal-500/20 text-teal-300 border border-teal-500/30">
            {t.chill}
          </span>
        );
    }
  };

  const getCategoryLabel = (category: TaskCategory) => {
    switch (category) {
      case 'study': return t.study;
      case 'code': return t.code;
      case 'reading': return t.reading;
      case 'project': return t.project;
      default: return t.other;
    }
  };

  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-stone-100 tracking-tight">
            {t.tasksTitle}
          </h1>
          <p className="text-sm text-stone-400 mt-1">
            {t.tasksSubtitle}
          </p>
        </div>

        <button
          id="btn-open-new-task-form"
          onClick={() => setIsFormOpen(!isFormOpen)}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs sm:text-sm font-bold bg-amber-500 hover:bg-amber-400 text-stone-950 shadow-md shadow-amber-500/20 transition-all self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>{t.newTask}</span>
        </button>
      </div>

      {/* New Task Form (Expandable) */}
      {isFormOpen && (
        <form
          id="new-task-form"
          onSubmit={handleAddTask}
          className="mb-8 p-5 rounded-2xl bg-stone-950/60 border border-amber-500/40 shadow-xl backdrop-blur-md animate-in fade-in slide-in-from-top-4 duration-200"
        >
          <h3 className="text-sm font-bold text-amber-400 mb-3 flex items-center gap-2">
            <Plus className="w-4 h-4" />
            <span>{t.addTask}</span>
          </h3>

          <div className="space-y-4">
            <div>
              <label htmlFor="task_title_input" className="block text-xs font-semibold text-stone-300 mb-1">
                {t.taskTitlePlaceholder}
              </label>
              <input
                id="task_title_input"
                type="text"
                required
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                placeholder={t.taskTitlePlaceholder}
                className="w-full px-4 py-2.5 rounded-xl bg-stone-900 border border-stone-700 text-stone-100 text-sm focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {/* Priority */}
              <div>
                <label className="block text-xs font-semibold text-stone-300 mb-1">{t.priority}</label>
                <select
                  value={newPriority}
                  onChange={(e) => setNewPriority(e.target.value as TaskPriority)}
                  className="w-full px-3 py-2 rounded-xl bg-stone-900 border border-stone-700 text-stone-200 text-xs focus:outline-none focus:border-amber-500"
                >
                  <option value="urgent">{t.urgent}</option>
                  <option value="medium">{t.medium}</option>
                  <option value="chill">{t.chill}</option>
                </select>
              </div>

              {/* Category */}
              <div>
                <label className="block text-xs font-semibold text-stone-300 mb-1">{t.category}</label>
                <select
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value as TaskCategory)}
                  className="w-full px-3 py-2 rounded-xl bg-stone-900 border border-stone-700 text-stone-200 text-xs focus:outline-none focus:border-amber-500"
                >
                  <option value="study">{t.study}</option>
                  <option value="code">{t.code}</option>
                  <option value="reading">{t.reading}</option>
                  <option value="project">{t.project}</option>
                  <option value="other">{t.other}</option>
                </select>
              </div>

              {/* Estimated Pomodoros */}
              <div>
                <label className="block text-xs font-semibold text-stone-300 mb-1">{t.estimatedPomos}</label>
                <div className="flex items-center gap-2">
                  <input
                    type="range"
                    min="1"
                    max="8"
                    value={newEstimatedPomos}
                    onChange={(e) => setNewEstimatedPomos(parseInt(e.target.value))}
                    className="w-full h-2 bg-stone-800 rounded-lg appearance-none cursor-pointer accent-amber-500"
                  />
                  <span className="text-xs font-bold text-amber-400 font-mono w-8 text-right">
                    🍅 {newEstimatedPomos}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                type="button"
                onClick={() => setIsFormOpen(false)}
                className="px-4 py-2 rounded-xl text-xs font-semibold text-stone-400 hover:text-stone-200 hover:bg-stone-800"
              >
                Annuler
              </button>
              <button
                id="btn-submit-task"
                type="submit"
                className="px-5 py-2 rounded-xl text-xs font-bold bg-amber-500 hover:bg-amber-400 text-stone-950 shadow-sm"
              >
                {t.addTaskBtn}
              </button>
            </div>
          </div>
        </form>
      )}

      {/* Filters & Search Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 mb-6">
        <div className="flex items-center gap-1 bg-stone-950/40 p-1 rounded-xl border border-stone-800/80 w-full sm:w-auto">
          <button
            onClick={() => setFilterStatus('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filterStatus === 'all' ? 'bg-stone-800 text-stone-100' : 'text-stone-400 hover:text-stone-200'
            }`}
          >
            {t.filterAll} ({tasks.length})
          </button>
          <button
            onClick={() => setFilterStatus('active')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filterStatus === 'active' ? 'bg-stone-800 text-stone-100' : 'text-stone-400 hover:text-stone-200'
            }`}
          >
            {t.filterActive} ({tasks.filter((t) => !t.isCompleted).length})
          </button>
          <button
            onClick={() => setFilterStatus('completed')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filterStatus === 'completed' ? 'bg-stone-800 text-stone-100' : 'text-stone-400 hover:text-stone-200'
            }`}
          >
            {t.filterCompleted} ({tasks.filter((t) => t.isCompleted).length})
          </button>
        </div>

        {/* Search Input */}
        <div className="relative w-full sm:w-64">
          <Search className="w-4 h-4 text-stone-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder={t.searchTasks}
            className="w-full pl-9 pr-3 py-1.5 rounded-xl bg-stone-900/80 border border-stone-800 text-stone-200 text-xs focus:outline-none focus:border-amber-500"
          />
        </div>
      </div>

      {/* Task List (Matching TaskItemWidget) */}
      {filteredTasks.length === 0 ? (
        <div className="text-center py-16 bg-stone-950/30 rounded-2xl border border-stone-800/50">
          <AlertCircle className="w-8 h-8 text-stone-500 mx-auto mb-2" />
          <p className="text-sm text-stone-400 font-medium">{t.noTasksFound}</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredTasks.map((task) => {
            const isActive = activeTask?.id === task.id;

            return (
              <div
                key={task.id}
                id={`task-item-${task.id}`}
                className={`p-4 rounded-2xl border transition-all duration-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 ${
                  isActive
                    ? 'bg-amber-500/5 border-amber-500/40 shadow-sm'
                    : task.isCompleted
                    ? 'bg-stone-950/30 border-stone-800/40 opacity-70'
                    : 'bg-stone-900/60 border-stone-800/80 hover:border-stone-700/80'
                }`}
              >
                {/* Checkbox and Title */}
                <div className="flex items-center gap-3.5 flex-1 min-w-0">
                  <button
                    id={`task_checkbox_${task.id}`}
                    onClick={() => handleToggleTask(task.id)}
                    className={`w-5 h-5 rounded-md border flex items-center justify-center transition-colors shrink-0 ${
                      task.isCompleted
                        ? 'bg-emerald-500 border-emerald-500 text-stone-950'
                        : 'border-stone-600 hover:border-amber-400 bg-stone-900'
                    }`}
                    aria-label={`Mark task ${task.title} as ${task.isCompleted ? 'incomplete' : 'complete'}`}
                  >
                    {task.isCompleted && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                  </button>

                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap mb-1">
                      <span
                        id="task_title"
                        className={`text-sm font-semibold truncate ${
                          task.isCompleted ? 'line-through text-stone-400' : 'text-stone-100'
                        }`}
                      >
                        {task.title}
                      </span>
                      {isActive && (
                        <span className="px-2 py-0.5 rounded text-[10px] font-extrabold bg-amber-500 text-stone-950">
                          {t.activeFocusBadge}
                        </span>
                      )}
                    </div>

                    {/* Metadata tags */}
                    <div className="flex items-center gap-2 flex-wrap text-xs text-stone-400">
                      <span id="task_priority">{getPriorityBadge(task.priority)}</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-stone-800/80 text-stone-300">
                        {getCategoryLabel(task.category)}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Pomodoro Progress Counter & Actions */}
                <div className="flex items-center justify-between sm:justify-end gap-3 shrink-0 pt-2 sm:pt-0 border-t sm:border-t-0 border-stone-800/60">
                  {/* Pomodoro counter badge */}
                  <div
                    id="task_pomodoro_badge"
                    className="flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-stone-950/60 border border-stone-800"
                    title={`${task.completedPomodoros} pomodoros complétés sur ${task.estimatedPomodoros} estimés`}
                  >
                    <span className="text-xs">🍅</span>
                    <span className="text-xs font-mono font-bold text-amber-400">
                      {task.completedPomodoros} / {task.estimatedPomodoros}
                    </span>
                    <button
                      onClick={() => handleIncrementPomodoro(task.id)}
                      className="ml-1 w-4 h-4 rounded bg-stone-800 hover:bg-stone-700 text-stone-300 flex items-center justify-center text-[11px] font-bold"
                      title="Ajouter un Pomodoro"
                    >
                      +
                    </button>
                  </div>

                  {/* Set active focus button */}
                  {!isActive && !task.isCompleted && (
                    <button
                      onClick={() => onSelectAndStart(task)}
                      className="px-2.5 py-1 rounded-lg text-xs font-bold text-amber-400 hover:bg-amber-500/10 flex items-center gap-1 transition-colors"
                      title={t.setAsActive}
                    >
                      <Play className="w-3 h-3 fill-current" />
                      <span className="hidden md:inline">{t.setAsActive}</span>
                    </button>
                  )}

                  {/* Delete Task */}
                  <button
                    onClick={() => handleDeleteTask(task.id)}
                    className="p-1.5 rounded-lg text-stone-500 hover:text-rose-400 hover:bg-rose-500/10 transition-colors"
                    title="Supprimer la tâche"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
