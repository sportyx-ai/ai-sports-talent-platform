import "dart:async";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

class ApiConfig {
  // Configured via: flutter run --dart-define=API_BASE_URL=http://...
  static const String _envBaseUrl = String.fromEnvironment("API_BASE_URL");
  static String? customBaseUrl;

  // Host machine local IPv4 LAN address
  static const String hostLanIp = "10.190.51.170";

  // Production URL (HTTPS)
  static const String productionBaseUrl = "https://api.sportyx.com";

  static const List<String> candidateUrls = [
    "http://127.0.0.1:8080",
    "http://localhost:8080",
    "http://10.190.51.170:8080",
    "http://10.0.2.2:8080",
  ];

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return normalizeUrl(customBaseUrl!);
    }
    if (_envBaseUrl.isNotEmpty) {
      return normalizeUrl(_envBaseUrl);
    }
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    // Default development URL: 127.0.0.1:8080 (works with USB adb reverse, desktop, and web)
    return "http://127.0.0.1:8080";
  }

  static void setBaseUrl(String url) {
    customBaseUrl = normalizeUrl(url);
  }

  /// Automatically tests candidate server URLs using the fast /api/health endpoint.
  static Future<String?> autoDetectServer() async {
    final list = <String>[
      if (customBaseUrl != null && customBaseUrl!.isNotEmpty) customBaseUrl!,
      ...candidateUrls,
    ];

    for (final url in list) {
      try {
        final uri = Uri.parse("${normalizeUrl(url)}/api/health");
        final response = await http.get(uri).timeout(const Duration(milliseconds: 1500));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final chosen = normalizeUrl(url);
          setBaseUrl(chosen);
          if (kDebugMode) {
            debugPrint("Connected to backend: $chosen");
          }
          return chosen;
        }
      } catch (_) {
        // continue probing next candidate
      }
    }
    return null;
  }

  static String normalizeUrl(String rawUrl) {
    final value = rawUrl.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) {
      return value;
    }

    final hasExplicitPort = value.contains(RegExp(r":\d+($|/)"));
    if (hasExplicitPort) {
      return value;
    }

    final scheme = uri.scheme.isEmpty ? "http" : uri.scheme;
    return "$scheme://${uri.host}:8080";
  }
}
