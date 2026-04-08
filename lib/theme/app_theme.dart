import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Inter-based themes matching the React dashboard (`font-family: Inter`).
class AppTheme {
  AppTheme._();

  static const double inputHeight = 48;
  static const double radiusMd = 8;

  static ThemeData light() {
    final p = EatOsPalette.light;
    final colorScheme = ColorScheme.light(
      surface: p.background,
      onSurface: p.foreground,
      primary: p.primary,
      onPrimary: EatOsPalette.light.background,
      outline: p.border,
    );
    return _base(p, colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    final p = EatOsPalette.dark;
    final colorScheme = ColorScheme.dark(
      surface: p.background,
      onSurface: p.foreground,
      primary: p.primary,
      onPrimary: EatOsPalette.dark.background,
      outline: p.border,
    );
    return _base(p, colorScheme, Brightness.dark);
  }

  static ThemeData _base(
    EatOsPalette p,
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final baseText = GoogleFonts.interTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.background,
      colorScheme: colorScheme,
      textTheme: baseText.copyWith(
        headlineSmall: GoogleFonts.inter(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: p.foreground,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: p.foreground,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: p.foreground,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: p.mutedForeground,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: p.foreground,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        constraints: const BoxConstraints(minHeight: AppTheme.inputHeight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: p.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: p.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: p.foreground, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.foreground;
          }
          return null;
        }),
        checkColor: WidgetStatePropertyAll(p.background),
        side: BorderSide(color: p.input, width: 1.5),
      ),
    );
  }
}
