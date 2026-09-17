// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Study Chill';

  @override
  String get pomodoro => 'Timer';

  @override
  String get soundboard => 'Sounds';

  @override
  String get tasks => 'Tasks';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get work => 'Focus';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Reset';

  @override
  String get skip => 'Skip';

  @override
  String get currentTask => 'Current focus:';

  @override
  String get noTaskSelected => 'No task linked';

  @override
  String get masterVolume => 'Master Volume';

  @override
  String get addTask => 'New Task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get priority => 'Priority';

  @override
  String get urgent => 'Urgent';

  @override
  String get medium => 'Medium';

  @override
  String get chill => 'Chill';

  @override
  String get totalFocusToday => 'Focus Today';

  @override
  String get sessionsCompleted => 'Completed Sessions';

  @override
  String get dailyStreak => 'Day Streak';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get offlineWarning =>
      'Offline mode: Local storage active. Data will sync once reconnected.';

  @override
  String get workDuration => 'Work Duration (min)';

  @override
  String get breakDuration => 'Break Duration (min)';
}
