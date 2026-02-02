import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luxury Midnight Amethyst Palette
  static const Color primaryColor = Color(0xFF1E1B4B); // Deep Indigo
  static const Color accentColor = Color(0xFFA78BFA); // Soft Violet
  static const Color secondaryColor = Color(0xFF6366F1); // Indigo
  static const Color backgroundColor = Color(0xFF020617); // Deep Slate/Black
  static const Color surfaceColor = Colors.white;

  // Neutral Colors
  static const Color black = Color(0xFF020617); // Deeper Slate
  static const Color darkGrey = Color(0xFF334155); // Slate 700
  static const Color grey = Color(0xFF64748B); // Slate 500
  static const Color lightGrey = Color(0xFFE2E8F0); // Slate 200
  static const Color white = Colors.white;

  // Status Colors
  static const Color errorColor = Color(0xFFDC2626); 
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFD97706);

  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF312E81)], // Indigo 900
  );

  static const LinearGradient amethystGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFF8B5CF6)], // Violet 600
  );

  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF1F5F9), // Slate 100
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFFF1F5F9),
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: black,
    height: 1.4,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: black,
    height: 1.4,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: black,
    height: 1.5,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkGrey,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: darkGrey,
    height: 1.4,
  );

  // Price Styles
  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    height: 1.2,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    height: 1.3,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: accentColor,
    height: 1.3,
  );

  // Theme Data
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      splashFactory: NoSplash.splashFactory, // Remove ripple effects
      highlightColor: Colors.transparent,    // Remove highlight color
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: primaryColor,
        background: backgroundColor,
        error: const Color(0xFFEF4444),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        iconTheme: const IconThemeData(color: white),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          color: darkGrey,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: grey,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightGrey),
        ),
      ),

      // Text Theme
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: black),
        displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: black),
        displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: black),
        headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: black),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkGrey),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkGrey),
        labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: accentColor,
        unselectedItemColor: grey,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: grey,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
