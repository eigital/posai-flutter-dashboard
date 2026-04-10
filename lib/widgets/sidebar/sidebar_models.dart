import 'package:flutter/material.dart';

/// Sidebar section + item matching [eatos-live-dashboard/src/components/app-sidebar.tsx].
/// Subitems are not shown in React UI; only parent URLs are linked.
class SidebarSectionModel {
  const SidebarSectionModel({
    required this.title,
    required this.items,
  });

  final String title;
  final List<SidebarItemModel> items;
}

class SidebarItemModel {
  const SidebarItemModel({
    required this.title,
    required this.path,
    required this.icon,
    required this.iconTint,
  });

  final String title;
  final String path;
  final IconData icon;
  final Color iconTint;
}

/// Menu data (colors approximate Tailwind iconColor classes from React).
List<SidebarSectionModel> buildSidebarSections() {
  const orange = Color(0xFFF97316);
  const purple = Color(0xFFA855F7);
  const emerald = Color(0xFF10B981);
  const pink = Color(0xFFEC4899);
  const red = Color(0xFFEF4444);
  const teal = Color(0xFF14B8A6);
  const yellow = Color(0xFFEAB308);
  const gray = Color(0xFF6B7280);

  return [
    SidebarSectionModel(
      title: 'Main',
      items: [
        SidebarItemModel(
          title: 'Dashboard',
          path: '/',
          icon: Icons.bar_chart_rounded,
          iconTint: gray,
        ),
        SidebarItemModel(
          title: 'Analytics & Reports',
          path: '/analytics',
          icon: Icons.pie_chart_outline_rounded,
          iconTint: purple,
        ),
        SidebarItemModel(
          title: 'Website Hierarchy',
          path: '/hierarchy',
          icon: Icons.hub_rounded,
          iconTint: emerald,
        ),
        SidebarItemModel(
          title: 'Sales',
          path: '/sales',
          icon: Icons.trending_up_rounded,
          iconTint: orange,
        ),
      ],
    ),
    SidebarSectionModel(
      title: 'Operations',
      items: [
        SidebarItemModel(
          title: 'Workforce',
          path: '/workforce',
          icon: Icons.people_outline_rounded,
          iconTint: orange,
        ),
        SidebarItemModel(
          title: 'Menu Management',
          path: '/menu',
          icon: Icons.restaurant_menu_rounded,
          iconTint: pink,
        ),
        SidebarItemModel(
          title: 'Guests',
          path: '/guests',
          icon: Icons.people_alt_outlined,
          iconTint: purple,
        ),
      ],
    ),
    SidebarSectionModel(
      title: 'Setup',
      items: [
        SidebarItemModel(
          title: 'Restaurant',
          path: '/restaurant',
          icon: Icons.restaurant_rounded,
          iconTint: pink,
        ),
        SidebarItemModel(
          title: 'Online Ordering',
          path: '/online-ordering',
          icon: Icons.shopping_cart_outlined,
          iconTint: red,
        ),
        SidebarItemModel(
          title: 'Reservation',
          path: '/reservation',
          icon: Icons.calendar_today_outlined,
          iconTint: teal,
        ),
        SidebarItemModel(
          title: 'Hardware',
          path: '/hardware',
          icon: Icons.bolt_rounded,
          iconTint: purple,
        ),
        SidebarItemModel(
          title: 'Integrations',
          path: '/integrations',
          icon: Icons.shield_outlined,
          iconTint: purple,
        ),
      ],
    ),
    SidebarSectionModel(
      title: 'Global Settings',
      items: [
        SidebarItemModel(
          title: 'Account Settings',
          path: '/account',
          icon: Icons.settings_outlined,
          iconTint: orange,
        ),
        SidebarItemModel(
          title: 'Activity Logs',
          path: '/activity',
          icon: Icons.description_outlined,
          iconTint: orange,
        ),
        SidebarItemModel(
          title: 'Referral Program',
          path: '/referral',
          icon: Icons.star_outline_rounded,
          iconTint: purple,
        ),
        SidebarItemModel(
          title: 'Device Logs',
          path: '/devices',
          icon: Icons.storage_rounded,
          iconTint: purple,
        ),
      ],
    ),
    SidebarSectionModel(
      title: 'Support',
      items: [
        SidebarItemModel(
          title: 'Chat with us',
          path: '/support/chat',
          icon: Icons.chat_bubble_outline_rounded,
          iconTint: yellow,
        ),
        SidebarItemModel(
          title: 'Support Tickets',
          path: '/support/tickets',
          icon: Icons.description_outlined,
          iconTint: pink,
        ),
        SidebarItemModel(
          title: 'Backups',
          path: '/backups',
          icon: Icons.restore_rounded,
          iconTint: orange,
        ),
      ],
    ),
  ];
}

/// All non-root shell paths for placeholder [GoRoute]s (leading slash).
const List<String> kShellPlaceholderPaths = [
  '/analytics',
  '/hierarchy',
  '/sales',
  '/workforce',
  '/menu',
  '/guests',
  '/restaurant',
  '/online-ordering',
  '/reservation',
  '/hardware',
  '/integrations',
  '/account',
  '/activity',
  '/referral',
  '/devices',
  '/support/chat',
  '/support/tickets',
  '/backups',
  '/sales-transaction',
];
