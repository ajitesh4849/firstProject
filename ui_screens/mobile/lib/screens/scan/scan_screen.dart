import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/scan_image_args.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _previewBytes;
  String _filename = 'meal.jpg';
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _previewBytes = bytes;
        _filename = file.name.isNotEmpty ? file.name : 'meal.jpg';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera or gallery unavailable. Check permissions.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startScan() {
    final bytes = _previewBytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Take or choose a food photo first')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.scanning,
      arguments: ScanImageArgs(
        bytes: bytes,
        filename: _filename,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    color: const Color(0xFF101714),
                    boxShadow: AppShadows.soft,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_previewBytes == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Capture your meal',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use clear lighting and fill the frame',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        )
                      else
                        Image.memory(
                          _previewBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ViewfinderPainter(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Camera',
                      icon: Icons.photo_camera_outlined,
                      isLoading: _busy,
                      onPressed: () => _pick(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      isLoading: _busy,
                      onPressed: () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Analyze Food',
                icon: Icons.document_scanner_outlined,
                onPressed: _busy ? null : _startScan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const inset = 28.0;
    const len = 28.0;
    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    // Top-left
    canvas.drawLine(Offset(left, top), Offset(left + len, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), paint);
    // Top-right
    canvas.drawLine(Offset(right, top), Offset(right - len, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}
