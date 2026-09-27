import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gymora_fitness_management/core/model/trainer_model.dart';

/// Thrown for any non-2xx response or `success: false` body.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// All trainer endpoints (`/api/trainers/*`).
///
/// Setup (once, e.g. in main.dart after login is restored):
/// ```dart
/// TrainerService.baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
/// TrainerService.tokenReader = () => SecureStorageService().getToken();
/// ```
class TrainerService {
  TrainerService({http.Client? client}) : _client = client ?? http.Client();

  static final TrainerService instance = TrainerService();

  /// localhost works for web / iOS simulator. Android emulator needs
  /// 10.0.2.2, a real device needs your machine's LAN IP or the AWS URL.
  static String baseUrl = 'http://localhost:5000/api';

  /// Returns the logged-in trainer's JWT. Point this at your
  /// SecureStorageService / SessionManager.
  static Future<String?> Function() tokenReader = () async => null;

  /// Change to 'PATCH' if the backend routes use router.patch(...).
  static String updateMethod = 'PUT';

  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================

  /// GET /trainers/dashboard
  Future<TrainerDashboardData> getDashboard() async {
    final data = await _get('/trainers/dashboard');
    return TrainerDashboardData.fromJson(data);
  }

  // ===========================================================================
  // CLIENTS
  // ===========================================================================

  /// GET /trainers/clients?status=ACTIVE|EXPIRING|EXPIRED&search=...
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

  /// GET /trainers/sessions  (optionally ?date=YYYY-MM-DD)
  Future<List<TrainingSession>> getSessions({DateTime? date}) async {
    final data = await _get(
      '/trainers/sessions',
      query: {if (date != null) 'date': formatApiDate(date)},
    );
    return asMapList(data['sessions']).map(TrainingSession.fromJson).toList();
  }

  /// GET /trainers/sessions/{id}
  Future<TrainingSession> getSession(String id) async {
    final data = await _get('/trainers/sessions/$id');
    return TrainingSession.fromJson(_map(data['session']));
  }

  /// POST /trainers/sessions
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

  /// PUT/PATCH /trainers/sessions/{id} with any of:
  /// clientId, date, time, duration, sessionType, location, status, notes
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

  /// Shortcut: { "status": "COMPLETED" }
  Future<TrainingSession> updateSessionStatus(
    String id,
    SessionStatus status,
  ) => updateSession(id, {'status': status.apiValue});

  /// DELETE /trainers/sessions/{id}
  Future<void> deleteSession(String id) async {
    await _send('DELETE', '/trainers/sessions/$id');
  }

  // ===========================================================================
  // PROGRESS
  // ===========================================================================

  /// GET /trainers/progress
  /// Returns the overall numbers plus `clientProgress` keyed by clientId.
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

  /// GET /trainers/progress/clients/{clientId}
  Future<ClientProgressDetail> getClientProgress(String clientId) async {
    final data = await _get('/trainers/progress/clients/$clientId');
    return ClientProgressDetail.fromJson(data);
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  /// GET /trainers/profile
  Future<TrainerProfile> getProfile() async {
    final data = await _get('/trainers/profile');
    return TrainerProfile.fromJson(data);
  }

  /// PUT/PATCH /trainers/profile — send only the fields that changed
  /// (fullName, phone, specialization, experience).
  Future<TrainerProfile> updateProfile(Map<String, dynamic> changes) async {
    final data = await _send(updateMethod, '/trainers/profile', body: changes);
    return TrainerProfile.fromJson(data);
  }

  // ===========================================================================
  // HTTP
  // ===========================================================================

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) => _send('GET', path, query: query);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);

    final token = await tokenReader();
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('Server is taking too long. Please try again.');
    } on http.ClientException {
      // Covers no internet, refused connection, DNS failure (web + mobile).
      throw const ApiException(
        'Cannot reach the server. Check your internet connection.',
      );
    }

    Map<String, dynamic> json = const {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) json = Map<String, dynamic>.from(decoded);
      } on FormatException {
        // Non-JSON body (e.g. HTML error page) — handled below.
      }
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || json['success'] == false) {
      throw ApiException(
        asString(
          json['message'],
          fallback: response.statusCode == 401
              ? 'Your session has expired. Please log in again.'
              : 'Request failed (${response.statusCode}).',
        ),
        statusCode: response.statusCode,
      );
    }

    return _map(json['data']);
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
}
