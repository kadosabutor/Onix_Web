import 'package:flutter/material.dart';

// --- KÖZPONTI ARCULATI SZÍNEK (Design System) ---
class OnixColors {
  static const Color obsidianBlack = Color(0xFF0D1117);
  static const Color deepEmerald = Color(0xFF0A3622);
  static const Color cyberMint = Color(0xFF00D084);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color textSecondary = Colors.white70;
  static const Color errorRed = Color(0xFFCF6679);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OnixColors.cyberMint,
      brightness: Brightness.dark,
      surface: OnixColors.obsidianBlack,
      primary: OnixColors.cyberMint,
      error: OnixColors.errorRed,
    );

    final textTheme = const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: OnixColors.pureWhite),
      displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: OnixColors.pureWhite),
      titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: OnixColors.pureWhite),
      bodyLarge: TextStyle(fontFamily: 'Inter', color: OnixColors.textSecondary),
      bodyMedium: TextStyle(fontFamily: 'Inter', color: OnixColors.textSecondary),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OnixColors.obsidianBlack,
      cardColor: OnixColors.darkSurface,
      fontFamily: 'Inter',
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: OnixColors.obsidianBlack,
        elevation: 0,
      ),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      useMaterial3: true,
    );
  }

  // A világos témát is meghagyjuk, ha a mobil apphoz az kellene
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      useMaterial3: true,
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return InputDecorationTheme(
      border: border,
      enabledBorder: border.copyWith(borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: OnixColors.cyberMint, width: 2)),
      errorBorder: border.copyWith(borderSide: const BorderSide(color: OnixColors.errorRed)),
      focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: OnixColors.errorRed, width: 2)),
    );
  }
}