import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  bool isCompleted;
  
  @HiveField(3)
  int completedPomodoros;
  
  @HiveField(4)
  int targetPomodoros;
  
  @HiveField(5)
  TaskPriority priority;
  
  @HiveField(6)
  String category;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedPomodoros = 0,
    this.targetPomodoros = 1,
    required this.priority,
    this.category = 'Général',
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => targetPomodoros > 0 ? completedPomodoros / targetPomodoros : 0.0;
  
  bool get isOverTarget => completedPomodoros >= targetPomodoros;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'completedPomodoros': completedPomodoros,
    'targetPomodoros': targetPomodoros,
    'priority': priority.name,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedPomodoros: json['completedPomodoros'] as int? ?? 0,
    targetPomodoros: json['targetPomodoros'] as int? ?? 1,
    priority: TaskPriority.values.byName(json['priority'] as String? ?? 'medium'),
    category: json['category'] as String? ?? 'Général',
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
  );
}

class TaskRepository {
  static const String boxName = kHiveBoxTasks;
  late Box<Task> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Task>(boxName);
  }

  Box<Task> get box => _box;

  List<Task> getAll({String? category, bool? completed}) {
    var tasks = _box.values.toList();
    
    if (category != null) {
      tasks = tasks.where((t) => t.category == category).toList();
    }
    if (completed != null) {
      tasks = tasks.where((t) => t.isCompleted == completed).toList();
    }
    
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return tasks;
  }

  Stream<List<Task>> watchAll() {
    return _box.watch().map((_) => getAll());
  }

  Task addTask({
    required String title,
    required TaskPriority priority,
    int targetPomodoros = 1,
    String category = 'Général',
  }) {
    final task = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      priority: priority,
      targetPomodoros: targetPomodoros,
      category: category,
    );
    _box.add(task);
    return task;
  }

  Future<void> updateTask(Task task) async {
    await task.save();
  }

  Future<void> toggleTask(String id) async {
    final task = _box.values.firstWhere((t) => t.id == id, orElse: () => throw Exception('Task not found'));
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await task.save();
  }

  Future<void> incrementPomodoro(String id) async {
    final task = _box.values.firstWhere((t) => t.id == id, orElse: () => throw Exception('Task not found'));
    task.completedPomodoros++;
    if (task.completedPomodoros >= task.targetPomodoros && !task.isCompleted) {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
    }
    await task.save();
  }

  Future<void> deleteTask(String id) async {
    final task = _box.values.firstWhere((t) => t.id == id, orElse: () => throw Exception('Task not found'));
    await task.delete();
  }

  Future<void> clearCompleted() async {
    final completed = _box.values.where((t) => t.isCompleted).toList();
    for (final task in completed) {
      await task.delete();
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAll();
});

final categoriesProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (tasks) => tasks.map((t) => t.category).toSet().toList()..sort(),
    loading: () => ['Général'],
    error: (_, __) => ['Général'],
  );
});