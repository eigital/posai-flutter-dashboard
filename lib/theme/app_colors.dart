import 'package:flutter/material.dart';

/// eatOS design tokens from [eatos-live-dashboard/src/index.css] (`:root` / `.dark` HSL).
@immutable
class EatOsPalette {
  const EatOsPalette({
    required this.background,
    required this.foreground,
    required this.primary,
    required this.mutedForeground,
    required this.border,
    required this.input,
  });

  final Color background;
  final Color foreground;
  final Color primary;
  final Color mutedForeground;
  final Color border;
  final Color input;

  /// `:root` in index.css
  static final EatOsPalette light = EatOsPalette(
    background: _hsl(0, 0, 98),
    foreground: _hsl(0, 0, 15),
    primary: _hsl(0, 0, 20),
    mutedForeground: _hsl(0, 0, 50),
    border: _hsl(0, 0, 90),
    input: _hsl(0, 0, 90),
  );

  /// `.dark` in index.css
  static final EatOsPalette dark = EatOsPalette(
    background: _hsl(240, 10, 8),
    foreground: _hsl(0, 0, 95),
    primary: _hsl(0, 0, 95),
    mutedForeground: _hsl(240, 4, 68),
    border: _hsl(240, 4, 27),
    input: _hsl(240, 4, 27),
  );

  static EatOsPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static Color _hsl(double h, double s, double l) {
    return HSLColor.fromAHSL(1, h, s / 100, l / 100).toColor();
  }
}
