import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/shell_theme.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/pointer_glow_layer.dart';
import '../widgets/dashboard/simple_footer.dart';
import '../widgets/sidebar/app_sidebar.dart';

/// App chrome matching [eatos-live-dashboard/src/components/dashboard-layout.tsx].
class DashboardShell extends StatefulWidget {
  const DashboardShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _collapsed = false;

  static const double _mobileBreakpoint = 768;

  void _toggleSidebar() {
    setState(() => _collapsed = !_collapsed);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < _mobileBreakpoint;
    final p = EatOsPalette.of(context);
    final shell = EatOsShellTheme.of(context);
    final mainBg = Color.alphaBlend(shell.mainMutedOverlay, p.background);

    final sidebarWidth = _collapsed ? 56.0 : 256.0;

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isMobile)
          AppSidebar(
            collapsed: _collapsed,
            onToggle: _toggleSidebar,
            width: sidebarWidth,
          ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              const PointerGlowLayer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardHeader(
                    showMenuButton: isMobile || _collapsed,
                    onMenu: isMobile ? _openDrawer : _toggleSidebar,
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: mainBg,
                      child: widget.child,
                    ),
                  ),
                  const SimpleFooter(),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile
          ? Drawer(
              width: 280,
              backgroundColor: shell.sidebarBackground,
              child: AppSidebar(
                collapsed: false,
                onToggle: () => Navigator.of(context).pop(),
                width: 280,
                isDrawer: true,
              ),
            )
          : null,
      body: body,
    );
  }
}
