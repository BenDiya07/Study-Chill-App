import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'task_model.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _CategoryFilter(
              categories: categories,
              selected: selectedCategory,
              onChanged: (cat) =>
                  ref.read(_selectedCategoryProvider.notifier).state = cat,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) => _TaskList(
                  tasks: tasks
                      .where((t) =>
                          selectedCategory == null ||
                          t.category == selectedCategory)
                      .toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
            _AddTaskButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allCategories = ['Tous', ...categories];

    return Semantics(
      label: 'Filtre par catégorie',
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: allCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = allCategories[index];
            final isSelected =
                selected == cat || (cat == 'Tous' && selected == null);
            return FilterChip(
              label: Text(cat,
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500)),
              selected: isSelected,
              onSelected: (_) => onChanged(cat == 'Tous' ? null : cat),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _TaskItem(task: tasks[index]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première tâche pour commencer',
            style: GoogleFonts.plusJakartaSans(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends ConsumerWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    final theme = Theme.of(context);
    final custom = CustomColors.of(theme);

    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => custom.taskUrgentColor,
      TaskPriority.medium => custom.taskMediumColor,
      TaskPriority.chill => custom.taskChillColor,
    };

    return Semantics(
      label:
          'Tâche: ${task.title}, ${task.isCompleted ? "terminée" : "en cours"}, priorité ${task.priority.name}, ${task.completedPomodoros}/${task.targetPomodoros} pomodoros',
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Supprimer la tâche',
                      style: GoogleFonts.plusJakartaSans()),
                  content: Text(
                      'Voulez-vous vraiment supprimer "${task.title}" ?',
                      style: GoogleFonts.plusJakartaSans()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer')),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) => repo.deleteTask(task.id),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => repo.toggleTask(task.id),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.priority.name.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.category,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '🍅 ${task.completedPomodoros}/${task.targetPomodoros}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (!task.isCompleted && task.completedPomodoros > 0)
                          SizedBox(
                            width: 60,
                            child: LinearProgressIndicator(
                              value: task.progress.clamp(0.0, 1.0),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (!task.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: Text('+1 Pomodoro',
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w500)),
                          onPressed: () => repo.incrementPomodoro(task.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTaskButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Ajouter une nouvelle tâche',
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text('Nouvelle tâche',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            onPressed: () => _showAddTaskDialog(context, ref),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(taskRepositoryProvider);
    final categories = ref.read(categoriesProvider);
    final formKey = GlobalKey<FormState>();
    String title = '';
    TaskPriority priority = TaskPriority.medium;
    int targetPomodoros = 1;
    String category = 'Général';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer une tâche', style: GoogleFonts.plusJakartaSans()),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Titre', hintText: 'Ex: Étudier Flutter'),
                  validator: (v) => v?.isEmpty ?? true ? 'Titre requis' : null,
                  onChanged: (v) => title = v,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priorité'),
                  items: TaskPriority.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => priority = v!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: targetPomodoros,
                  decoration:
                      const InputDecoration(labelText: 'Objectif Pomodoros'),
                  items: [1, 2, 3, 4, 5, 6, 8, 10]
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) => targetPomodoros = v!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: <String>{'Général', ...categories, 'Nouvelle...'}
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                repo.addTask(
                  title: title,
                  priority: priority,
                  targetPomodoros: targetPomodoros,
                  category: category == 'Nouvelle...' ? 'Général' : category,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
