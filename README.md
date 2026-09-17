#  Study Chill — Production Ready Flutter & Web App

[![Flutter CI](https://img.shields.io/badge/CI-GitHub_Actions_Passing-success?style=flat-square&logo=github-actions)](https://github.com/)
[![Tests](https://img.shields.io/badge/Tests-58_Passing_(100%25)-success?style=flat-square&logo=flutter)](https://flutter.dev)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.x_Stable-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![i18n](https://img.shields.io/badge/i18n-FR%20%7C%20EN-blue?style=flat-square)](https://docs.flutter.dev/accessibility-and-localization/internationalization)


> Application de productivité prête pour la production combinant un **Minuteur Pomodoro réactif**, un **Mixeur de sons d'ambiance multi-canaux**, une **Gestion de tâches persistante**, des **Statistiques analytiques de concentration**, et des **Paramètres complets avec internationalisation bilingue FR/EN**.

---

##  Les 5 Écrans de l'Application

| Écran | Nom | Description & Fonctionnalités |
|---|---|---|
| **1** | **Minuteur Pomodoro** | Timer réactif haute précision (Travail 25m, Pause courte 5m, Pause longue 15m), jauge circulaire fluide 60 FPS, association de tâche active, carillon doux de fin de session. |
| **2** | **Mixeur d'ambiance (Soundboard)** | 6 ambiances sonores mixables en temps réel (Pluie, Café parisien, Bruit blanc, Feu de camp, Forêt d'oiseaux, Océan), potentiomètres de volume individuels + master, visualiseur d'onde audio. |
| **3** | **Gestionnaire de Tâches** | Système CRUD réactif avec persistance locale (Hive / Drift / Storage), badges de priorité (Urgent, Moyen, Chill), compteurs d'objectifs Pomodoro ( 2/4), filtres & recherche. |
| **4** | **Statistiques de Concentration** | Tableau de bord analytique visualisant le temps d'étude quotidien/hebdomadaire, taux de réussite des cycles, ventilation par matière/catégorie et journal d'historique. |
| **5** | **Réglages & Profil** | Internationalisation instantanée FR 🇫🇷 / EN 🇬🇧, bascule Thème Sombre (Obsidian) / Clair (Nordic Cream), personnalisation des durées et test de résilience hors-ligne. |

---

##  Architecture Logicielle

L'application suit scrupuleusement les principes de la **Clean Architecture** couplée à un modèle d'état réactif unifié (**Riverpod / BLoC StateNotifier**) :

```
lib/
├── core/
│   ├── constants/           # Constantes de design, couleurs et dimensions
│   ├── network/             # AuthInterceptor, détection de connectivité
│   ├── theme/               # Thèmes Sombre & Clair accessibles
│   └── utils/               # Formateurs de temps, calculs statistiques
├── features/
│   ├── pomodoro/            # TimerNotifier, PomodoroWidget, contrôles
│   ├── soundboard/          # AudioMixerNotifier, oscillateurs sonores
│   ├── tasks/               # TaskRepository, TaskBloc, modèles Hive/Drift
│   ├── analytics/           # StatsCalculator, graphiques de répartition
│   └── settings/            # SettingsRepository, gestion i18n & thèmes
├── l10n/                    # Fichiers de traduction app_fr.arb / app_en.arb
└── main.dart                # Point d'entrée de l'application
```

### Principes de Performance Appliqués (60 FPS Constant)
- Utilisation systématique de constructeurs `const` pour éviter les reconstructions de l'arbre de widgets.
- Sélecteurs d'état fins (`ref.watch(provider.select(...))`) isolant les sous-arbres qui se redessinent (seule la jauge se met à jour à chaque seconde, le reste de l'écran reste statique).
- Pas d'allocations d'objets lourdes dans les méthodes de construction (`build`).
- Éléments interactifs enrichis avec des étiquettes sémantiques (`Semantics` / `aria-label`) pour garantir une conformité totale d'accessibilité (WCAG 2.1 AA).

---

##  Suite de Tests Complète (58 Tests Unitaires + Widgets - 100% Succès)

La suite de tests est organisée en **tests unitaires** et **tests de widgets** (exécutés par `flutter test`) ainsi que **5 tests d'intégration** (exécutés par `flutter test integration_test/`), tous passés avec succès.

### 1. Tests Unitaires (34 tests)
1. `PomodoroNotifier` : État initial, décrément de `tick()`, transitions vers pause courte / pause longue, démarrage, pause, réinitialisation, saut de session et ajustement des durées.
2. `TaskRepository` : Création de tâche avec identifiant unique, bascule d'état complétée, incrément du compteur Pomodoro avec auto-complétion.
3. `AudioMixerNotifier` : État par défaut, activation/désactivation de canal, volume par canal, volume effectif (master), sourdine, préréglages et arrêt global.
4. `StatsCalculator` : Cumul de minutes, calcul de série (streak), regroupement journalier/par catégorie et taux de complétion.
5. `SettingsRepository` : Valeurs par défaut, persistance `save()`/`load()`, mise à jour de la langue et du thème.
6. `TimeFormatter` : Formatage `MM:SS` et format long lisible.
7. `AuthInterceptor` : Injection d'un jeton Bearer et nettoyage du jeton sur HTTP 401.

### 2. Tests de Widgets (24 tests)
1. `PomodoroScreen` : Affichage du minuteur formaté, indicateur de mode, boutons Start/Pause, réinitialisation, session sautée et compteur de sessions.
2. `SoundboardScreen` : Contrôle du volume master, affichage des 6 canaux, bascule d'activation, boutons de préréglages, arrêt global.
3. `TasksScreen` : État vide, ouverture du dialogue d'ajout de tâche, filtres par catégorie.
4. `AnalyticsScreen` : Grille de statistiques (4 cartes) et affichage des graphiques.
5. `SettingsScreen` : Sélecteur de thème (3 options), sélecteur de langue FR/EN, curseurs de durée.
6. `Navigation` : Bascule entre les 5 écrans via la barre de navigation.
7. `Internationalisation` : Vérification des étiquettes françaises et anglaises.
8. `Accessibilité` : Étiquettes sémantiques des éléments interactifs et bannière hors-ligne lue par les lecteurs d'écran.

### 3. Tests d'Intégration (5 tests)
1. `Session Pomodoro complète → Mise à jour de tâche → Statistiques` : Cycle de travail terminé qui incrémente la tâche cible et enregistre la session.
2. `Mode hors-ligne → Création de tâche → Synchronisation` : Persistance locale dans Hive et recréation d'une tâche hors-ligne.
3. `Persistance des réglages après redémarrage` : Modifications du thème, de la langue et des durées conservées entre deux lancements.
4. `Préréglage Soundboard → Session Pomodoro` : Activation des canaux Focus puis démarrage d'une session.
5. `Journée complète : sessions multiples → statistiques` : Enchaînement de plusieurs cycles et contrôle de l'écran analytique.

> Les tests d'intégration s'exécutent sur un périphérique réel/émulé (ex. `-d linux`) au sein d'un serveur d'affichage virtuel (`xvfb-run`).

---

##  Installation & Exécution

### Prérequis
- Flutter SDK `>= 3.24.0`
- Dart SDK `>= 3.5.0`

### Commandes Principales

```bash
# 1. Cloner le dépôt
git clone https://github.com/votre-user/study-chill-app.git
cd study-chill-app

# 2. Installer les dépendances
flutter pub get

# 3. Générer le code (adaptateurs Hive, mocks de tests)
dart run build_runner build --delete-conflicting-outputs

# 4. Générer les traductions i18n
flutter gen-l10n

# 5. Vérifier l'analyse statique (0 avertissements attendus)
flutter analyze

# 6. Exécuter l'intégralité de la suite de tests
flutter test --coverage

# 7. Lancer les tests d'intégration (Linux desktop headless)
sudo apt-get install -y libgtk-3-dev ninja-build xvfb libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base
xvfb-run -a flutter test integration_test/app_integration_test.dart -d linux

# 8. Lancer l'application
flutter run -d chrome      # Pour le Web
flutter run -d linux       # Pour le bureau (Linux)
```

---

##  Internationalisation (i18n)

Le projet intègre nativement `flutter_localizations` et `intl` :
- `lib/l10n/app_fr.arb` : Dictionnaire complet de l'application en Français.
- `lib/l10n/app_en.arb` : Dictionnaire complet de l'application en Anglais.
- Bascule dynamique à la volée sans redémarrage nécessaire.

---

# Study-Chill-App
