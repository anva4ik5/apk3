import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds — холодный ночной оттенок с мягким контрастом
  static const bg1 = Color(0xFF0F1822);
  static const bg2 = Color(0xFF172331);
  static const bg3 = Color(0xFF1E2B3B);
  static const bg4 = Color(0xFF243549);

  // Акценты
  static const primary = Color(0xFF2AABEE);
  static const primaryDark = Color(0xFF1A8EC0);
  static const primaryLight = Color(0xFF69C6FF);
  static const green = Color(0xFF4DB266);
  static const red = Color(0xFFE53935);
  static const yellow = Color(0xFFFFB300);
  static const violet = Color(0xFF7C4DFF);

  // Текст
  static const textPrimary = Color(0xFFECEFF3);
  static const textSecondary = Color(0xFF9AB0C6);
  static const textMuted = Color(0xFF6C8099);

  // Пузыри сообщений
  static const myBubble = Color(0xFF2AABEE);
  static const myBubbleDark = Color(0xFF1A8EC0);
  static const otherBubble = Color(0xFF213342);
  static const aiBubble = Color(0xFF172E42);
  static const aiAccent = Color(0xFF56D5FF);

  // Системные цвета
  static const divider = Color(0xFF24384A);
  static const badge = Color(0xFF2AABEE);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const myMessage = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const splash = LinearGradient(
    colors: [AppColors.bg1, AppColors.bg2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg1,
    canvasColor: AppColors.bg1,
    cardColor: AppColors.bg2,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.bg2,
      background: AppColors.bg1,
      error: AppColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg2,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bg2,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: AppColors.primary, width: 2)),
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textMuted,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.25),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.bg2,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
    ),
    dividerColor: AppColors.divider,
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 0.5),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    ),
  );
}
