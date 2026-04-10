import 'package:flutter/material.dart';

/// Sidebar + shell tokens from [eatos-live-dashboard/src/index.css].
@immutable
class EatOsShellTheme extends ThemeExtension<EatOsShellTheme> {
  const EatOsShellTheme({
    required this.sidebarBackground,
    required this.sidebarForeground,
    required this.sidebarAccent,
    required this.sidebarAccentForeground,
    required this.sidebarBorder,
    required this.mainMutedOverlay,
    required this.cardBackground,
    required this.popoverBackground,
    required this.destructive,
    required this.success,
    required this.mutedSolid,
  });

  final Color sidebarBackground;
  final Color sidebarForeground;
  final Color sidebarAccent;
  final Color sidebarAccentForeground;
  final Color sidebarBorder;

  /// Blended over scaffold for `bg-muted/30` main area.
  final Color mainMutedOverlay;
  final Color cardBackground;
  final Color popoverBackground;
  final Color destructive;
  final Color success;
  final Color mutedSolid;

  static final EatOsShellTheme light = EatOsShellTheme(
    sidebarBackground: _hsl(0, 0, 100),
    sidebarForeground: _hsl(0, 0, 20),
    sidebarAccent: _hsl(0, 0, 96),
    sidebarAccentForeground: _hsl(0, 0, 20),
    sidebarBorder: _hsl(0, 0, 92),
    mainMutedOverlay: _hsl(0, 0, 96).withValues(alpha: 0.35),
    cardBackground: _hsl(0, 0, 100),
    popoverBackground: _hsl(0, 0, 100),
    destructive: _hsl(0, 72, 58),
    success: _hsl(142, 71, 45),
    mutedSolid: _hsl(0, 0, 96),
  );

  static final EatOsShellTheme dark = EatOsShellTheme(
    sidebarBackground: _hsl(240, 10, 8),
    sidebarForeground: _hsl(0, 0, 95),
    sidebarAccent: _hsl(240, 5, 22),
    sidebarAccentForeground: _hsl(0, 0, 95),
    sidebarBorder: _hsl(240, 4, 27),
    mainMutedOverlay: _hsl(240, 4, 16).withValues(alpha: 0.45),
    cardBackground: _hsl(240, 6, 12),
    popoverBackground: _hsl(240, 6, 12),
    destructive: _hsl(0, 62, 50),
    success: _hsl(142, 71, 45),
    mutedSolid: _hsl(240, 4, 18),
  );

  static EatOsShellTheme of(BuildContext context) {
    return Theme.of(context).extension<EatOsShellTheme>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  static Color _hsl(double h, double s, double l) {
    return HSLColor.fromAHSL(1, h, s / 100, l / 100).toColor();
  }

  @override
  EatOsShellTheme copyWith({
    Color? sidebarBackground,
    Color? sidebarForeground,
    Color? sidebarAccent,
    Color? sidebarAccentForeground,
    Color? sidebarBorder,
    Color? mainMutedOverlay,
    Color? cardBackground,
    Color? popoverBackground,
    Color? destructive,
    Color? success,
    Color? mutedSolid,
  }) {
    return EatOsShellTheme(
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarForeground: sidebarForeground ?? this.sidebarForeground,
      sidebarAccent: sidebarAccent ?? this.sidebarAccent,
      sidebarAccentForeground: sidebarAccentForeground ?? this.sidebarAccentForeground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      mainMutedOverlay: mainMutedOverlay ?? this.mainMutedOverlay,
      cardBackground: cardBackground ?? this.cardBackground,
      popoverBackground: popoverBackground ?? this.popoverBackground,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      mutedSolid: mutedSolid ?? this.mutedSolid,
    );
  }

  @override
  EatOsShellTheme lerp(ThemeExtension<EatOsShellTheme>? other, double t) {
    if (other is! EatOsShellTheme) return this;
    return EatOsShellTheme(
      sidebarBackground: Color.lerp(sidebarBackground, other.sidebarBackground, t)!,
      sidebarForeground: Color.lerp(sidebarForeground, other.sidebarForeground, t)!,
      sidebarAccent: Color.lerp(sidebarAccent, other.sidebarAccent, t)!,
      sidebarAccentForeground: Color.lerp(sidebarAccentForeground, other.sidebarAccentForeground, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      mainMutedOverlay: Color.lerp(mainMutedOverlay, other.mainMutedOverlay, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      popoverBackground: Color.lerp(popoverBackground, other.popoverBackground, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
      mutedSolid: Color.lerp(mutedSolid, other.mutedSolid, t)!,
    );
  }
}
