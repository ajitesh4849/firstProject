import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';

Future<void> openLegalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (ok) return;
    // Fallback: in-app browser tab (works better on some devices).
    final okInApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (okInApp) return;
  } catch (_) {
    // fall through to message
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Could not open the website. Check that the marketing site is running '
        '(port 3000) or set LEGAL_BASE_URL. Tried: $url',
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

Future<void> openPrivacyPolicy(BuildContext context) =>
    openLegalUrl(context, ApiConfig.privacyUrl);

Future<void> openTermsOfUse(BuildContext context) =>
    openLegalUrl(context, ApiConfig.termsUrl);
