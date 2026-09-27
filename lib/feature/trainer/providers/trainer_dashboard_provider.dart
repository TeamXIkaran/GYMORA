import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';

/// Single source of truth for every trainer screen.
///
/// Screens listen with `ListenableBuilder(listenable: TrainerProvider.instance)`
/// so it works without registering anything in main.dart. If you prefer, you
/// can also register it in your MultiProvider:
///   ChangeNotifierProvider.value(value: TrainerProvider.instance)
///
/// Data is currently seeded locally. Each mutating method has a TODO where the
/// matching API call (AWS Lambda / API Gateway) should go.
class TrainerDashboardProvider extends ChangeNotifier {
  TrainerDashboardProvider._() {
    _seed();
  }

  static final TrainerDashboardProvider instance = TrainerDashboardProvider._();

  late TrainerProfile profile;
  final List<TrainerClient> _clients = [];
  final List<TrainingSession> _sessions = [];

  static const int monthlySessionGoal = 50;

  int _idCounter = 0;
  String _newId() =>
      'S${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

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

  int get totalClients => _clients.length;
  int countByStatus(String status) =>
      _clients.where((c) => c.status == status).length;

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

  /// TODO(api): POST /api/trainer/clients/{id}/workout
  void assignWorkout(String clientId, WorkoutPlan plan) {
    final client = clientById(clientId);
    if (client == null) return;
    client.workoutPlan = plan;
    notifyListeners();
  }

  // ===========================================================================
  // SESSIONS
  // ===========================================================================

  List<TrainingSession> sessionsOn(DateTime day) {
    final list = _sessions.where((s) => isSameDay(s.start, day)).toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<TrainingSession> get todaysSessions => sessionsOn(DateTime.now());

  /// Today's sessions that have not been completed yet.
  List<TrainingSession> get todaysUpcoming =>
      todaysSessions.where((s) => !s.isCompleted).toList();

  int completedBetween(DateTime from, DateTime to) => _sessions
      .where(
        (s) => s.isCompleted && !s.start.isBefore(from) && s.start.isBefore(to),
      )
      .length;

  int minutesBetween(DateTime from, DateTime to) => _sessions
      .where(
        (s) => s.isCompleted && !s.start.isBefore(from) && s.start.isBefore(to),
      )
      .fold(0, (sum, s) => sum + s.durationMinutes);

  int completedForClientBetween(String clientId, DateTime from, DateTime to) =>
      _sessions
          .where(
            (s) =>
                s.clientId == clientId &&
                s.isCompleted &&
                !s.start.isBefore(from) &&
                s.start.isBefore(to),
          )
          .length;

  int get totalCompleted => _sessions.where((s) => s.isCompleted).length;

  double get averageSessionMinutes {
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
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 1);
    return completedBetween(from, to);
  }

  /// Returns an error message when the slot clashes, otherwise null.
  String? _validate(TrainingSession candidate, {String? ignoreId}) {
    if (clientById(candidate.clientId) == null) {
      return 'Please choose one of your assigned clients.';
    }
    for (final s in _sessions) {
      if (s.id == ignoreId) continue;
      final overlaps =
          candidate.start.isBefore(s.end) && s.start.isBefore(candidate.end);
      if (overlaps) {
        final other = clientById(s.clientId)?.name ?? 'another client';
        return 'You already have a session with $other '
            'at ${formatTime(s.start)}.';
      }
    }
    return null;
  }

  /// TODO(api): POST /api/trainer/sessions
  String? addSession({
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String type,
    required String location,
  }) {
    final session = TrainingSession(
      id: _newId(),
      clientId: clientId,
      start: start,
      durationMinutes: durationMinutes,
      type: type,
      location: location,
    );
    final error = _validate(session);
    if (error != null) return error;
    _sessions.add(session);
    notifyListeners();
    return null;
  }

  /// TODO(api): PUT /api/trainer/sessions/{id}
  String? updateSession(
    String id, {
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required String type,
    required String location,
  }) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return 'Session not found.';
    final updated = _sessions[index].copy()
      ..clientId = clientId
      ..start = start
      ..durationMinutes = durationMinutes
      ..type = type
      ..location = location;
    final error = _validate(updated, ignoreId: id);
    if (error != null) return error;
    _sessions[index] = updated;
    notifyListeners();
    return null;
  }

  /// TODO(api): DELETE /api/trainer/sessions/{id}
  TrainingSession? cancelSession(String id) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    final removed = _sessions.removeAt(index);
    notifyListeners();
    return removed;
  }

  /// Puts a cancelled session back (used by the Undo action).
  void restoreSession(TrainingSession session) {
    if (_sessions.any((s) => s.id == session.id)) return;
    _sessions.add(session);
    notifyListeners();
  }

  /// TODO(api): PATCH /api/trainer/sessions/{id}/complete
  void completeSession(String id) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1 || _sessions[index].isCompleted) return;
    final session = _sessions[index];
    session.status = SessionStatus.completed;
    final client = clientById(session.clientId);
    if (client != null) {
      client.sessions += 1;
      client.remainingSessions = math.max(0, client.remainingSessions - 1);
      client.progress = math.min(100, client.progress + 1);
    }
    notifyListeners();
  }

  /// Session number of this session within the client's history.
  String sessionNumber(TrainingSession session) {
    final count = _sessions
        .where(
          (s) =>
              s.clientId == session.clientId && !s.start.isAfter(session.start),
        )
        .length;
    return 'Session ${count.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // PROFILE
  // ===========================================================================

  /// TODO(api): PUT /api/trainer/profile
  void updateProfile({
    required String name,
    required String phone,
    required String location,
    required String specialization,
    required String experience,
    required String certification,
  }) {
    profile
      ..name = name
      ..phone = phone
      ..location = location
      ..specialization = specialization
      ..experience = experience
      ..certification = certification;
    notifyListeners();
  }

  // ===========================================================================
  // SEED DATA (replace with API fetch)
  // ===========================================================================

  void _seed() {
    final now = DateTime.now();
    final today = dateOnly(now);

    profile = TrainerProfile(
      name: 'Amit Kumar',
      email: 'amit.kumar@gmail.com',
      phone: '+91 98765 43210',
      location: 'New Delhi, India',
      specialization: 'Strength & Fitness',
      experience: '5+ Years',
      certification: 'Certified Fitness Trainer',
      gymName: 'GYMO Fitness',
      gymId: 'GYMO07',
      rating: 4.9,
    );

    _clients.addAll([
      TrainerClient(
        id: 'C1',
        name: 'Aarav Sharma',
        goal: 'Weight Loss',
        plan: 'Premium',
        expiry: today.add(const Duration(days: 45)),
        age: '26 yrs',
        height: '5\'9"',
        weight: '78 kg',
        progress: 82,
        attendance: 92,
        sessions: 18,
        remainingSessions: 6,
      ),
      TrainerClient(
        id: 'C2',
        name: 'Neha Singh',
        goal: 'Muscle Gain',
        plan: 'Standard',
        expiry: today.add(const Duration(days: 60)),
        age: '24 yrs',
        height: '5\'5"',
        weight: '61 kg',
        progress: 68,
        attendance: 86,
        sessions: 14,
        remainingSessions: 4,
      ),
      TrainerClient(
        id: 'C3',
        name: 'Rahul Verma',
        goal: 'Strength',
        plan: 'Premium',
        expiry: today.add(const Duration(days: 90)),
        age: '29 yrs',
        height: '5\'11"',
        weight: '84 kg',
        progress: 91,
        attendance: 96,
        sessions: 24,
        remainingSessions: 8,
      ),
      TrainerClient(
        id: 'C4',
        name: 'Priya Patel',
        goal: 'Fat Loss',
        plan: 'Basic',
        expiry: today.add(const Duration(days: 4)),
        age: '27 yrs',
        height: '5\'4"',
        weight: '69 kg',
        progress: 54,
        attendance: 72,
        sessions: 9,
        remainingSessions: 2,
      ),
      TrainerClient(
        id: 'C5',
        name: 'Rohan Mehta',
        goal: 'Fitness',
        plan: 'Premium',
        expiry: today.add(const Duration(days: 120)),
        age: '31 yrs',
        height: '5\'10"',
        weight: '80 kg',
        progress: 76,
        attendance: 89,
        sessions: 16,
        remainingSessions: 5,
      ),
      TrainerClient(
        id: 'C6',
        name: 'Simran Kaur',
        goal: 'Body Toning',
        plan: 'Standard',
        expiry: today.subtract(const Duration(days: 6)),
        age: '25 yrs',
        height: '5\'6"',
        weight: '63 kg',
        progress: 61,
        attendance: 81,
        sessions: 11,
        remainingSessions: 3,
      ),
    ]);

    // Today's plan (sessions already over are marked completed).
    const todayPlan = [
      [10, 30, 'C1', 60, 'Personal Training', 'Gym Floor • Zone A'],
      [12, 0, 'C2', 60, 'Strength Training', 'Weight Area • Zone B'],
      [14, 30, 'C4', 45, 'HIIT Workout', 'Functional Area'],
      [16, 30, 'C3', 60, 'Personal Training', 'Gym Floor • Zone A'],
      [18, 0, 'C5', 60, 'Cardio Training', 'Cardio Zone'],
    ];
    for (final p in todayPlan) {
      final start = today.add(
        Duration(hours: p[0] as int, minutes: p[1] as int),
      );
      final duration = p[3] as int;
      _sessions.add(
        TrainingSession(
          id: _newId(),
          clientId: p[2] as String,
          start: start,
          durationMinutes: duration,
          type: p[4] as String,
          location: p[5] as String,
          status: start.add(Duration(minutes: duration)).isBefore(now)
              ? SessionStatus.completed
              : SessionStatus.upcoming,
        ),
      );
    }

    // History (last 12 months, completed) + next 7 days (upcoming).
    final random = math.Random(7);
    final activeIds = ['C1', 'C2', 'C3', 'C4', 'C5'];
    const slots = [7, 9, 11, 15, 17, 19];
    for (int offset = -365; offset <= 7; offset++) {
      if (offset == 0) continue;
      final day = today.add(Duration(days: offset));
      final isSunday = day.weekday == DateTime.sunday;
      final count = isSunday ? random.nextInt(2) : 1 + random.nextInt(4);
      final usedSlots = [...slots]..shuffle(random);
      for (int i = 0; i < count; i++) {
        final type = TrainerOptions
            .sessionTypes[random.nextInt(TrainerOptions.sessionTypes.length)];
        _sessions.add(
          TrainingSession(
            id: _newId(),
            clientId: activeIds[random.nextInt(activeIds.length)],
            start: day.add(Duration(hours: usedSlots[i])),
            durationMinutes: [45, 60, 60, 60, 90][random.nextInt(5)],
            type: type,
            location: TrainerOptions
                .locations[random.nextInt(TrainerOptions.locations.length)],
            status: offset < 0
                ? SessionStatus.completed
                : SessionStatus.upcoming,
          ),
        );
      }
    }
  }
}
