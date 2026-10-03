import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/network/trainer_service.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';

/// Single source of truth for every trainer screen.
///
/// All trainer data comes from the backend through [TrainerService].
///
/// Screens can listen with:
/// ListenableBuilder(
///   listenable: TrainerDashboardProvider.instance,
///   builder: (_, __) => ...
/// )
///
/// Or register it in MultiProvider:
/// ChangeNotifierProvider.value(
///   value: TrainerDashboardProvider.instance,
/// )
class TrainerDashboardProvider extends ChangeNotifier {
  TrainerDashboardProvider._(this._api);

  static final TrainerDashboardProvider instance = TrainerDashboardProvider._(
    TrainerService.instance,
  );

  final TrainerService _api;

  static const int monthlySessionGoal = 50;

  // ===========================================================================
  // STATE
  // ===========================================================================

  TrainerProfile? profile;

  TrainerDashboardData dashboard = const TrainerDashboardData();

  TrainerProgressData progressData = const TrainerProgressData();

  ClientOverview clientOverview = const ClientOverview();

  final List<TrainerClient> _clients = [];
  final List<TrainingSession> _sessions = [];

  /// Current result displayed by the Clients screen.
  ///
  /// Initially contains all loaded clients.
  /// Server-side search/filter updates this list.
  List<TrainerClient> filteredClients = [];

  bool isFilteringClients = false;

  int _filterRequestId = 0;

  bool isLoading = false;

  bool hasLoaded = false;

  bool isSaving = false;

  String? error;

  // ===========================================================================
  // LOADING
  // ===========================================================================

  /// Loads everything required by trainer screens.
  ///
  /// Profile, clients, sessions and dashboard are loaded in parallel.
  /// Progress is loaded afterwards because progress data is applied
  /// to the already-loaded clients.
  Future<void> loadAll({bool force = false}) async {
    if (isLoading) return;

    if (hasLoaded && !force) return;

    isLoading = true;
    error = null;

    notifyListeners();

    final errors = <String>[];

    Future<void> guard(Future<void> Function() task) async {
      try {
        await task();
      } catch (e) {
        errors.add(e.toString());
      }
    }

    await Future.wait([
      guard(_fetchProfile),
      guard(_fetchClients),
      guard(_fetchSessions),
      guard(_fetchDashboard),
    ]);

    // Progress depends on the client list.
    await guard(_fetchProgress);

    isLoading = false;

    hasLoaded = errors.isEmpty || _clients.isNotEmpty || profile != null;

    error = errors.isEmpty ? null : errors.first;

    notifyListeners();
  }

  Future<void> refreshAll() => loadAll(force: true);

  Future<void> refreshSessions() => _run(() async {
    await _fetchSessions();
  });

  Future<void> refreshClients() => _run(() async {
    await _fetchClients();
    await _fetchProgress();
  });

  Future<void> refreshDashboard() => _run(() async {
    await Future.wait([_fetchDashboard(), _fetchSessions()]);
  });

  Future<void> refreshProgress() => _run(() async {
    await Future.wait([_fetchProgress(), _fetchSessions()]);
  });

  Future<void> refreshProfile() => _run(_fetchProfile);

  /// Runs a refresh and stores its error instead of throwing.
  Future<void> _run(Future<void> Function() task) async {
    try {
      await task();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    notifyListeners();
  }

  // ===========================================================================
  // FETCH METHODS
  // ===========================================================================

  Future<void> _fetchProfile() async {
    profile = await _api.getProfile();
  }

  Future<void> _fetchClients() async {
    final result = await _api.getClients();

    // Preserve locally known progress/workout information when possible.
    final previous = <String, TrainerClient>{
      for (final client in _clients) client.id: client,
    };

    clientOverview = result.overview;

    _clients
      ..clear()
      ..addAll(result.clients);

    // Restore progress/workout data for clients that were already loaded.
    for (final client in _clients) {
      final old = previous[client.id];

      if (old == null) continue;

      client
        ..progress = old.progress
        ..totalSessions = old.totalSessions
        ..completedSessions = old.completedSessions
        ..scheduledSessions = old.scheduledSessions
        ..cancelledSessions = old.cancelledSessions
        ..trainingHours = old.trainingHours
        ..workoutPlan = old.workoutPlan;
    }

    // IMPORTANT:
    // Keep the Clients screen populated after the initial API call.
    filteredClients = List<TrainerClient>.from(_clients);
  }

  Future<void> _fetchSessions() async {
    final list = await _api.getSessions();

    _sessions
      ..clear()
      ..addAll(list);
  }

  Future<void> _fetchDashboard() async {
    dashboard = await _api.getDashboard();
  }

  Future<void> _fetchProgress() async {
    final result = await _api.getProgress();

    progressData = result.progress;

    // Apply progress data to the already loaded client objects.
    for (final client in _clients) {
      final progress = result.clients[client.id];

      if (progress != null) {
        client.applyProgress(progress);
      }
    }

    // Refresh filtered clients references as well.
    if (filteredClients.isNotEmpty) {
      filteredClients = filteredClients.map((client) {
        return clientById(client.id) ?? client;
      }).toList();
    }
  }

  // ===========================================================================
  // AFTER SESSION CHANGE
  // ===========================================================================

  /// Refreshes all data affected by a session mutation.
  Future<void> _afterSessionChange() async {
    try {
      await Future.wait([
        _fetchSessions(),
        _fetchDashboard(),
        _fetchProgress(),
      ]);
    } catch (_) {
      // The actual mutation already succeeded.
      // A refresh failure should not make the mutation look unsuccessful.
    }
  }

  // ===========================================================================
  // CLEAR / LOGOUT
  // ===========================================================================

  /// Clears all trainer data.
  ///
  /// Call this when trainer logs out.
  void clear() {
    profile = null;

    dashboard = const TrainerDashboardData();

    progressData = const TrainerProgressData();

    clientOverview = const ClientOverview();

    _clients.clear();

    _sessions.clear();

    filteredClients = [];

    isFilteringClients = false;

    _filterRequestId++;

    isLoading = false;

    isSaving = false;

    hasLoaded = false;

    error = null;

    notifyListeners();
  }

  // ===========================================================================
  // CLIENTS
  // ===========================================================================

  /// All currently loaded clients.
  List<TrainerClient> get clients => List.unmodifiable(_clients);

  /// Find a client from the cached list.
  TrainerClient? clientById(String id) {
    for (final client in _clients) {
      if (client.id == id) {
        return client;
      }
    }

    return null;
  }

  /// Total number of assigned clients.
  int get totalClients {
    if (clientOverview.total > 0) {
      return clientOverview.total;
    }

    return _clients.length;
  }

  /// Returns count for:
  /// Active
  /// Expiring
  /// Expired
  int countByStatus(String status) {
    final fromApi = clientOverview.countFor(status);

    if (clientOverview.total > 0) {
      return fromApi;
    }

    return _clients.where((client) => client.status == status).length;
  }

  /// Average client progress as a decimal from 0.0 to 1.0.
  double get averageClientProgress {
    if (_clients.isEmpty) {
      return 0;
    }

    final totalProgress = _clients.fold<int>(
      0,
      (sum, client) => sum + client.progress,
    );

    return totalProgress / _clients.length / 100;
  }

  /// Clients sorted by progress, highest first.
  List<TrainerClient> get clientsByProgress {
    final list = [..._clients];

    list.sort((a, b) => b.progress.compareTo(a.progress));

    return list;
  }

  // ===========================================================================
  // SERVER-SIDE CLIENT SEARCH / FILTER
  // ===========================================================================

  /// Server-side search + status filter.
  ///
  /// [filter] can be:
  /// All
  /// Active
  /// Expiring
  /// Expired
  Future<void> fetchFilteredClients({
    String filter = 'All',
    String search = '',
  }) async {
    final requestId = ++_filterRequestId;

    isFilteringClients = true;

    notifyListeners();

    try {
      final normalizedFilter = filter.trim().toUpperCase();

      final result = await _api.getClients(
        status: normalizedFilter == 'ALL' || normalizedFilter.isEmpty
            ? null
            : normalizedFilter,
        search: search,
      );

      // Ignore an old search response if a newer request already started.
      if (requestId != _filterRequestId) {
        return;
      }

      clientOverview = result.overview;

      filteredClients = result.clients.map((client) {
        final cached = clientById(client.id);

        // Reuse cached object so progress/workout data is not lost.
        return cached ?? client;
      }).toList();

      error = null;
    } catch (e) {
      if (requestId != _filterRequestId) {
        return;
      }

      error = e.toString();
    } finally {
      if (requestId == _filterRequestId) {
        isFilteringClients = false;

        notifyListeners();
      }
    }
  }

  /// Clears server-side filtering and displays all loaded clients.
  void clearClientFilter() {
    _filterRequestId++;

    filteredClients = List<TrainerClient>.from(_clients);

    isFilteringClients = false;

    error = null;

    notifyListeners();
  }

  // ===========================================================================
  // CLIENT PROGRESS
  // ===========================================================================

  /// GET /trainers/progress/clients/{id}
  ///
  /// Loads detailed progress and updates the cached client.
  Future<ClientProgressDetail?> loadClientProgress(String clientId) async {
    try {
      final detail = await _api.getClientProgress(clientId);

      final cached = clientById(clientId);

      if (cached != null) {
        cached
          ..progress = detail.client.progress
          ..totalSessions = detail.client.totalSessions
          ..completedSessions = detail.client.completedSessions
          ..scheduledSessions = detail.client.scheduledSessions
          ..cancelledSessions = detail.client.cancelledSessions
          ..trainingHours = detail.client.trainingHours;

        // Keep filtered list in sync with the cached object.
        filteredClients = filteredClients.map((client) {
          if (client.id == clientId) {
            return cached;
          }

          return client;
        }).toList();

        notifyListeners();
      }

      return detail;
    } catch (e) {
      error = e.toString();

      notifyListeners();

      return null;
    }
  }

  // ===========================================================================
  // WORKOUT
  // ===========================================================================

  /// Saves a trainer-created workout to the backend so the assigned member's
  /// `/api/client/workouts` request returns the same plan.
  Future<void> assignWorkout(String clientId, WorkoutPlan plan) async {
    final client = clientById(clientId);

    if (client == null) {
      throw Exception('This client is no longer in your assigned client list.');
    }

    await _api.assignWorkout(
      clientId: client.id,
      title: plan.title,
      exercises: plan.exercises,
      notes: plan.notes,
    );

    client.workoutPlan = plan;

    // Keep filtered list synchronized.
    filteredClients = filteredClients.map((item) {
      if (item.id == clientId) {
        return client;
      }

      return item;
    }).toList();

    notifyListeners();
  }

  // ===========================================================================
  // SESSIONS
  // ===========================================================================

  List<TrainingSession> get sessions => List.unmodifiable(_sessions);

  TrainingSession? sessionById(String id) {
    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  /// Returns sessions for a specific day.
  ///
  /// Cancelled sessions are hidden.
  /// Results are sorted by start time.
  List<TrainingSession> sessionsOn(DateTime day) {
    final list = _sessions
        .where(
          (session) => !session.isCancelled && isSameDay(session.start, day),
        )
        .toList();

    list.sort((a, b) => a.start.compareTo(b.start));

    return list;
  }

  List<TrainingSession> get todaysSessions {
    return sessionsOn(DateTime.now());
  }

  /// Today's sessions that are not completed.
  List<TrainingSession> get todaysUpcoming {
    return todaysSessions.where((session) => !session.isCompleted).toList();
  }

  Iterable<TrainingSession> _completedIn(DateTime from, DateTime to) {
    return _sessions.where(
      (session) =>
          session.isCompleted &&
          !session.start.isBefore(from) &&
          session.start.isBefore(to),
    );
  }

  int completedBetween(DateTime from, DateTime to) {
    return _completedIn(from, to).length;
  }

  int minutesBetween(DateTime from, DateTime to) {
    return _completedIn(
      from,
      to,
    ).fold<int>(0, (sum, session) => sum + session.durationMinutes);
  }

  int completedForClientBetween(String clientId, DateTime from, DateTime to) {
    return _completedIn(
      from,
      to,
    ).where((session) => session.clientId == clientId).length;
  }

  /// Total completed sessions.
  ///
  /// Uses the larger value between local session data and
  /// backend progress data.
  int get totalCompleted {
    final local = _sessions.where((session) => session.isCompleted).length;

    return math.max(local, progressData.completedSessions);
  }

  /// Average session duration.
  double get averageSessionMinutes {
    if (progressData.averageSessionDuration > 0) {
      return progressData.averageSessionDuration;
    }

    final completed = _sessions
        .where((session) => session.isCompleted)
        .toList();

    if (completed.isEmpty) {
      return 0;
    }

    return completed.fold<int>(
          0,
          (sum, session) => sum + session.durationMinutes,
        ) /
        completed.length;
  }

  /// Longest consecutive-day streak with at least one completed session.
  int get bestStreak {
    final days =
        _sessions
            .where((session) => session.isCompleted)
            .map((session) => dateOnly(session.start))
            .toSet()
            .toList()
          ..sort();

    int best = 0;
    int current = 0;

    DateTime? previous;

    for (final day in days) {
      if (previous != null && day.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }

      best = math.max(best, current);

      previous = day;
    }

    return best;
  }

  /// Completed sessions in current month.
  int get completedThisMonth {
    if (progressData.completedThisMonth > 0) {
      return progressData.completedThisMonth;
    }

    final now = DateTime.now();

    return completedBetween(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    );
  }

  // ===========================================================================
  // SESSION VALIDATION
  // ===========================================================================

  /// Returns an error message if a session overlaps another session.
  String? _validate(TrainingSession candidate, {String? ignoreId}) {
    if (clientById(candidate.clientId) == null) {
      return 'Please choose one of your assigned clients.';
    }

    for (final session in _sessions) {
      if (session.id == ignoreId || session.isCancelled) {
        continue;
      }

      final overlaps =
          candidate.start.isBefore(session.end) &&
          session.start.isBefore(candidate.end);

      if (overlaps) {
        final other = session.clientName.isNotEmpty
            ? session.clientName
            : clientById(session.clientId)?.name ?? 'another client';

        return 'You already have a session with $other '
            'at ${formatTime(session.start)}.';
      }
    }

    return null;
  }

  // ===========================================================================
  // ADD SESSION
  // ===========================================================================

  /// POST /trainers/sessions
  Future<String?> addSession({
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String type,
    required String location,
    String notes = '',
  }) async {
    final candidate = TrainingSession(
      id: '',
      clientId: clientId,
      start: start,
      durationMinutes: durationMinutes,
      type: type,
      location: location,
      notes: notes,
    );

    final clash = _validate(candidate);

    if (clash != null) {
      return clash;
    }

    return _mutate(() async {
      await _api.createSession(
        clientId: clientId,
        start: start,
        durationMinutes: durationMinutes,
        sessionType: type,
        location: location,
        notes: notes,
      );
    });
  }

  // ===========================================================================
  // UPDATE SESSION
  // ===========================================================================

  /// PUT /trainers/sessions/{id}
  Future<String?> updateSession(
    String id, {
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String type,
    required String location,
  }) async {
    final current = sessionById(id);

    if (current == null) {
      return 'Session not found.';
    }

    final updated = current.copy()
      ..clientId = clientId
      ..start = start
      ..durationMinutes = durationMinutes
      ..type = type
      ..location = location;

    final clash = _validate(updated, ignoreId: id);

    if (clash != null) {
      return clash;
    }

    return _mutate(() async {
      final body = updated.toApiJson();

      // Notes are intentionally preserved now.
      await _api.updateSession(id, body);
    });
  }

  // ===========================================================================
  // DELETE SESSION
  // ===========================================================================

  /// DELETE /trainers/sessions/{id}
  ///
  /// The backend currently deletes the session.
  Future<TrainingSession?> cancelSession(String id) async {
    final index = _sessions.indexWhere((session) => session.id == id);

    if (index == -1) {
      return null;
    }

    final removed = _sessions[index];

    final failure = await _mutate(() => _api.deleteSession(id));

    if (failure != null) {
      error = failure;

      notifyListeners();

      return null;
    }

    return removed;
  }

  /// Restores a deleted session by creating it again.
  Future<String?> restoreSession(TrainingSession session) {
    return _mutate(() async {
      await _api.createSession(
        clientId: session.clientId,
        start: session.start,
        durationMinutes: session.durationMinutes,
        sessionType: session.type,
        location: session.location,
        notes: session.notes,
      );
    });
  }

  // ===========================================================================
  // COMPLETE SESSION
  // ===========================================================================

  /// PUT /trainers/sessions/{id}
  ///
  /// Body:
  /// {
  ///   "status": "COMPLETED"
  /// }
  Future<String?> completeSession(String id) async {
    final session = sessionById(id);

    if (session == null || session.isCompleted) {
      return null;
    }

    return _mutate(() => _api.updateSessionStatus(id, SessionStatus.completed));
  }

  /// Returns the session number within this client's history.
  String sessionNumber(TrainingSession session) {
    final count = _sessions
        .where(
          (item) =>
              item.clientId == session.clientId &&
              !item.isCancelled &&
              !item.start.isAfter(session.start),
        )
        .length;

    return 'Session ${count.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // MUTATION HELPER
  // ===========================================================================

  /// Runs a write API call.
  ///
  /// After success, affected trainer data is refreshed.
  Future<String?> _mutate(Future<void> Function() call) async {
    isSaving = true;

    error = null;

    notifyListeners();

    try {
      await call();

      await _afterSessionChange();

      return null;
    } catch (e) {
      error = e.toString();

      return e.toString();
    } finally {
      isSaving = false;

      notifyListeners();
    }
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  /// PUT /trainers/profile
  ///
  /// Only changed fields are sent.
  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String specialization,
    required int experience,
  }) async {
    final currentProfile = profile;

    if (currentProfile == null) {
      return 'Profile not loaded yet.';
    }

    final changes = <String, dynamic>{
      if (name != currentProfile.name) 'fullName': name,

      if (phone != currentProfile.phone) 'phone': phone,

      if (specialization != currentProfile.specialization)
        'specialization': specialization,

      if (experience != currentProfile.experience) 'experience': experience,
    };

    if (changes.isEmpty) {
      return null;
    }

    isSaving = true;

    error = null;

    notifyListeners();

    try {
      final updated = await _api.updateProfile(changes);

      // The profile update API response does not contain
      // the statistics block, so preserve the old statistics.
      updated
        ..totalClients = currentProfile.totalClients
        ..completedSessions = currentProfile.completedSessions
        ..trainingHours = currentProfile.trainingHours;

      profile = updated;

      return null;
    } catch (e) {
      error = e.toString();

      return e.toString();
    } finally {
      isSaving = false;

      notifyListeners();
    }
  }
}
