const int kDefaultWorkDuration = 25 * 60;
const int kDefaultShortBreakDuration = 5 * 60;
const int kDefaultLongBreakDuration = 15 * 60;
const int kSessionsBeforeLongBreak = 4;

const String kAudioRain = 'rain';
const String kAudioCoffee = 'coffee_shop';
const String kAudioWhiteNoise = 'white_noise';
const String kAudioCampfire = 'campfire';
const String kAudioForest = 'forest';
const String kAudioOcean = 'ocean';

const List<String> kAudioChannels = [
  kAudioRain,
  kAudioCoffee,
  kAudioWhiteNoise,
  kAudioCampfire,
  kAudioForest,
  kAudioOcean,
];

const String kHiveBoxTasks = 'tasks';
const String kHiveBoxSessions = 'sessions';
const String kHiveBoxSettings = 'settings';

const String kPrefLocale = 'locale';
const String kPrefThemeMode = 'theme_mode';
const String kPrefWorkDuration = 'work_duration';
const String kPrefShortBreakDuration = 'short_break_duration';
const String kPrefLongBreakDuration = 'long_break_duration';
const String kPrefMasterVolume = 'master_volume';

enum TimerMode { work, shortBreak, longBreak }

enum TaskPriority { urgent, medium, chill }

enum ThemeModeType { light, dark, system }