// lib/core/theme.dart
//
// CropSense Design System
// ─────────────────────────────────────────────────────────────────────────
// This file is the single source of truth for all visual styling.
// Every color, font size, card shape, and button style is defined here.
// Import this file wherever you need theme access:
//   import 'package:cropsense/core/theme.dart';
// Then use: AppTheme.primary, AppTheme.buildTheme(), etc.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────
// COLOR PALETTE
// These are the exact hex values specified in the CropSense design spec.
// We define them as static constants so they're available everywhere.
// ─────────────────────────────────────────────────────────────────────────
abstract class AppColors {
  // Primary brand colors
  static const Color deepGreen   = Color(0xFF1B5E20); // AppBar, SideNav, headers
  static const Color limeGreen   = Color(0xFF8BC34A); // Accents, positive indicators, FAB
  static const Color amber       = Color(0xFFFF8F00); // Warnings, moderate risk
  static const Color skyBlue     = Color(0xFF0288D1); // Data, charts, info cards
  static const Color burntOrange = Color(0xFFE65100); // Alerts, high risk
  static const Color offWhite    = Color(0xFFF9FAF7); // Scaffold background

  // Risk level colors (used on the Pakistan choropleth map)
  static const Color riskGood     = Color(0xFF1B5E20); // Good conditions
  static const Color riskAbove    = Color(0xFF8BC34A); // Above average
  static const Color riskWatch    = Color(0xFFFF8F00); // Watch / moderate
  static const Color riskHigh     = Color(0xFFE65100); // High risk
  static const Color riskCritical = Color(0xFFB71C1C); // Critical / drought

  // Neutral shades used throughout the UI
  static const Color white        = Color(0xFFFFFFFF);
  static const Color grey100      = Color(0xFFF5F5F5);
  static const Color grey200      = Color(0xFFEEEEEE);
  static const Color grey400      = Color(0xFFBDBDBD);
  static const Color grey600      = Color(0xFF757575);
  static const Color grey800      = Color(0xFF424242);
  static const Color darkText     = Color(0xFF1A1A1A);

  // Card and surface colors
  static const Color cardSurface  = Color(0xFFFFFFFF);
  static const Color divider      = Color(0xFFE0E0E0);

  // Chart colors for 5 crops (Wheat, Rice, Cotton, Sugarcane, Maize)
  static const List<Color> cropColors = [
    Color(0xFF1B5E20), // Wheat   — deep green
    Color(0xFF0288D1), // Rice    — sky blue
    Color(0xFFFF8F00), // Cotton  — amber
    Color(0xFF8BC34A), // Sugarcane — lime
    Color(0xFFE65100), // Maize   — burnt orange
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// TEXT STYLES
// Inter for body text, Space Grotesk for headings.
// Both come from the google_fonts package — no font files needed.
// ─────────────────────────────────────────────────────────────────────────
abstract class AppTextStyles {
  // ── Headings (Space Grotesk) ──────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
    letterSpacing: -0.5,
  );

  static TextStyle get headingLarge => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
    letterSpacing: -0.3,
  );

  static TextStyle get headingMedium => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static TextStyle get headingSmall => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  // ── Body text (Inter) ─────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.4,
  );

  // ── Special purpose ───────────────────────────────────────────
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.grey600,
    letterSpacing: 0.5,
  );

  static TextStyle get kpiNumber => GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.deepGreen,
    letterSpacing: -1.0,
  );

  static TextStyle get chipLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ── Urdu-friendly override ────────────────────────────────────
  // When displaying Urdu text, we use a slightly larger size
  // because Urdu script needs more space to be readable.
  static TextStyle get urduBody => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    height: 1.8, // Urdu needs more line height
  );
}

// ─────────────────────────────────────────────────────────────────────────
// SPACING & SIZING CONSTANTS
// Use these instead of hardcoded numbers so the UI is consistent.
// ─────────────────────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // Card padding (used on all KPI, chart, and data cards)
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
}

// ─────────────────────────────────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────────────────────────────────
abstract class AppRadius {
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 24.0;
  static const double pill = 100.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(pill));
}

// ─────────────────────────────────────────────────────────────────────────
// SHADOWS
// Subtle shadows give depth to cards without looking heavy.
// ─────────────────────────────────────────────────────────────────────────
abstract class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// MAIN THEME BUILDER
// This is what we pass to MaterialApp's `theme:` parameter.
// It wires together all the colors, fonts, and component styles above.
// ─────────────────────────────────────────────────────────────────────────
abstract class AppTheme {
  static ThemeData buildTheme() {
    // Base color scheme centered on deep green
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepGreen,
      primary: AppColors.deepGreen,
      secondary: AppColors.limeGreen,
      tertiary: AppColors.skyBlue,
      error: AppColors.burntOrange,
      surface: AppColors.cardSurface,
      onPrimary: AppColors.white,
      onSecondary: AppColors.darkText,
      onSurface: AppColors.darkText,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ── Scaffold (page background) ──────────────────────────
      scaffoldBackgroundColor: AppColors.offWhite,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),

      // ── Navigation Rail (persistent left sidebar) ────────────
      // Used on web and desktop where there's enough horizontal space.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.deepGreen,
        selectedIconTheme: const IconThemeData(
          color: AppColors.limeGreen,
          size: 26,
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColors.white.withValues(alpha: 0.7),
          size: 24,
        ),
        selectedLabelTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.limeGreen,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white.withValues(alpha: 0.7),
        ),
        indicatorColor: AppColors.white.withValues(alpha: 0.15),
        elevation: 0,
      ),

      // ── Cards ────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: AppColors.grey200, width: 1),
        ),
        margin: EdgeInsets.all(0),
      ),

      // ── Elevated Buttons ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // ── Outlined Buttons ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepGreen,
          side: const BorderSide(color: AppColors.deepGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),

      // ── Text Buttons ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepGreen,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Fields (TextFormField, DropdownButtonFormField) ─
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppColors.deepGreen, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppColors.burntOrange, width: 1),
        ),
        labelStyle: AppTextStyles.bodySmall,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
      ),

      // ── Chips (crop filter chips on map screen) ───────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.deepGreen,
        labelStyle: AppTextStyles.chipLabel,
        secondaryLabelStyle: AppTextStyles.chipLabel.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.chipRadius,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Global text theme wired to Inter font ─────────────────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelSmall: AppTextStyles.label,
      ),
    );
  }
}