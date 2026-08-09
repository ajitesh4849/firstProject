import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1A1F1C),
                        Color(0xFF2A3530),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 72,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera Preview',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placeholder for Phase 1',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 36,
                        top: 36,
                        child: _Corner(color: AppColors.accent),
                      ),
                      Positioned(
                        right: 36,
                        top: 36,
                        child: Transform.rotate(
                          angle: 1.5708,
                          child: _Corner(color: AppColors.accent),
                        ),
                      ),
                      Positioned(
                        left: 36,
                        bottom: 36,
                        child: Transform.rotate(
                          angle: -1.5708,
                          child: _Corner(color: AppColors.accent),
                        ),
                      ),
                      Positioned(
                        right: 36,
                        bottom: 36,
                        child: Transform.rotate(
                          angle: 3.1416,
                          child: _Corner(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Point camera at your food',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onLongPress: () {
                  MockDataService.forceNextScanFailure = true;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Next scan will simulate a detection error'),
                    ),
                  );
                  Navigator.pushNamed(context, AppRoutes.scanning);
                },
                child: PrimaryButton(
                  label: 'Scan Food',
                  icon: Icons.document_scanner_outlined,
                  onPressed: () {
                    MockDataService.forceNextScanFailure = false;
                    Navigator.pushNamed(context, AppRoutes.scanning);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _CornerPainter(color)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.65, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
