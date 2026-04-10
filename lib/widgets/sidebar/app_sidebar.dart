import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/login_assets.dart';
import '../../theme/shell_theme.dart';
import 'sidebar_models.dart';

/// Matches [eatos-live-dashboard/src/components/app-sidebar.tsx] (no DashboardSwitcher).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
    required this.width,
    this.isDrawer = false,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final double width;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final theme = Theme.of(context);
    final logoAsset = theme.brightness == Brightness.dark ? loginLogoDark : loginLogoLight;
    final sections = buildSidebarSections();

    return Material(
      color: shell.sidebarBackground,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SidebarHeader(
              collapsed: collapsed,
              logoAsset: logoAsset,
              onToggle: onToggle,
              borderColor: shell.sidebarBorder,
              isDrawer: isDrawer,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final section in sections) ...[
                    if (!collapsed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: Text(
                          section.title.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                            color: shell.sidebarForeground.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    for (final item in section.items)
                      _SidebarNavTile(
                        item: item,
                        collapsed: collapsed,
                        onTap: () {
                          if (isDrawer) Navigator.of(context).pop();
                          context.go(item.path);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.collapsed,
    required this.logoAsset,
    required this.onToggle,
    required this.borderColor,
    required this.isDrawer,
  });

  final bool collapsed;
  final String logoAsset;
  final VoidCallback onToggle;
  final Color borderColor;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: collapsed ? const EdgeInsets.symmetric(horizontal: 8) : const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.go('/'),
              child: collapsed
                  ? Center(
                      child: Image.asset(
                        logoAsset,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu, size: 24),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        logoAsset,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text('eatOS'),
                      ),
                    ),
            ),
          ),
          if (isDrawer)
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.close, size: 22),
              tooltip: 'Close',
            )
          else if (!collapsed)
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.menu, size: 20),
              tooltip: 'Toggle sidebar',
            ),
        ],
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.item,
    required this.collapsed,
    required this.onTap,
  });

  final SidebarItemModel item;
  final bool collapsed;
  final VoidCallback onTap;

  bool _active(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (item.path == '/') {
      return loc == '/' || loc.isEmpty;
    }
    return loc == item.path || loc.startsWith('${item.path}/');
  }

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final active = _active(context);
    final bg = active ? shell.sidebarAccent : Colors.transparent;
    final fg = active ? shell.sidebarAccentForeground : shell.sidebarForeground.withValues(alpha: 0.82);
    final iconColor = active ? const Color(0xFFF97316) : item.iconTint;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 4 : 8, vertical: collapsed ? 4 : 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
              vertical: collapsed ? 12 : 10,
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(item.icon, size: collapsed ? 18 : 22, color: iconColor),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: fg,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
