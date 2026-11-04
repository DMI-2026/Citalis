import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF7F5F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFEBE4);
  static const Color ink = Color(0xFF0F0F0F);
  static const Color inkMuted = Color(0xFF78716C);
  static const Color inkFaint = Color(0xFFA8A29E);
  static const Color line = Color(0xFFE7E5E4);
  static const Color accent = Color(0xFFB8956A);
  static const Color success = Color(0xFF4A5D45);
  static const Color warn = Color(0xFFB45309);
  static const Color danger = Color(0xFF991B1B);

  static TextStyle display({
    double size = 44,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: 1.05,
      letterSpacing: -0.6,
    );
  }

  static TextStyle serif({
    double size = 20,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: 1.15,
      letterSpacing: -0.2,
    );
  }

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle eyebrow({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color ?? inkMuted,
      letterSpacing: 1.4,
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ink,
      brightness: Brightness.light,
      primary: ink,
      onPrimary: Colors.white,
      secondary: accent,
      surface: surface,
      onSurface: ink,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: serif(size: 18, weight: FontWeight.w500),
        iconTheme: const IconThemeData(color: ink, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: sans(size: 14, color: inkFaint),
        labelStyle: sans(size: 14, color: inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ink, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: surfaceAlt,
          disabledForegroundColor: inkFaint,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: ink, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationThickness: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? ink : inkMuted,
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? ink : inkMuted, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: ink, size: 22),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return TextTheme(
      displayLarge: display(size: 48, weight: FontWeight.w500),
      displayMedium: display(size: 40, weight: FontWeight.w500),
      displaySmall: display(size: 32, weight: FontWeight.w500),
      headlineLarge: serif(size: 28, weight: FontWeight.w500),
      headlineMedium: serif(size: 22, weight: FontWeight.w500),
      headlineSmall: serif(size: 18, weight: FontWeight.w500),
      titleLarge: sans(size: 16, weight: FontWeight.w600),
      titleMedium: sans(size: 14, weight: FontWeight.w600),
      titleSmall: sans(size: 12, weight: FontWeight.w600),
      bodyLarge: sans(size: 16, color: ink, height: 1.5),
      bodyMedium: sans(size: 14, color: ink, height: 1.5),
      bodySmall: sans(size: 12, color: inkMuted, height: 1.4),
      labelLarge: sans(size: 14, weight: FontWeight.w500),
      labelMedium: sans(size: 12, weight: FontWeight.w500),
      labelSmall: eyebrow(),
    );
  }
}
