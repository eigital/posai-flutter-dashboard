import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../bootstrap/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/shell_theme.dart';
import '../../theme/theme_controller.dart';
import '../../theme/theme_scope.dart';
import 'dashboard_header_assets.dart';

/// Matches React [ALL_LOCATIONS_ID] (`eatos-live-dashboard/src/services/storeApi.ts`).
const String _kAllLocationsId = '*';

class _MockStore {
  const _MockStore({required this.id, required this.name});
  final String id;
  final String name;
}

/// Sticky top bar matching [eatos-live-dashboard/src/components/dashboard-header.tsx].
class DashboardHeader extends StatefulWidget {
  const DashboardHeader({
    super.key,
    required this.showMenuButton,
    required this.onMenu,
  });

  final bool showMenuButton;
  final VoidCallback onMenu;

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  static const List<_MockStore> _mockStores = [
    _MockStore(id: 'main', name: 'Main Location'),
    _MockStore(id: 'downtown', name: 'Downtown'),
    _MockStore(id: 'airport', name: 'Airport'),
  ];

  /// Selected scope: `*` = All Locations, else store [id].
  String _selectedLocationId = _kAllLocationsId;

  void _showAiSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => const Padding(
        padding: EdgeInsets.all(24),
        child: Text('AI Assistant (placeholder)'),
      ),
    );
  }

  List<_MockStore> get _locationMenuRows {
    if (_mockStores.length <= 1) {
      return List<_MockStore>.from(_mockStores);
    }
    return [
      const _MockStore(id: _kAllLocationsId, name: 'All Locations'),
      ..._mockStores,
    ];
  }

  String get _locationTriggerLabel {
    if (_selectedLocationId == _kAllLocationsId) {
      return 'All Locations';
    }
    for (final s in _mockStores) {
      if (s.id == _selectedLocationId) {
        return s.name;
      }
    }
    return 'Location';
  }

  bool _showCurrentForRow(_MockStore row) {
    if (row.id == _kAllLocationsId) {
      return _selectedLocationId == _kAllLocationsId;
    }
    return _selectedLocationId == row.id;
  }

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final shell = EatOsShellTheme.of(context);
    final themeController = ThemeControllerScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;
    final iconColor = _headerActionIconColor(context);

    return Material(
      color: shell.cardBackground,
      elevation: 0,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: Row(
          children: [
            if (widget.showMenuButton)
              IconButton(
                onPressed: widget.onMenu,
                icon: Icon(Icons.menu, size: 20, color: iconColor),
                tooltip: 'Toggle sidebar',
              ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _LocationSelectorButton(
                    triggerLabel: _locationTriggerLabel,
                    rows: _locationMenuRows,
                    palette: p,
                    iconColor: iconColor,
                    showCurrentForRow: _showCurrentForRow,
                    onSelect: (id) => setState(() => _selectedLocationId = id),
                    onAddLocation: () {
                      if (context.mounted) context.go('/account');
                    },
                  ),
                ),
              ),
            ),
            if (!isMobile)
              _DesktopActions(
                themeController: themeController,
                onAiTap: () => _showAiSheet(context),
              ),
            if (isMobile)
              _MobileActions(
                onAiTap: () => _showAiSheet(context),
                themeController: themeController,
              ),
          ],
        ),
      ),
    );
  }
}

Color _headerActionIconColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : EatOsPalette.of(context).foreground;
}

/// PNG toolbar assets: white in dark mode except [fullColorInDark] (AI logo).
Widget _headerAssetPng(
  BuildContext context, {
  required String assetPath,
  double size = 24,
  bool fullColorInDark = false,
  IconData fallbackIcon = Icons.image_not_supported_outlined,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final tintWhite = dark && !fullColorInDark;
  return Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    color: tintWhite ? Colors.white : null,
    colorBlendMode: tintWhite ? BlendMode.srcIn : null,
    errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, size: size * 0.85, color: _headerActionIconColor(context)),
  );
}

class _LocationSelectorButton extends StatelessWidget {
  const _LocationSelectorButton({
    required this.triggerLabel,
    required this.rows,
    required this.palette,
    required this.iconColor,
    required this.showCurrentForRow,
    required this.onSelect,
    required this.onAddLocation,
  });

  final String triggerLabel;
  final List<_MockStore> rows;
  final EatOsPalette palette;
  final Color iconColor;
  final bool Function(_MockStore row) showCurrentForRow;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddLocation;

  static const double _triggerHeight = 40;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      tooltip: 'Select location',
      child: Container(
        height: _triggerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                triggerLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: palette.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: iconColor),
          ],
        ),
      ),
      itemBuilder: (context) {
        final entries = <PopupMenuEntry<String>>[];
        for (final row in rows) {
          entries.add(
            PopupMenuItem<String>(
              value: row.id,
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: palette.foreground),
                  const SizedBox(width: 8),
                  Expanded(child: Text(row.name)),
                  if (showCurrentForRow(row))
                    Text(
                      'Current',
                      style: TextStyle(fontSize: 12, color: palette.mutedForeground),
                    ),
                ],
              ),
            ),
          );
        }
        entries.add(const PopupMenuDivider());
        entries.add(
          PopupMenuItem<String>(
            value: '__add_location__',
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: palette.foreground),
                const SizedBox(width: 8),
                const Text('Add a new location'),
              ],
            ),
          ),
        );
        return entries;
      },
      onSelected: (value) {
        if (value == '__add_location__') {
          onAddLocation();
        } else {
          onSelect(value);
        }
      },
    );
  }
}

class _DesktopActions extends StatelessWidget {
  const _DesktopActions({
    required this.themeController,
    required this.onAiTap,
  });

  final ThemeController themeController;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = _headerActionIconColor(context);

    Widget iconBtn({required IconData icon, required String tip, VoidCallback? onPressed}) {
      return IconButton(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 22, color: iconColor),
        tooltip: tip,
      );
    }

    Widget statusChip(String asset, String tip) {
      final p = EatOsPalette.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Tooltip(
            message: tip,
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: p.border.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.5),
              ),
              child: _headerAssetPng(context, assetPath: asset, size: 24),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBtn(icon: Icons.search, tip: 'Search'),
        IconButton(
          onPressed: onAiTap,
          tooltip: 'AI Assistant',
          icon: _headerAssetPng(
            context,
            assetPath: kHeaderAiAssistant,
            size: 24,
            fullColorInDark: true,
            fallbackIcon: Icons.auto_awesome,
          ),
        ),
        statusChip(kHeaderStatusRed, 'Status'),
        statusChip(kHeaderStatusBlue, 'Status'),
        statusChip(kHeaderStatusPink, 'Status'),
        iconBtn(icon: Icons.wb_cloudy_outlined, tip: 'Weather'),
        iconBtn(icon: Icons.notifications_none_rounded, tip: 'Notifications'),
        IconButton(
          onPressed: () {},
          tooltip: 'Profile',
          icon: _headerAssetPng(
            context,
            assetPath: kHeaderProfile,
            size: 24,
            fallbackIcon: Icons.account_circle_outlined,
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Support',
          icon: _headerAssetPng(
            context,
            assetPath: kHeaderSupport,
            size: 24,
            fallbackIcon: Icons.headset_mic_outlined,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.person_outline, color: iconColor),
          onSelected: (v) async {
            if (v == 'logout') {
              await authRepository.logout();
              authRefresh.notifyAuthChanged();
              if (context.mounted) context.go('/login');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'logout', child: Text('Log out')),
          ],
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.language, size: 20, color: iconColor),
          onSelected: (_) {},
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'es', child: Text('Español')),
          ],
        ),
        PopupMenuButton<ThemeMode>(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            size: 20,
            color: iconColor,
          ),
          onSelected: (mode) => themeController.mode = mode,
          itemBuilder: (context) => const [
            PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
            PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            PopupMenuItem(value: ThemeMode.system, child: Text('System')),
          ],
        ),
      ],
    );
  }
}

class _MobileActions extends StatelessWidget {
  const _MobileActions({
    required this.onAiTap,
    required this.themeController,
  });

  final VoidCallback onAiTap;
  final ThemeController themeController;

  static const double _thumb = 20;

  @override
  Widget build(BuildContext context) {
    final iconColor = _headerActionIconColor(context);

    Future<void> logout() async {
      await authRepository.logout();
      authRefresh.notifyAuthChanged();
      if (context.mounted) context.go('/login');
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: iconColor),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'ai',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(
                context,
                assetPath: kHeaderAiAssistant,
                size: _thumb,
                fullColorInDark: true,
              ),
            ),
            title: const Text('AI Assistant'),
          ),
        ),
        PopupMenuItem(
          value: 'red',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(context, assetPath: kHeaderStatusRed, size: _thumb),
            ),
            title: const Text('Status'),
          ),
        ),
        PopupMenuItem(
          value: 'blue',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(context, assetPath: kHeaderStatusBlue, size: _thumb),
            ),
            title: const Text('Status'),
          ),
        ),
        PopupMenuItem(
          value: 'pink',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(context, assetPath: kHeaderStatusPink, size: _thumb),
            ),
            title: const Text('Status'),
          ),
        ),
        PopupMenuItem(
          value: 'weather',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.wb_cloudy_outlined, size: 22, color: iconColor),
            title: const Text('Weather'),
          ),
        ),
        PopupMenuItem(
          value: 'notifications',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.notifications_none_rounded, size: 22, color: iconColor),
            title: const Text('Notifications'),
          ),
        ),
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(context, assetPath: kHeaderProfile, size: _thumb),
            ),
            title: const Text('Profile'),
          ),
        ),
        PopupMenuItem(
          value: 'support',
          child: ListTile(
            dense: true,
            leading: SizedBox(
              width: _thumb,
              height: _thumb,
              child: _headerAssetPng(context, assetPath: kHeaderSupport, size: _thumb),
            ),
            title: const Text('Support'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'lang_en', child: Text('English')),
        const PopupMenuItem(value: 'lang_es', child: Text('Español')),
        const PopupMenuItem(
          value: 'theme_light',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.light_mode_outlined),
            title: Text('Theme: Light'),
          ),
        ),
        const PopupMenuItem(
          value: 'theme_dark',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.dark_mode_outlined),
            title: Text('Theme: Dark'),
          ),
        ),
        const PopupMenuItem(
          value: 'theme_system',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.brightness_auto_outlined),
            title: Text('Theme: System'),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Log out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
      onSelected: (v) async {
        switch (v) {
          case 'ai':
            onAiTap();
            break;
          case 'logout':
            await logout();
            break;
          case 'theme_light':
            themeController.setLight();
            break;
          case 'theme_dark':
            themeController.setDark();
            break;
          case 'theme_system':
            themeController.mode = ThemeMode.system;
            break;
          default:
            break;
        }
      },
    );
  }
}
