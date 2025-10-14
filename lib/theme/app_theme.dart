import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF044366);
  static const Color orange = Color(0xFFEE7D21);
  static const Color white = Color(0xFFFFFFFF);
}

ThemeData buildLightTheme() {
  const Color primary = AppColors.navy;
  const Color secondary = AppColors.orange;
  const Color background = AppColors.white;

  final ColorScheme colorScheme = const ColorScheme.light(
    primary: primary,
    secondary: secondary,
    surface: AppColors.white,
    background: background,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: Colors.black87,
    onBackground: Colors.black87,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(secondary),
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
        padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(secondary),
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all<BorderSide>(BorderSide(color: secondary, width: 1.4)),
        foregroundColor: WidgetStateProperty.all<Color>(secondary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(secondary),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: AppColors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondary.withOpacity(0.12),
      selectedColor: secondary,
      secondarySelectedColor: secondary,
      labelStyle: const TextStyle(color: Colors.black87),
      secondaryLabelStyle: const TextStyle(color: AppColors.white),
      brightness: Brightness.light,
    ),
    dividerColor: Colors.black12,
  );
}

ThemeData buildDarkTheme() {
  const Color primary = AppColors.navy;
  const Color secondary = AppColors.orange;

  final ColorScheme colorScheme = const ColorScheme.dark(
    primary: primary,
    secondary: secondary,
    surface: Color(0xFF1A1A1A),
    background: Color(0xFF0F0F0F),
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.white,
    onBackground: AppColors.white,
  );

  return ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(secondary),
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(secondary),
        foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all<BorderSide>(BorderSide(color: secondary, width: 1.4)),
        foregroundColor: WidgetStateProperty.all<Color>(secondary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(secondary),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: AppColors.white,
    ),
    dividerColor: const Color(0xFF2A2A2A),
  );
}