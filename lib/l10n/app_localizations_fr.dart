// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Study Chill';

  @override
  String get pomodoro => 'Timer';

  @override
  String get soundboard => 'Sons';

  @override
  String get tasks => 'Tâches';

  @override
  String get analytics => 'Stats';

  @override
  String get settings => 'Réglages';

  @override
  String get work => 'Concentration';

  @override
  String get shortBreak => 'Pause Courte';

  @override
  String get longBreak => 'Pause Longue';

  @override
  String get start => 'Démarrer';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get skip => 'Passer';

  @override
  String get currentTask => 'Tâche en cours :';

  @override
  String get noTaskSelected => 'Aucune tâche liée';

  @override
  String get masterVolume => 'Volume Général';

  @override
  String get addTask => 'Nouvelle Tâche';

  @override
  String get taskTitle => 'Intitulé de la tâche';

  @override
  String get priority => 'Priorité';

  @override
  String get urgent => 'Urgent';

  @override
  String get medium => 'Moyen';

  @override
  String get chill => 'Détente';

  @override
  String get totalFocusToday => 'Temps de Focus';

  @override
  String get sessionsCompleted => 'Sessions Réalisées';

  @override
  String get dailyStreak => 'Série Quotidienne';

  @override
  String get language => 'Langue';

  @override
  String get darkMode => 'Thème Sombre';

  @override
  String get offlineWarning =>
      'Mode hors-ligne : Sauvegarde locale active. Synchronisation automatique au rétablissement du réseau.';

  @override
  String get workDuration => 'Durée de Travail (min)';

  @override
  String get breakDuration => 'Durée de Pause (min)';
}
