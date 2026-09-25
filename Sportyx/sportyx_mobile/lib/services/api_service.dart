import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";

import "../core/api_config.dart";

class ApiService {
  static Uri _uri(String path) => Uri.parse("${ApiConfig.baseUrl}$path");

  static const Duration defaultTimeout = Duration(seconds: 12);

  static bool _isNetworkException(dynamic e) {
    if (e is TimeoutException || e is http.ClientException) return true;
    final str = e.toString().toLowerCase();
    return str.contains("timeoutexception") ||
        str.contains("timed out") ||
        str.contains("failed host lookup") ||
        str.contains("connection refused") ||
        str.contains("network is unreachable") ||
        str.contains("future not completed");
  }

  /// Verifies connectivity to the Spring Boot backend
  static Future<bool> checkHealth() async {
    try {
      final res = await http.get(_uri("/api/health")).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> getUpcomingEvents() async {
    try {
      final response = await http.get(_uri("/api/events/upcoming")).timeout(defaultTimeout);
      _ensureSuccess(response);
      return _asList(response.body);
    } catch (e) {
      if (_isNetworkException(e)) {
        final detected = await ApiConfig.autoDetectServer();
        if (detected != null) {
          final retry = await http.get(_uri("/api/events/upcoming")).timeout(defaultTimeout);
          _ensureSuccess(retry);
          return _asList(retry.body);
        }
        throw Exception("Unable to connect to the server. Please check your connection and server settings.");
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> getEventsForAthlete(String athleteId) async {
    final response = await http.get(_uri("/api/athletes/$athleteId/events")).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asList(response.body);
  }

  static Future<Map<String, dynamic>> registerAthleteForEvent({
    required String athleteId,
    required String eventId,
  }) async {
    final response = await http.post(
      _uri("/api/athletes/$athleteId/events/$eventId/register"),
    ).timeout(defaultTimeout);
    _ensureSuccess(response, expected: const [201]);
    return _asMap(response.body);
  }

  static Future<Map<String, dynamic>> updateRegistrationStatus({
    required String athleteId,
    required String eventId,
    required String status,
  }) async {
    final response = await http.patch(
      _uri("/api/athletes/$athleteId/events/$eventId/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    ).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asMap(response.body);
  }

  static Future<List<dynamic>> getManagers() async {
    try {
      final response = await http.get(_uri("/api/managers")).timeout(defaultTimeout);
      _ensureSuccess(response);
      return _asList(response.body);
    } catch (e) {
      if (_isNetworkException(e)) {
        final detected = await ApiConfig.autoDetectServer();
        if (detected != null) {
          final retry = await http.get(_uri("/api/managers")).timeout(defaultTimeout);
          _ensureSuccess(retry);
          return _asList(retry.body);
        }
        throw Exception("Unable to connect to the server. Please check your connection and try again.");
      }
      rethrow;
    }
  }

  /// Uploads an ID Proof document (image) via multipart/form-data
  static Future<Map<String, dynamic>> uploadIdProof(XFile file) async {
    final uri = _uri("/api/managers/upload-id-proof");
    final request = http.MultipartRequest("POST", uri);

    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      "file",
      bytes,
      filename: file.name.isNotEmpty ? file.name : "id_proof.jpg",
    );
    request.files.add(multipartFile);

    try {
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode != 201 && streamed.statusCode != 200) {
        throw Exception("Failed to upload ID proof (${streamed.statusCode})");
      }
      return _asMap(body);
    } catch (e) {
      if (_isNetworkException(e)) {
        throw Exception("Unable to reach server during ID upload. Please check connection.");
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> registerManager({
    required String fullName,
    required String email,
    required String passwordHash,
    required String phone,
    required String organization,
    int? age,
    String? gender,
    String? idNumber,
    String? idProofUrl,
    XFile? idProofFile,
  }) async {
    String? resolvedProofUrl = idProofUrl;
    if (resolvedProofUrl == null && idProofFile != null) {
      try {
        final uploadRes = await uploadIdProof(idProofFile);
        resolvedProofUrl = uploadRes["fileUrl"]?.toString();
      } catch (uploadError) {
        if (kDebugMode) {
          debugPrint("ID proof upload note: $uploadError");
        }
      }
    }

    final payload = jsonEncode({
      "fullName": fullName,
      "email": email,
      "passwordHash": passwordHash,
      "phone": phone,
      "organization": organization,
      "age": age,
      "gender": gender,
      "idNumber": idNumber,
      "idProofUrl": resolvedProofUrl,
      "role": "PT_TEACHER",
      "athletes": [],
    });

    try {
      final response = await http.post(
        _uri("/api/managers/register"),
        headers: {"Content-Type": "application/json"},
        body: payload,
      ).timeout(defaultTimeout);
      _ensureSuccess(response, expected: const [200, 201]);
      return _asMap(response.body);
    } catch (e) {
      if (_isNetworkException(e)) {
        final detected = await ApiConfig.autoDetectServer();
        if (detected != null) {
          try {
            final retry = await http.post(
              _uri("/api/managers/register"),
              headers: {"Content-Type": "application/json"},
              body: payload,
            ).timeout(defaultTimeout);
            _ensureSuccess(retry, expected: const [200, 201]);
            return _asMap(retry.body);
          } catch (inner) {
            if (!_isNetworkException(inner)) rethrow;
          }
        }
        if (kDebugMode) {
          debugPrint("[API DEBUG] Network error on POST /api/managers/register to ${ApiConfig.baseUrl}: $e");
        }
        throw Exception("Unable to connect to the server. Please check your connection and try again.");
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> getAthletesByManager(String managerId) async {
    final response = await http.get(_uri("/api/managers/$managerId/athletes")).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asList(response.body);
  }

  static Future<Map<String, dynamic>> createAthlete({
    required String managerId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      _uri("/api/managers/$managerId/athletes"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    ).timeout(defaultTimeout);
    _ensureSuccess(response, expected: const [201]);
    return _asMap(response.body);
  }

  static Future<Map<String, dynamic>> updateAthlete({
    required String athleteId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.put(
      _uri("/api/athletes/$athleteId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    ).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asMap(response.body);
  }

  static Future<List<dynamic>> getVideosByAthlete(String athleteId) async {
    final response = await http.get(_uri("/api/athletes/$athleteId/videos")).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asList(response.body);
  }

  static Future<List<dynamic>> getAssessmentsByAthlete(String athleteId) async {
    final response = await http.get(_uri("/api/athletes/$athleteId/assessments")).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asList(response.body);
  }

  static Future<Map<String, dynamic>> uploadAthleteImage({
    required String managerId,
    required String filePath,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      _uri("/api/managers/$managerId/athletes/upload-photo"),
    );
    request.files.add(await http.MultipartFile.fromPath("file", filePath));
    request.fields["fileName"] = fileName;

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 201 && streamed.statusCode != 200) {
      throw Exception("API request failed (${streamed.statusCode}): $body");
    }
    return _asMap(body);
  }

  static Future<List<dynamic>> getPendingVideosForAdmin() async {
    final response = await http.get(_uri("/api/videos/pending")).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asList(response.body);
  }

  static Future<Map<String, dynamic>> reviewVideo({
    required String videoId,
    required String status,
    required String feedback,
  }) async {
    final response = await http.patch(
      _uri("/api/videos/$videoId/review"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "status": status,
        "feedback": feedback,
      }),
    ).timeout(defaultTimeout);
    _ensureSuccess(response);
    return _asMap(response.body);
  }

  static Future<Map<String, dynamic>> uploadVideo({
    required String managerId,
    required String athleteId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      _uri("/api/managers/$managerId/athletes/$athleteId/videos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    ).timeout(defaultTimeout);
    _ensureSuccess(response, expected: const [201]);
    return _asMap(response.body);
  }

  static Future<Map<String, dynamic>> uploadVideoFile({
    required String managerId,
    required String athleteId,
    required String filePath,
    required String title,
    required String sportCategory,
    required String skillType,
    int durationSeconds = 60,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint("\n${'=' * 60}");
        debugPrint("🎬 VIDEO UPLOAD DEBUG");
        debugPrint('=' * 60);
        debugPrint("📍 Manager ID: $managerId");
        debugPrint("👤 Athlete ID: $athleteId");
        debugPrint("🎥 Title: $title");
        debugPrint("🏆 Sport: $sportCategory");
        debugPrint('=' * 60);
      }

      final endpoint = "/api/managers/$managerId/athletes/$athleteId/videos/upload";
      final uri = _uri(endpoint);

      final request = http.MultipartRequest("POST", uri);
      final file = await http.MultipartFile.fromPath("file", filePath);
      request.files.add(file);

      request.fields["title"] = title;
      request.fields["sportCategory"] = sportCategory;
      request.fields["skillType"] = skillType;
      request.fields["durationSeconds"] = durationSeconds.toString();

      final streamed = await request.send().timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception("Upload timeout - network too slow or file too large");
        },
      );

      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 201) {
        if (kDebugMode) {
          debugPrint("✅ Video uploaded successfully");
        }
        return _asMap(body);
      } else {
        throw Exception("Upload failed (${streamed.statusCode}): $body");
      }
    } catch (e) {
      if (e.toString().contains("timeout")) {
        throw Exception("Video upload timed out. Check network connection.");
      }
      rethrow;
    }
  }

  static List<dynamic> _asList(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List<dynamic>) {
        return decoded;
      }
    } catch (_) {}
    throw Exception("Unexpected server response format.");
  }

  static Map<String, dynamic> _asMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    throw Exception("Unexpected server response format.");
  }

  static void _ensureSuccess(http.Response response, {List<int> expected = const [200]}) {
    if (!expected.contains(response.statusCode)) {
      String errorMessage;

      switch (response.statusCode) {
        case 400:
          errorMessage = "Bad request. Please check your input.";
          break;
        case 401:
          errorMessage = "Unauthorized. Please check your login credentials.";
          break;
        case 403:
          errorMessage = "Access denied.";
          break;
        case 404:
          errorMessage = "Resource not found.";
          break;
        case 409:
          errorMessage = "Conflict: Email or account is already registered.";
          break;
        case 422:
          errorMessage = "Validation failed. Please verify the entered data.";
          break;
        case 500:
        case 502:
        case 503:
          errorMessage = "Server error. Please try again shortly.";
          break;
        default:
          errorMessage = "Request failed (${response.statusCode})";
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded["message"] != null && decoded["message"].toString().isNotEmpty) {
            errorMessage = decoded["message"].toString();
          } else if (decoded["error"] != null && decoded["error"].toString().isNotEmpty) {
            errorMessage = decoded["error"].toString();
          }
        }
      } catch (_) {
        if (response.body.isNotEmpty && response.body.length < 120) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }
}
