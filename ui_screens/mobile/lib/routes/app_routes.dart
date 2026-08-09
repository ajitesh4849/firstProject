import 'package:flutter/material.dart';

import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/nutrition/nutrition_screen.dart';
import '../screens/portion/portion_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/result/food_result_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/scan/scanning_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../models/food_item.dart';
import '../models/nutrition_info.dart';
import '../models/scan_image_args.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String scanning = '/scanning';
  static const String foodResult = '/food-result';
  static const String portion = '/portion';
  static const String nutrition = '/nutrition';
  static const String history = '/history';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen(), settings);
      case login:
        return _fade(const LoginScreen(), settings);
      case home:
        return _fade(const HomeScreen(), settings);
      case scan:
        return _slide(const ScanScreen(), settings);
      case scanning:
        final imageArgs = settings.arguments as ScanImageArgs?;
        return _fade(ScanningScreen(imageArgs: imageArgs), settings);
      case foodResult:
        final food = settings.arguments as FoodItem?;
        return _slide(FoodResultScreen(food: food), settings);
      case portion:
        final food = settings.arguments as FoodItem;
        return _slide(PortionScreen(food: food), settings);
      case nutrition:
        final info = settings.arguments as NutritionInfo;
        return _slide(NutritionScreen(nutrition: info), settings);
      case history:
        return _fade(const HistoryScreen(), settings);
      case profile:
        return _fade(const ProfileScreen(), settings);
      default:
        return _fade(
          Scaffold(
            body: Center(child: Text('No route: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}
