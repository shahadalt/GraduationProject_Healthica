import '../../imports.dart';

/// A service that stores and retrieves user settings.
class StorageService {
  SharedPreferences? prefs;

  /// Loads the User's preferred ThemeMode from local storage.
  Future<Locale> locale() async {
    String? name = (prefs ?? await SharedPreferences.getInstance()).getString('locale');

    if (name == null || name == 'en') return const Locale('en');

    return const Locale('ar');
  }

  Future<ThemeMode> themeMode() async {
    String? name = (prefs ?? await SharedPreferences.getInstance()).getString('theme');

    if (name == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere((e) => e.name == name);
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    (prefs ?? await SharedPreferences.getInstance()).setString('theme', theme.name);
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateLocale(Locale locale) async {
    (prefs ?? await SharedPreferences.getInstance()).setString('locale', locale.languageCode);
  }
}
