import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class PackagedBarcodeScreen extends StatefulWidget {
  const PackagedBarcodeScreen({super.key});

  @override
  State<PackagedBarcodeScreen> createState() => _PackagedBarcodeScreenState();
}

class _PackagedBarcodeScreenState extends State<PackagedBarcodeScreen> {
  final _manualController = TextEditingController();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    autoStart: true,
  );
  bool _busy = false;
  bool _handled = false;
  String? _error;
  String? _lastBarcode;

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  String _digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  Future<void> _pauseScanner() async {
    try {
      await _scannerController.stop();
    } catch (_) {}
  }

  Future<void> _resumeScanner() async {
    try {
      await _scannerController.start();
    } catch (_) {}
  }

  Future<void> _analyze(String barcode, {required bool fromScanner}) async {
    final cleaned = _digitsOnly(barcode);
    if (cleaned.length < 8 || cleaned.length > 14) {
      setState(() {
        _error = 'Enter a valid barcode (8–14 digits).';
        _busy = false;
        _handled = false;
      });
      if (fromScanner) await _resumeScanner();
      return;
    }
    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
      _handled = true;
      _lastBarcode = cleaned;
      _manualController.text = cleaned;
    });

    if (fromScanner) {
      await _pauseScanner();
    }

    try {
      final result = await foodApi.analyzePackagedBarcode(cleaned);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.packagedResult,
        arguments: result,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      final message = switch (error.statusCode) {
        404 => 'Product not found for this barcode. Try another pack or enter digits manually.',
        502 || 503 => 'Product database is temporarily unavailable. Try again in a moment.',
        _ => error.message,
      };
      setState(() {
        _busy = false;
        _error = message;
      });
      // Keep camera paused until user taps Try again — avoids blink/retry loop.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'Could not reach the server. Check Wi‑Fi and that the backend is running.';
      });
    }
  }

  Future<void> _tryAgain() async {
    setState(() {
      _error = null;
      _handled = false;
      _busy = false;
    });
    await _resumeScanner();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy || _handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map(_digitsOnly)
        .firstWhere(
          (v) => v.length >= 8 && v.length <= 14,
          orElse: () => '',
        );
    if (raw.isEmpty) return;
    // Ignore duplicate rapid callbacks for the same code.
    if (raw == _lastBarcode && _error != null) return;
    _handled = true;
    unawaited(_analyze(raw, fromScanner: true));
  }

  @override
  Widget build(BuildContext context) {
    final showRetry = _error != null && !_busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Packaged food')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Scan a barcode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'We’ll look up the product and flag common unhealthy ingredients using rules (no AI).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      if (_busy)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                'Checking product…',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      if (showRetry)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _tryAgain,
                                child: const Text('Scan again'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _manualController,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Or enter barcode manually',
                  hintText: 'e.g. 3017620422003',
                  prefixIcon: Icon(Icons.qr_code_2_outlined),
                ),
              ),
              if (_error != null && !showRetry) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Analyze barcode',
                isLoading: _busy,
                onPressed: () => _analyze(
                  _manualController.text,
                  fromScanner: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
