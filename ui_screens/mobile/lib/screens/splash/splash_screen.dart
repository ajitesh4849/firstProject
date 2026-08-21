import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(AppConstants.splashDelay);
    if (!mounted) return;

    final token = apiClient.accessToken;
    if (token == null || token.isEmpty) {
      setState(() => _checkingSession = false);
      return;
    }

    try {
      await foodApi.fetchProfile();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await apiClient.clearSession();
      }
      if (!mounted) return;
      setState(() => _checkingSession = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingSession = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5F2),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        width: 112,
                        height: 112,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.soft,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 52,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppConstants.tagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                      ),
                      const Spacer(flex: 3),
                      if (_checkingSession)
                        const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                      else ...[
                        PrimaryButton(
                          label: apiClient.accessToken?.isNotEmpty == true
                              ? 'Continue'
                              : 'Get Started',
                          onPressed: () {
                            final hasToken =
                                apiClient.accessToken?.isNotEmpty == true;
                            Navigator.pushReplacementNamed(
                              context,
                              hasToken ? AppRoutes.home : AppRoutes.login,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Private by design. Your meals stay with you.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
