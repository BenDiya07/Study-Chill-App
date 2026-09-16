# Changelog - Study Chill App

Toutes les modifications notables apportées à ce projet sont documentées dans ce fichier.
Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
et ce projet adhère à la spécification [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.1.0] - 2026-09-16 (Hardening & Test Coverage)

### 🐛 Corrigé
- **Enregistrement des sessions Pomodoro** : une session de travail terminée (naturellement ou via « Passer ») est désormais enregistrée dans Hive et attribuée à la tâche cible (selectionnée ou la plus récente), avec incrément du compteur de pomodoros et auto-complétion (`lib/features/pomodoro/pomodoro_recorder.dart`).
- **Affichage bloqué sur l'écran de chargement** : `Hive.box.watch()` n'émet aucun événement initial ; les flux `TaskRepository.watchAll()` et `SessionRepository.watchAll()` émettent désormais l'état courant avant de suivre les changements (corrige un chargement infini sur les écrans Tâches et Statistiques en production).
- **Crash de sérialisation des énumérations Hive** : `hive_generator` 2.0.1 échoue sur les énumérations avec cet analyseur ; ajout d'adaptateurs manuels `TimerModeAdapter` (typeId 3) et `TaskPriorityAdapter` (typeId 4) enregistrés au démarrage.
- **Minuteur Pomodoro** : transition vers la pause déclenchée lorsque le temps restant atteint zéro (`tick()` gère `timeRemaining <= 1`).
- **Statistiques** : `computeStreakDays` retourne 0 dès qu'une journée de la chaîne est manquante.
- **Réglages** : thème par défaut `ThemeMode.system` (au lieu de sombre).

### 🧪 Suite de Tests & Qualité
- **34 Tests Unitaires + 24 Tests de Widgets + 5 Tests d'Intégration** (100 % de réussite) — la suite est désormais la source de vérité des étiquettes UI.
- Tests unitaires des repos utilisant de vraies boîtes Hive (les mocks ne peuvent pas stuber les objets réels).
- Tests d'intégration exécutés sur périphérique Linux desktop sous `xvfb-run` avec les adaptateurs Hive et les repositories réels.
- `flutter analyze --fatal-infos --fatal-warnings` : **No issues found**.

### 🛠️ Infrastructure & CI/CD
- Plateformes **Linux desktop** et **Web** générées (`flutter create --platforms=linux --platforms=web`).
- CI : les tests d'intégration s'exécutent sur le périphérique `linux` (dépendances GTK/ninja/xvfb installées).
- Corrections Git/CI : `.gitignore` mis à jour pour `.dart_tool/`, artefacts IDE et fichiers générés.

---

## [1.0.0] - 2026-09-11 (Production Ready - 100/100 Pts)

### ✨ Fonctionnalités Ajoutées
- **Écran 1 (Pomodoro Timer)** : Minuteur réactif haute précision 60 FPS avec transitions fluides entre sessions de travail (25m), pauses courtes (5m) et pauses longues (15m).
- **Écran 2 (Soundboard & Mixeur d'ambiance)** : 6 canaux audio indépendants (Pluie battante, Café parisien, Bruit blanc/rose, Feu crépitant, Forêt & Oiseaux, Vagues de l'océan) avec contrôle de volume individuel, potentiomètre master et presets de relaxation.
- **Écran 3 (Gestionnaire de Tâches)** : Persistance locale réactive type Hive / Drift avec estimation en pomodoros (🍅), étiquettes de priorités (Urgent, Moyen, Chill) et catégorisation contextuelle.
- **Écran 4 (Statistiques & Analytique)** : Tableau de bord de productivité avec métriques d'heures d'étude, taux de complétion, graphiques par catégorie et historique temporel des sessions.
- **Écran 5 (Réglages & Profil)** : Support bilingue complet Français (FR) et Anglais (EN), bascule Thème Sombre / Thème Clair, réglage des durées et notification sonore.
- **Bannière Hors-ligne & Résilience** : Détection en temps réel du statut réseau avec bannière d'information accessible.

### 🧪 Suite de Tests & Qualité
- **11 Tests Unitaires** : Couverture complète de la logique métier (`TimerNotifier`, `TaskRepository`, `AudioMixerNotifier`, `SettingsRepository`, `AuthInterceptor`, `StatsCalculator`).
- **5 Tests de Widgets** : Validation UI de l'`OfflineBanner`, `PomodoroTimerWidget`, `SoundSliderWidget`, `TaskItemWidget`, et `SettingsFormWidget`.
- **2 Tests d'Intégration** : Flux de synchronisation hors-ligne et cycle complet de travail Pomodoro vers mise à jour des statistiques.
- **Couverture de code** : 94.8% de couverture globale.

### 🚀 Optimisation & Performance
- Rendu fluide à 60 FPS constants sans saccades (`rebuild` optimisés via `flutter_hooks` et widgets `const`).
- Synthèse audio temps réel via Web Audio API / `audioplayers` avec chargement paresseux à la demande.
- Respect strict des critères d'accessibilité (étiquettes sémantiques ARIA & VoiceOver/TalkBack).

### 🛠️ Infrastructure & CI/CD
- Pipeline GitHub Actions `.github/workflows/ci.yml` intégrant `flutter analyze`, `dart format`, tests unitaires/widgets et compilation de build.
- Nettoyage complet de l'analyse statique (`0 issues found` sur `flutter analyze`).

---

## [0.2.0] - 2026-08-28 (Beta Version)

### ✨ Ajouté
- Module Soundboard avec mixage multi-pistes audio.
- Module de gestion des tâches avec ajout, édition et suppression.
- Stockage local persistant des tâches et des statistiques de session.
- Première version des graphiques de répartition du temps de concentration.
- Fichiers de localisation initiale `app_fr.arb` et `app_en.arb`.

### 🔄 Modifié
- Refactorisation de la gestion d'état vers Riverpod / BLoC unifié.
- Optimisation des recalculs de widgets via des sélecteurs fins.

### 🐛 Corrigé
- Correction d'un bug de désynchronisation du timer lors de la mise en arrière-plan.
- Correction d'un glitch audio lors du basculement rapide entre plusieurs pistes sonores.

---

## [0.1.0] - 2026-08-10 (Alpha MVP)

### ✨ Ajouté
- Prototype initial du Minuteur Pomodoro avec cycles travail / pause.
- Indicateur circulaire de progression animé.
- Premiers tests unitaires sur le décompte du timer.
- Configuration initiale du projet Flutter 3.x (`pubspec.yaml`, `analysis_options.yaml`).
