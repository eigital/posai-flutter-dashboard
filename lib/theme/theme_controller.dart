import 'package:flutter/material.dart';

/// Drives [ThemeMode] for MaterialApp (light / dark / system).
class ThemeController extends ChangeNotifier {
  ThemeController([ThemeMode initial = ThemeMode.system]) : _mode = initial;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  set mode(ThemeMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  void setLight() => mode = ThemeMode.light;

  void setDark() => mode = ThemeMode.dark;

  void setSystem() => mode = ThemeMode.system;
}
