import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class SettingsManager {
  static const String _keyTabSuspensionEnabled = 'tab_suspension_enabled';
  static const String _keyTabSuspensionTimeout = 'tab_suspension_timeout';
  static const String _keyMaxTabs = 'max_tabs';
  static const String _keyThemeDark = 'theme_dark';
  static const String _keyAdBlockEnabled = 'ad_block_enabled';

  static final SettingsManager _instance = SettingsManager._internal();
  
  factory SettingsManager() {
    return _instance;
  }
  
  SettingsManager._internal();
  
  late SharedPreferences _prefs;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Tab Management Settings
  bool get isTabSuspensionEnabled => _prefs.getBool(_keyTabSuspensionEnabled) ?? true;
  set isTabSuspensionEnabled(bool value) => _prefs.setBool(_keyTabSuspensionEnabled, value);
  
  int get tabSuspensionTimeout => _prefs.getInt(_keyTabSuspensionTimeout) ?? 30;
  set tabSuspensionTimeout(int minutes) => _prefs.setInt(_keyTabSuspensionTimeout, minutes);
  
  int get maxTabs => _prefs.getInt(_keyMaxTabs) ?? 20;
  set maxTabs(int value) => _prefs.setInt(_keyMaxTabs, value);
  
  // Theme Settings
  bool get isDarkTheme => _prefs.getBool(_keyThemeDark) ?? true;
  set isDarkTheme(bool value) => _prefs.setBool(_keyThemeDark, value);
  
  // Ad Blocking Settings
  bool get isAdBlockEnabled => _prefs.getBool(_keyAdBlockEnabled) ?? true;
  set isAdBlockEnabled(bool value) => _prefs.setBool(_keyAdBlockEnabled, value);
  
  ThemeData get currentTheme {
    return ThemeData(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      primaryColor: Color(0xFF6c5ce7),
      accentColor: Color(0xFFa700e3),
      scaffoldBackgroundColor: isDarkTheme ? Color(0xFF1a1a2e) : Colors.white,
      cardColor: isDarkTheme ? Color(0xFF2d2d44) : Colors.grey[100],
      textTheme: TextTheme(
        bodyText1: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
        bodyText2: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
  
  void resetToDefaults() {
    isTabSuspensionEnabled = true;
    tabSuspensionTimeout = 30;
    maxTabs = 20;
    isDarkTheme = true;
    isAdBlockEnabled = true;
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsManager _settings = SettingsManager();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFF6c5ce7),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Tab Suspension'),
            subtitle: Text('Automatically suspend inactive tabs to save memory'),
            value: _settings.isTabSuspensionEnabled,
            onChanged: (bool value) {
              setState(() {
                _settings.isTabSuspensionEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text('Tab Suspension Timeout'),
            subtitle: Text('${_settings.tabSuspensionTimeout} minutes'),
            trailing: DropdownButton<int>(
              value: _settings.tabSuspensionTimeout,
              items: [15, 30, 45, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value min'),
                );
              }).toList(),
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _settings.tabSuspensionTimeout = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text('Maximum Tabs'),
            subtitle: Text('${_settings.maxTabs} tabs'),
            trailing: DropdownButton<int>(
              value: _settings.maxTabs,
              items: [10, 20, 30, 40, 50].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _settings.maxTabs = value;
                  });
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text('Dark Theme'),
            subtitle: Text('Use dark color scheme'),
            value: _settings.isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                _settings.isDarkTheme = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Ad Blocking'),
            subtitle: Text('Block advertisements while browsing'),
            value: _settings.isAdBlockEnabled,
            onChanged: (bool value) {
              setState(() {
                _settings.isAdBlockEnabled = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFa700e3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Reset to Defaults'),
              onPressed: () {
                setState(() {
                  _settings.resetToDefaults();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
