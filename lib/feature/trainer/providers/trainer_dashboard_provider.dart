import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/api/network/trainer_service.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';


/// Single source of truth for every trainer screen. All data comes from the
/// backend through [TrainerService] — nothing is seeded locally.
///
/// Screens listen with `ListenableBuilder(listenable: TrainerDashboardProvider.instance)`.
/// You can also register it in MultiProvider:
///   ChangeNotifierProvider.value(value: TrainerDashboardProvider.instance)
///
/// Call [loadAll] once after the trainer logs in (the dashboard does this in
/// initState) and [clear] on logout.
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

  /// Result of the last server-side search / status filter (Clients screen).
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

  /// Loads everything the trainer screens need, in parallel.
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
    // Progress fills client progress numbers, so it runs after clients.
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

  Future<void> _fetchProfile() async {
    profile = await _api.getProfile();
  }

  Future<void> _fetchClients() async {
    final result = await _api.getClients();
    final previous = {for (final c in _clients) c.id: c};
    clientOverview = result.overview;
    _clients
      ..clear()
      ..addAll(result.clients);
    // Keep progress / workout already known for the same client.
    for (final c in _clients) {
      final old = previous[c.id];
      if (old == null) continue;
      c
        ..progress = old.progress
        ..totalSessions = old.totalSessions
        ..completedSessions = old.completedSessions
        ..scheduledSessions = old.scheduledSessions
        ..cancelledSessions = old.cancelledSessions
        ..trainingHours = old.trainingHours
        ..workoutPlan = old.workoutPlan;
    }
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
    for (final c in _clients) {
      final p = result.clients[c.id];
      if (p != null) c.applyProgress(p);
    }
  }

  /// Everything that changes when a session is created / edited / removed.
  Future<void> _afterSessionChange() async {
    try {
      await Future.wait([
        _fetchSessions(),
        _fetchDashboard(),
        _fetchProgress(),
      ]);
    } catch (_) {
      // The mutation itself succeeded; a failed refresh is not fatal.
    }
  }

  /// Clears all trainer data (call on logout).
  void clear() {
    profile = null;
    dashboard = const TrainerDashboardData();
    progressData = const TrainerProgressData();
    clientOverview = const ClientOverview();
    _clients.clear();
    _sessions.clear();
    filteredClients = [];
    hasLoaded = false;
    error = null;
    notifyListeners();
  }

  // ===========================================================================
  // CLIENTS (read-only for trainers — assigned by owner)
  // ===========================================================================

  List<TrainerClient> get clients => List.unmodifiable(_clients);

  TrainerClient? clientById(String id) {
    for (final c in _clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  int get totalClients =>
      clientOverview.total > 0 ? clientOverview.total : _clients.length;

  /// 'Active' | 'Expiring' | 'Expired'
  int countByStatus(String status) {
    final fromApi = clientOverview.countFor(status);
    if (clientOverview.total > 0) return fromApi;
    return _clients.where((c) => c.status == status).length;
  }

  double get averageClientProgress {
    if (_clients.isEmpty) return 0;
    return _clients.fold<int>(0, (s, c) => s + c.progress) /
        _clients.length /
        100;
  }

  List<TrainerClient> get clientsByProgress {
    final list = [..._clients];
    list.sort((a, b) => b.progress.compareTo(a.progress));
    return list;
  }

  /// Server-side search + status filter used by the Clients screen.
  /// [filter] is 'All' | 'Active' | 'Expiring' | 'Expired'.
  Future<void> fetchFilteredClients({
    String filter = 'All',
    String search = '',
  }) async {
    final requestId = ++_filterRequestId;
    isFilteringClients = true;
    notifyListeners();

    try {
      final result = await _api.getClients(
        status: filter == 'All' ? null : filter.toUpperCase(),
        search: search,
      );
      if (requestId != _filterRequestId) return; // a newer search won
      clientOverview = result.overview;
      // Reuse the richer objects (progress, workout) when we have them.
      filteredClients = result.clients
          .map((c) => clientById(c.id) ?? c)
          .toList();
      error = null;
    } catch (e) {
      if (requestId != _filterRequestId) return;
      error = e.toString();
    } finally {
      if (requestId == _filterRequestId) {
        isFilteringClients = false;
        notifyListeners();
      }
    }
  }

  /// GET /trainers/progress/clients/{id} — also updates the cached client.
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
        notifyListeners();
      }
      return detail;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// No backend endpoint for workouts yet — kept in memory for this session.
  void assignWorkout(String clientId, WorkoutPlan plan) {
    final client = clientById(clientId);
    if (client == null) return;
    client.workoutPlan = plan;
    notifyListeners();
  }

  // ===========================================================================
  // SESSIONS
  // ===========================================================================

  List<TrainingSession> get sessions => List.unmodifiable(_sessions);

  TrainingSession? sessionById(String id) {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Sessions on a day (cancelled ones hidden), sorted by start time.
  List<TrainingSession> sessionsOn(DateTime day) {
    final list = _sessions
        .where((s) => !s.isCancelled && isSameDay(s.start, day))
        .toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<TrainingSession> get todaysSessions => sessionsOn(DateTime.now());

  /// Today's sessions that have not been completed yet.
  List<TrainingSession> get todaysUpcoming =>
      todaysSessions.where((s) => !s.isCompleted).toList();

  Iterable<TrainingSession> _completedIn(DateTime from, DateTime to) =>
      _sessions.where(
        (s) => s.isCompleted && !s.start.isBefore(from) && s.start.isBefore(to),
      );

  int completedBetween(DateTime from, DateTime to) =>
      _completedIn(from, to).length;

  int minutesBetween(DateTime from, DateTime to) =>
      _completedIn(from, to).fold(0, (sum, s) => sum + s.durationMinutes);

  int completedForClientBetween(String clientId, DateTime from, DateTime to) =>
      _completedIn(from, to).where((s) => s.clientId == clientId).length;

  int get totalCompleted {
    final local = _sessions.where((s) => s.isCompleted).length;
    return math.max(local, progressData.completedSessions);
  }

  double get averageSessionMinutes {
    if (progressData.averageSessionDuration > 0) {
      return progressData.averageSessionDuration;
    }
    final done = _sessions.where((s) => s.isCompleted).toList();
    if (done.isEmpty) return 0;
    return done.fold<int>(0, (sum, s) => sum + s.durationMinutes) / done.length;
  }

  /// Longest run of consecutive days with at least one completed session.
  int get bestStreak {
    final days =
        _sessions
            .where((s) => s.isCompleted)
            .map((s) => dateOnly(s.start))
            .toSet()
            .toList()
          ..sort();
    int best = 0;
    int current = 0;
    DateTime? previous;
    for (final d in days) {
      if (previous != null && d.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      best = math.max(best, current);
      previous = d;
    }
    return best;
  }

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

  /// Returns an error message when the slot clashes, otherwise null.
  String? _validate(TrainingSession candidate, {String? ignoreId}) {
    if (clientById(candidate.clientId) == null) {
      return 'Please choose one of your assigned clients.';
    }
    for (final s in _sessions) {
      if (s.id == ignoreId || s.isCancelled) continue;
      final overlaps =
          candidate.start.isBefore(s.end) && s.start.isBefore(candidate.end);
      if (overlaps) {
        final other = s.clientName.isNotEmpty
            ? s.clientName
            : clientById(s.clientId)?.name ?? 'another client';
        return 'You already have a session with $other '
            'at ${formatTime(s.start)}.';
      }
    }
    return null;
  }

  /// POST /trainers/sessions — returns an error message or null on success.
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
    );
    final clash = _validate(candidate);
    if (clash != null) return clash;

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

  /// PUT /trainers/sessions/{id} — returns an error message or null.
  Future<String?> updateSession(
    String id, {
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String type,
    required String location,
  }) async {
    final current = sessionById(id);
    if (current == null) return 'Session not found.';
    final updated = current.copy()
      ..clientId = clientId
      ..start = start
      ..durationMinutes = durationMinutes
      ..type = type
      ..location = location;
    final clash = _validate(updated, ignoreId: id);
    if (clash != null) return clash;

    return _mutate(() async {
      final body = updated.toApiJson()..remove('notes');
      await _api.updateSession(id, body);
    });
  }

  /// DELETE /trainers/sessions/{id}. Returns the removed session (for Undo)
  /// or null when it failed — check [error] for the reason.
  Future<TrainingSession?> cancelSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    final removed = _sessions[index];

    final failure = await _mutate(() => _api.deleteSession(id));
    if (failure != null) {
      error = failure;
      notifyListeners();
      return null;
    }
    return removed;
  }

  /// Undo for [cancelSession]: creates the same session again.
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

  /// PUT /trainers/sessions/{id} { status: COMPLETED }
  Future<String?> completeSession(String id) async {
    final session = sessionById(id);
    if (session == null || session.isCompleted) return null;
    return _mutate(() => _api.updateSessionStatus(id, SessionStatus.completed));
  }

  /// Session number of this session within the client's history.
  String sessionNumber(TrainingSession session) {
    final count = _sessions
        .where(
          (s) =>
              s.clientId == session.clientId &&
              !s.isCancelled &&
              !s.start.isAfter(session.start),
        )
        .length;
    return 'Session ${count.toString().padLeft(2, '0')}';
  }

  /// Runs a write call, refreshes the affected data and returns an error
  /// message (or null on success).
  Future<String?> _mutate(Future<void> Function() call) async {
    isSaving = true;
    notifyListeners();
    try {
      await call();
      await _afterSessionChange();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  /// PUT /trainers/profile — only changed fields are sent.
  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String specialization,
    required int experience,
  }) async {
    final p = profile;
    if (p == null) return 'Profile not loaded yet.';

    final changes = <String, dynamic>{
      if (name != p.name) 'fullName': name,
      if (phone != p.phone) 'phone': phone,
      if (specialization != p.specialization) 'specialization': specialization,
      if (experience != p.experience) 'experience': experience,
    };
    if (changes.isEmpty) return null;

    isSaving = true;
    notifyListeners();
    try {
      final updated = await _api.updateProfile(changes);
      // The update response has no statistics block — keep the old numbers.
      updated
        ..totalClients = p.totalClients
        ..completedSessions = p.completedSessions
        ..trainingHours = p.trainingHours;
      profile = updated;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
