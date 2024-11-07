import 'package:flutter/material.dart';

class AppTheme {
  // YeonSphere color scheme
  static const primaryPurple = Color(0xFF7B2CBF);
  static const secondaryPurple = Color(0xFF9D4EDD);
  static const darkBg = Color(0xFF1A1A2E);
  static const lightBg = Color(0xFFF8F9FA);
  static const accentColor = Color(0xFFE0AAFF);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: secondaryPurple,
      surface: darkBg,
      background: darkBg,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: darkBg.withOpacity(0.6),
      elevation: 0,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: secondaryPurple,
      surface: lightBg,
      background: lightBg,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: lightBg.withOpacity(0.6),
      elevation: 0,
    ),
  );
}
