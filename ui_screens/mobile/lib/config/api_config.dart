import 'dart:io';

/// Backend base URL.
///
/// Android emulator → host machine via 10.0.2.2
/// iOS simulator / desktop → localhost
/// Override: `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080`
class ApiConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://127.0.0.1:8080';
  }

  static const Duration timeout = Duration(seconds: 25);
  /// Photo scan / label upload: allow vision model time, but fail before feeling stuck.
  static const Duration scanTimeout = Duration(seconds: 40);
  static const Duration connectTimeout = Duration(seconds: 8);
}
