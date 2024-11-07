import 'package:shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _searchEngineKey = 'search_engine';
  static const String _adBlockingKey = 'ad_blocking';
  static const String _trackingProtectionKey = 'tracking_protection';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<void> setThemeMode(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setSearchEngine(String searchEngine) async {
    await _prefs.setString(_searchEngineKey, searchEngine);
  }

  String getSearchEngine() {
    return _prefs.getString(_searchEngineKey) ?? 'https://search.brave.com/search?q=';
  }

  Future<void> setAdBlocking(bool enabled) async {
    await _prefs.setBool(_adBlockingKey, enabled);
  }

  bool getAdBlocking() {
    return _prefs.getBool(_adBlockingKey) ?? true;
  }

  Future<void> setTrackingProtection(bool enabled) async {
    await _prefs.setBool(_trackingProtectionKey, enabled);
  }

  bool getTrackingProtection() {
    return _prefs.getBool(_trackingProtectionKey) ?? true;
  }
}
