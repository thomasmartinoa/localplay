/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Music';
  static const String appVersion = '1.0.0';

  // API (placeholder for future backend integration)
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Audio Settings
  static const Duration seekDuration = Duration(seconds: 10);
  static const double minPlaybackSpeed = 0.5;
  static const double maxPlaybackSpeed = 2.0;
  static const double defaultPlaybackSpeed = 1.0;

  // Cache Settings
  static const int maxCachedSongs = 100;
  static const int maxRecentlyPlayed = 50;
  static const int maxSearchHistory = 20;

  // UI Settings
  static const double miniPlayerHeight = 64.0;
  static const double bottomNavHeight = 80.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  // Hive Boxes
  static const String songsBox = 'songs_box';
  static const String playlistsBox = 'playlists_box';
  static const String settingsBox = 'settings_box';
  static const String recentBox = 'recent_box';
  static const String favoritesBox = 'favorites_box';
}
