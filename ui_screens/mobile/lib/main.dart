import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_navigator.dart';
import 'routes/app_routes.dart';
import 'services/api_client.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await apiClient.loadSession();
  runApp(const FoodScanApp());
}

class FoodScanApp extends StatefulWidget {
  const FoodScanApp({super.key});

  @override
  State<FoodScanApp> createState() => _FoodScanAppState();
}

class _FoodScanAppState extends State<FoodScanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // After background / Wi‑Fi changes, drop stale sockets so the next API call reconnects.
    if (state == AppLifecycleState.resumed) {
      apiClient.resetHttpClient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(maxScaleFactor: 1.25),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
