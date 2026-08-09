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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: current.index,
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
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
