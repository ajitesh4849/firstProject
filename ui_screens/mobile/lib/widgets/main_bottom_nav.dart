import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/app_theme.dart';

enum MainTab { home, history, profile }

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key, required this.current});

  final MainTab current;

  void _go(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current.index,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      onDestinationSelected: (index) {
        final tab = MainTab.values[index];
        if (tab == current) return;

        switch (tab) {
          case MainTab.home:
            _go(context, AppRoutes.home);
          case MainTab.history:
            _go(context, AppRoutes.history);
          case MainTab.profile:
            _go(context, AppRoutes.profile);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
