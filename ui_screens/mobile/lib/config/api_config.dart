import 'dart:io';

/// Backend + legal site URLs.
///
/// Dev defaults:
/// - Android emulator → host via 10.0.2.2
/// - iOS simulator / desktop → localhost
///
/// Production / physical device — always pass dart-defines:
/// ```
/// flutter run \
///   --dart-define=API_BASE_URL=https://api.yourdomain.com \
///   --dart-define=LEGAL_BASE_URL=https://yourdomain.com
/// ```
class ApiConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://127.0.0.1:8080';
  }

  /// Marketing / legal site (privacy + terms).
  static String get legalBaseUrl {
    const fromEnv = String.fromEnvironment('LEGAL_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
    return 'http://127.0.0.1:3000';
  }

  static String get privacyUrl => '$legalBaseUrl/privacy';
  static String get termsUrl => '$legalBaseUrl/terms';

  static const Duration timeout = Duration(seconds: 25);
  /// Photo scan / label upload: allow vision model time, but fail before feeling stuck.
  static const Duration scanTimeout = Duration(seconds: 40);
  static const Duration connectTimeout = Duration(seconds: 8);
}
