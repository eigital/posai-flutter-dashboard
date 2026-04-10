import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Provides [ThemeController] to the widget tree (theme toggle in dashboard header).
class ThemeControllerScope extends InheritedWidget {
  const ThemeControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final ThemeController controller;

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
