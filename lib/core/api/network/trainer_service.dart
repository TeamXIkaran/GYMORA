import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/core/service/secure_storage_service.dart';

/// Thrown for any non-2xx response or `success: false` body.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// All trainer endpoints.
///
/// Example:
/// GET    /api/trainers/dashboard
/// GET    /api/trainers/clients
/// GET    /api/trainers/sessions
/// POST   /api/trainers/sessions
/// PUT    /api/trainers/sessions/{id}
/// DELETE /api/trainers/sessions/{id}
/// GET    /api/trainers/progress
/// GET    /api/trainers/profile
/// PUT    /api/trainers/profile
class TrainerService {
  TrainerService({http.Client? client}) : _client = client ?? http.Client();

  /// Singleton instance used by TrainerDashboardProvider.
  static final TrainerService instance = TrainerService();

  // ===========================================================================
  // BASE URL
  // ===========================================================================

  /// Reads BASE_URL from the loaded .env file.
  ///
  /// Android Emulator:
  /// BASE_URL=http://10.0.2.2:5000/api
  ///
  /// Physical Android device:
  /// BASE_URL=http://YOUR_PC_IP:5000/api
  ///
  /// Production:
  /// BASE_URL=https://your-render-url/api
  static String get baseUrl {
    final envUrl = dotenv.env['BASE_URL'];

    if (envUrl == null || envUrl.trim().isEmpty) {
      // Safe fallback for Android Emulator.
      return 'http://10.0.2.2:5000/api';
    }

    return envUrl.trim().replaceFirst(RegExp(r'/$'), '');
  }

  // ===========================================================================
  // AUTH TOKEN
  // ===========================================================================

  /// Reads the JWT saved after trainer login.
  ///
  /// SecureStorageService already exposes getToken() in the project.
  static Future<String?> Function() tokenReader = () =>
      SecureStorageService().getToken();

  // ===========================================================================
  // UPDATE METHOD
  // ===========================================================================

  /// Current backend uses PUT.
  ///
  /// If backend changes to PATCH later:
  /// TrainerService.updateMethod = 'PATCH';
  static String updateMethod = 'PUT';

  // ===========================================================================
  // TIMEOUT
  // ===========================================================================

  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================

  /// GET /api/trainers/dashboard
  Future<TrainerDashboardData> getDashboard() async {
    final data = await _get('/trainers/dashboard');

    return TrainerDashboardData.fromJson(data);
  }

  // ===========================================================================
  // CLIENTS
  // ===========================================================================

  /// GET /api/trainers/clients
  ///
  /// Optional:
  /// ?status=ACTIVE
  /// ?status=EXPIRING
  /// ?status=EXPIRED
  /// ?search=Aarav
  Future<({ClientOverview overview, List<TrainerClient> clients})> getClients({
    String? status,
    String? search,
  }) async {
    final data = await _get(
      '/trainers/clients',
      query: {
        if (status != null && status.isNotEmpty) 'status': status,

        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final overview = data['overview'] is Map
        ? ClientOverview.fromJson(Map<String, dynamic>.from(data['overview']))
        : const ClientOverview();

    final clients = asMapList(
      data['clients'],
    ).map(TrainerClient.fromJson).toList();

    return (overview: overview, clients: clients);
  }

  // ===========================================================================
  // SESSIONS
  // ===========================================================================

  /// GET /api/trainers/sessions
  ///
  /// Optional:
  /// ?date=YYYY-MM-DD
  Future<List<TrainingSession>> getSessions({DateTime? date}) async {
    final data = await _get(
      '/trainers/sessions',
      query: {if (date != null) 'date': formatApiDate(date)},
    );

    return asMapList(data['sessions']).map(TrainingSession.fromJson).toList();
  }

  /// GET /api/trainers/sessions/{id}
  Future<TrainingSession> getSession(String id) async {
    final data = await _get('/trainers/sessions/$id');

    return TrainingSession.fromJson(_map(data['session']));
  }

  /// POST /api/trainers/sessions
  Future<TrainingSession> createSession({
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String sessionType,
    required String location,
    String notes = '',
  }) async {
    final body = TrainingSession(
      id: '',
      clientId: clientId,
      start: start,
      durationMinutes: durationMinutes,
      type: sessionType,
      location: location,
      notes: notes,
    ).toApiJson();

    final data = await _send('POST', '/trainers/sessions', body: body);

    return TrainingSession.fromJson(_map(data['session']));
  }

  /// PUT/PATCH /api/trainers/sessions/{id}
  ///
  /// Supported fields:
  /// clientId
  /// date
  /// time
  /// duration
  /// sessionType
  /// location
  /// status
  /// notes
  Future<TrainingSession> updateSession(
    String id,
    Map<String, dynamic> changes,
  ) async {
    final data = await _send(
      updateMethod,
      '/trainers/sessions/$id',
      body: changes,
    );

    return TrainingSession.fromJson(_map(data['session']));
  }

  /// Update session status.
  ///
  /// Example:
  /// { "status": "COMPLETED" }
  Future<TrainingSession> updateSessionStatus(String id, SessionStatus status) {
    return updateSession(id, {'status': status.apiValue});
  }

  /// DELETE /api/trainers/sessions/{id}
  Future<void> deleteSession(String id) async {
    await _send('DELETE', '/trainers/sessions/$id');
  }

  // ===========================================================================
  // PROGRESS
  // ===========================================================================

  /// GET /api/trainers/progress
  Future<
    ({TrainerProgressData progress, Map<String, Map<String, dynamic>> clients})
  >
  getProgress() async {
    final data = await _get('/trainers/progress');

    final byClient = <String, Map<String, dynamic>>{
      for (final item in asMapList(data['clientProgress']))
        asString(item['clientId']): item,
    };

    return (progress: TrainerProgressData.fromJson(data), clients: byClient);
  }

  /// GET /api/trainers/progress/clients/{clientId}
  Future<ClientProgressDetail> getClientProgress(String clientId) async {
    final data = await _get('/trainers/progress/clients/$clientId');

    return ClientProgressDetail.fromJson(data);
  }

  /// POST /api/trainers/workouts
  /// Assigns a workout to one of the trainer's clients. The backend uses the
  /// member's business `clientId` (for example `0003`), not its Mongo id.
  Future<void> assignWorkout({
    required String clientId,
    required String title,
    required List<String> exercises,
    required String notes,
  }) async {
    await _send(
      'POST',
      '/trainers/workouts',
      body: {
        'clientId': clientId,
        'title': title,
        'muscleGroups': _muscleGroupsFor(title),
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'duration': 45,
        'estimatedCalories': 320,
        'exercises': exercises.map(_workoutExercisePayload).toList(),
        'notes': notes,
      },
    );
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  /// GET /api/trainers/profile
  Future<TrainerProfile> getProfile() async {
    final data = await _get('/trainers/profile');

    return TrainerProfile.fromJson(data);
  }

  /// PUT/PATCH /api/trainers/profile
  ///
  /// Send only changed fields:
  /// fullName
  /// phone
  /// specialization
  /// experience
  Future<TrainerProfile> updateProfile(Map<String, dynamic> changes) async {
    final data = await _send(updateMethod, '/trainers/profile', body: changes);

    return TrainerProfile.fromJson(data);
  }

  // ===========================================================================
  // GET
  // ===========================================================================

  Future<Map<String, dynamic>> _get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  // ===========================================================================
  // HTTP REQUEST
  // ===========================================================================

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    // -------------------------------------------------------------------------
    // Build URL safely
    // -------------------------------------------------------------------------

    final cleanBaseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

    final cleanPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse(
      '$cleanBaseUrl$cleanPath',
    ).replace(queryParameters: query == null || query.isEmpty ? null : query);

    // -------------------------------------------------------------------------
    // Read JWT
    // -------------------------------------------------------------------------

    String? token;

    try {
      token = await tokenReader();
    } catch (e) {
      debugPrint('⚠️ [TrainerService] Failed to read token: $e');
      token = null;
    }

    // -------------------------------------------------------------------------
    // Debug
    // -------------------------------------------------------------------------

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    debugPrint('🏋️ [TrainerService] REQUEST');

    debugPrint('➡️ Method: $method');

    debugPrint('➡️ URL: $uri');

    debugPrint(
      '🔐 Token: '
      '${token != null && token.isNotEmpty ? 'FOUND' : 'MISSING'}',
    );

    if (body != null) {
      debugPrint('📦 Body: ${jsonEncode(body)}');
    }

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // -------------------------------------------------------------------------
    // Request
    // -------------------------------------------------------------------------

    final request = http.Request(method.toUpperCase(), uri);

    request.headers.addAll({
      'Accept': 'application/json',

      if (body != null) 'Content-Type': 'application/json',

      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    if (body != null) {
      request.body = jsonEncode(body);
    }

    // -------------------------------------------------------------------------
    // Send
    // -------------------------------------------------------------------------

    http.Response response;

    try {
      final streamedResponse = await _client.send(request).timeout(_timeout);

      response = await http.Response.fromStream(streamedResponse);
    } on TimeoutException {
      debugPrint('⏱️ [TrainerService] Request timeout');

      throw const ApiException('Server is taking too long. Please try again.');
    } on http.ClientException catch (e) {
      debugPrint('❌ [TrainerService] ClientException: $e');

      throw const ApiException(
        'Cannot reach the server. Check your internet connection.',
      );
    } catch (e) {
      debugPrint('❌ [TrainerService] Network error: $e');

      throw const ApiException(
        'Cannot connect to the server. Please try again.',
      );
    }

    // -------------------------------------------------------------------------
    // Response Debug
    // -------------------------------------------------------------------------

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    debugPrint('🏋️ [TrainerService] RESPONSE');

    debugPrint('⬅️ Status: ${response.statusCode}');

    debugPrint('📦 Body: ${response.body}');

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // -------------------------------------------------------------------------
    // Parse JSON
    // -------------------------------------------------------------------------

    Map<String, dynamic> json = <String, dynamic>{};

    if (response.body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          json = Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        // Backend returned HTML/text instead of JSON.
        debugPrint('⚠️ [TrainerService] Response is not JSON.');
      }
    }

    // -------------------------------------------------------------------------
    // HTTP Error
    // -------------------------------------------------------------------------

    final isHttpSuccess =
        response.statusCode >= 200 && response.statusCode < 300;

    if (!isHttpSuccess) {
      String message;

      if (response.statusCode == 401) {
        message = asString(
          json['message'],
          fallback: 'Your session has expired. Please log in again.',
        );
      } else if (response.statusCode == 403) {
        message = asString(
          json['message'],
          fallback: 'You do not have permission to access this data.',
        );
      } else if (response.statusCode == 404) {
        message = asString(
          json['message'],
          fallback: 'Trainer API endpoint was not found.',
        );
      } else if (json.isEmpty && response.body.trim().isNotEmpty) {
        message =
            'Server returned an invalid response '
            '(${response.statusCode}).';
      } else {
        message = asString(
          json['message'],
          fallback: 'Request failed (${response.statusCode}).',
        );
      }

      throw ApiException(message, statusCode: response.statusCode);
    }

    // -------------------------------------------------------------------------
    // Backend success:false
    // -------------------------------------------------------------------------

    if (json['success'] == false) {
      throw ApiException(
        asString(json['message'], fallback: 'Request failed.'),
        statusCode: response.statusCode,
      );
    }

    // -------------------------------------------------------------------------
    // Return data
    // -------------------------------------------------------------------------

    return _map(json['data']);
  }

  // ===========================================================================
  // MAP HELPER
  // ===========================================================================

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}

Map<String, dynamic> _workoutExercisePayload(String prescription) {
  final text = prescription.trim();
  final prescriptionMatch = RegExp(
    r'[-–—:]\s*(\d+)\s*(?:rounds?\s*)?[x×]\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(text);
  final durationMatch = RegExp(
    r'[-–—:]\s*(\d+)\s*(sec(?:onds?)?|min(?:utes?)?)\b',
    caseSensitive: false,
  ).firstMatch(text);

  var sets = 3;
  var reps = 10;
  if (prescriptionMatch != null) {
    sets = int.tryParse(prescriptionMatch.group(1)!) ?? sets;
    reps = int.tryParse(prescriptionMatch.group(2)!) ?? reps;
  } else if (durationMatch != null) {
    final amount = int.tryParse(durationMatch.group(1)!) ?? reps;
    final unit = durationMatch.group(2)!.toLowerCase();
    // The member workout model represents timed exercise targets in seconds.
    reps = unit.startsWith('min') ? amount * 60 : amount;
    sets = 1;
  }

  final name = text.replaceFirst(RegExp(r'\s*[-–—:]\s*.*$'), '').trim();
  return {
    'name': name.isEmpty ? text : name,
    'sets': sets,
    'reps': reps,
    'weight': 0,
    'restSeconds': 60,
  };
}

List<String> _muscleGroupsFor(String title) {
  final normalized = title.toLowerCase();
  const groups = <(String, List<String>)>[
    ('Chest', ['chest', 'push']),
    ('Back', ['back', 'pull']),
    ('Shoulders', ['shoulder']),
    ('Arms', ['arm', 'bicep', 'tricep']),
    ('Core', ['core', 'stability']),
    ('Legs', ['leg', 'lower body', 'glute', 'squat']),
    ('Cardio', ['cardio', 'hiit', 'fat loss', 'endurance']),
    ('Mobility', ['mobility', 'stretch']),
  ];
  final matched = groups
      .where((group) => group.$2.any(normalized.contains))
      .map((group) => group.$1)
      .toList();
  return matched.isEmpty ? ['Full Body'] : matched;
}
