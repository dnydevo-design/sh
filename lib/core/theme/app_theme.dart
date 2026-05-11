import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const trueBlack = Color(0xFF000000);
  static const electricBlue = Color(0xFF00E5FF);
  static const deepBlue = Color(0xFF2A7BFF);
  static const magenta = Color(0xFFFF2BD6);
  static const lightSurface = Color(0xFFF6F8FB);
  static const darkPanel = Color(0xFF0A0D12);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: electricBlue,
      brightness: Brightness.dark,
      surface: trueBlack,
      primary: electricBlue,
      secondary: magenta,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: trueBlack,
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: darkPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: trueBlack,
        indicatorColor: electricBlue.withValues(alpha: 0.16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: trueBlack,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: trueBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
      ),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: deepBlue,
      brightness: Brightness.light,
      primary: deepBlue,
      secondary: magenta,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightSurface,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: Color(0xFF101828),
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

