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
  );
  bool _busy = false;
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _analyze(String barcode) async {
    final cleaned = barcode.trim();
    if (cleaned.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

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
      setState(() {
        _busy = false;
        _handled = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _handled = false;
        _error = 'Could not analyze this barcode right now.';
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy || _handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map((v) => v.trim())
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (raw.isEmpty) return;
    _handled = true;
    _analyze(raw);
  }

  @override
  Widget build(BuildContext context) {
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
                          color: Colors.black45,
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
                  hintText: 'e.g. 8901030865268',
                  prefixIcon: Icon(Icons.qr_code_2_outlined),
                ),
              ),
              if (_error != null) ...[
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
                onPressed: () => _analyze(_manualController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
