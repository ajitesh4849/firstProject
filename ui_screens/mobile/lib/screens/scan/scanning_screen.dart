import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/food_image_placeholder.dart';
import '../../widgets/ux_states.dart';

enum _ScanPhase { loading, error }

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  _ScanPhase _phase = _ScanPhase.loading;
  String _status = 'Detecting food...';

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    setState(() {
      _phase = _ScanPhase.loading;
      _status = 'Detecting food...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _status = 'Estimating calories...');

    await Future<void>.delayed(AppConstants.scanningDelay);
    if (!mounted) return;

    if (MockDataService.forceNextScanFailure) {
      MockDataService.forceNextScanFailure = false;
      setState(() => _phase = _ScanPhase.error);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.foodResult,
      arguments: MockDataService.detectedFood,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanning'),
        automaticallyImplyLeading: false,
        actions: [
          if (_phase == _ScanPhase.loading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _phase == _ScanPhase.error
              ? ErrorState(
                  title: 'Could not detect food',
                  message:
                      'We could not identify this image. Try again with better lighting or a clearer photo.',
                  onRetry: _runSimulation,
                  onSecondary: () => Navigator.pop(context),
                  secondaryLabel: 'Back to camera',
                )
              : Column(
                  children: [
                    const FoodImagePlaceholder(
                      height: 260,
                      icon: Icons.image_search_rounded,
                      label: 'Analyzing image',
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tip: open Scan and long-press Scan Food to simulate failure',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
