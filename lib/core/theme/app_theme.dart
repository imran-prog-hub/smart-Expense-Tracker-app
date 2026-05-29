import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors matching the screenshots
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color surfaceVariant = Color(0xFF242736);
  static const Color cardColor = Color(0xFF1E2130);

  static const Color primary = Color(0xFF4ADE80);       // Green accent
  static const Color primaryDark = Color(0xFF22C55E);
  static const Color accent = Color(0xFF6EE7B7);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color income = Color(0xFF4ADE80);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color expenseLight = Color(0xFFFF8080);

  static const Color foodColor = Color(0xFFF59E0B);     // Amber
  static const Color transportColor = Color(0xFF60A5FA); // Blue
  static const Color shoppingColor = Color(0xFFA78BFA); // Purple
  static const Color healthColor = Color(0xFF34D399);   // Teal
  static const Color entertainColor = Color(0xFFFB7185);// Pink
  static const Color billsColor = Color(0xFFFBBF24);   // Yellow
  static const Color travelColor = Color(0xFF38BDF8);   // Sky
  static const Color otherColor = Color(0xFF94A3B8);    // Slate

  static const Color divider = Color(0xFF2D3148);
  static const Color border = Color(0xFF2A2D3E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: expense,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
