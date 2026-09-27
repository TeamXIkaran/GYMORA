import 'package:flutter/material.dart';

// =============================================================================
// TRAINER MODELS
// These classes follow the backend JSON returned by /api/trainers/*.
// Clients are ASSIGNED to a trainer by the gym owner (POST /api/members).
// A trainer can view their assigned clients, schedule sessions with them and
// track progress.
// =============================================================================

/// Backend values: SCHEDULED | COMPLETED | CANCELLED
enum SessionStatus { upcoming, completed, cancelled }

extension SessionStatusApi on SessionStatus {
  String get apiValue {
    switch (this) {
      case SessionStatus.completed:
        return 'COMPLETED';
      case SessionStatus.cancelled:
        return 'CANCELLED';
      case SessionStatus.upcoming:
        return 'SCHEDULED';
    }
  }

  static SessionStatus fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'COMPLETED':
        return SessionStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.upcoming;
    }
  }
}

// =============================================================================
// PROFILE  —  GET /api/trainers/profile
// =============================================================================

class TrainerProfile {
  final String id;
  final String trainerId;
  String name;
  final String email;
  String phone;
  final String gymId;
  String specialization;
  int experience; // years
  final String status;
  final DateTime? createdAt;

  // "statistics" block of the profile response
  int totalClients;
  int completedSessions;
  double trainingHours;

  TrainerProfile({
    required this.id,
    required this.trainerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.gymId,
    required this.specialization,
    required this.experience,
    required this.status,
    this.createdAt,
    this.totalClients = 0,
    this.completedSessions = 0,
    this.trainingHours = 0,
  });

  /// Accepts either the whole `data` object ({trainer, statistics}) or just
  /// the `trainer` object.
  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    final t = json['trainer'] is Map
        ? Map<String, dynamic>.from(json['trainer'])
        : json;
    final stats = json['statistics'] is Map
        ? Map<String, dynamic>.from(json['statistics'])
        : const <String, dynamic>{};

    return TrainerProfile(
      id: asString(t['id'] ?? t['_id']),
      trainerId: asString(t['trainerId']),
      name: asString(t['fullName']),
      email: asString(t['email']),
      phone: asString(t['phone']),
      gymId: asString(t['gymId']),
      specialization: asString(t['specialization']),
      experience: asInt(t['experience']),
      status: asString(t['status'], fallback: 'ACTIVE'),
      createdAt: asDate(t['createdAt']),
      totalClients: asInt(stats['totalClients']),
      completedSessions: asInt(stats['completedSessions']),
      trainingHours: asDouble(stats['trainingHours']),
    );
  }

  String get initials => initialsOf(name);

  String get experienceLabel =>
      experience <= 0 ? '-' : '$experience Year${experience == 1 ? '' : 's'}';

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}

// =============================================================================
// WORKOUT PLAN  (no backend endpoint yet — kept in memory only)
// =============================================================================

class WorkoutPlan {
  final String title;
  final List<String> exercises;
  final String notes;
  final DateTime assignedOn;

  const WorkoutPlan({
    required this.title,
    required this.exercises,
    required this.notes,
    required this.assignedOn,
  });
}

// =============================================================================
// CLIENT  —  GET /api/trainers/clients
// Progress fields are filled from GET /api/trainers/progress (clientProgress)
// or GET /api/trainers/progress/clients/{clientId}.
// =============================================================================

class TrainerClient {
  /// Business id used by every trainer endpoint (e.g. "0001").
  final String id;

  /// Mongo `_id`.
  final String mongoId;
  final String name;
  final String phone;
  final String email;
  final String gymId;
  final String trainerId;

  /// Raw plan code, e.g. "PREMIUM".
  final String membershipPlan;

  /// Display name from the API, e.g. "PREMIUM Plan".
  final String planName;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Raw status: ACTIVE | EXPIRING | EXPIRED
  final String apiStatus;

  // Progress (0 when the progress endpoint has not been loaded yet)
  int progress; // 0 - 100
  int totalSessions;
  int completedSessions;
  int scheduledSessions;
  int cancelledSessions;
  double trainingHours;

  WorkoutPlan? workoutPlan;

  TrainerClient({
    required this.id,
    required this.mongoId,
    required this.name,
    required this.phone,
    required this.email,
    required this.gymId,
    required this.trainerId,
    required this.membershipPlan,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.apiStatus,
    this.progress = 0,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.scheduledSessions = 0,
    this.cancelledSessions = 0,
    this.trainingHours = 0,
    this.workoutPlan,
  });

  factory TrainerClient.fromJson(Map<String, dynamic> json) {
    final plan = asString(json['membershipPlan']);
    return TrainerClient(
      id: asString(json['clientId']),
      mongoId: asString(json['_id'] ?? json['id']),
      name: asString(json['fullName']),
      phone: asString(json['phone']),
      email: asString(json['email']),
      gymId: asString(json['gymId']),
      trainerId: asString(json['trainerId']),
      membershipPlan: plan,
      planName: asString(
        json['planName'],
        fallback: plan.isEmpty ? '-' : '${titleCase(plan)} Plan',
      ),
      startDate: asDate(json['startDate']),
      endDate: asDate(json['endDate']),
      apiStatus: asString(json['status'], fallback: 'ACTIVE').toUpperCase(),
    );
  }

  /// Copies progress numbers from a `clientProgress` item or a
  /// `progress` block of the client-progress endpoint.
  void applyProgress(Map<String, dynamic> json) {
    progress = asInt(
      json['progress'] ?? json['percentage'],
    ).clamp(0, 100).toInt();
    totalSessions = asInt(json['totalSessions']);
    completedSessions = asInt(json['completedSessions']);
    scheduledSessions = asInt(json['scheduledSessions']);
    cancelledSessions = asInt(json['cancelledSessions']);
    trainingHours = asDouble(json['trainingHours']);
  }

  String get initials => initialsOf(name);

  /// "Premium"
  String get plan => membershipPlan.isEmpty ? '-' : titleCase(membershipPlan);

  /// Kept for older widgets that still read `client.goal`; the backend has no
  /// goal field, so this shows the membership plan instead.
  String get goal => planName;

  /// Completed sessions (kept for older widgets reading `client.sessions`).
  int get sessions => completedSessions;

  /// Active / Expiring / Expired — straight from the backend.
  String get status => titleCase(apiStatus);

  DateTime get expiry => endDate ?? DateTime.now();

  String get expiryLabel => endDate == null ? '-' : formatShortDate(endDate!);

  String get startLabel =>
      startDate == null ? '-' : formatShortDate(startDate!);

  int get daysLeft {
    if (endDate == null) return 0;
    return dateOnly(endDate!).difference(dateOnly(DateTime.now())).inDays;
  }
}

// =============================================================================
// TRAINING SESSION  —  /api/trainers/sessions
// =============================================================================

class TrainingSession {
  final String id;
  String clientId;
  String clientName;
  String membershipPlan;
  DateTime start;
  int durationMinutes;
  String type;
  String location;
  SessionStatus status;
  String notes;

  TrainingSession({
    required this.id,
    required this.clientId,
    required this.start,
    required this.durationMinutes,
    required this.type,
    required this.location,
    this.clientName = '',
    this.membershipPlan = '',
    this.status = SessionStatus.upcoming,
    this.notes = '',
  });

  /// Works for list items ({id, clientName, ...}) and the detail response
  /// ({_id, client: {...}}).
  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final client = json['client'] is Map
        ? Map<String, dynamic>.from(json['client'])
        : const <String, dynamic>{};

    final day = asDate(json['date']) ?? dateOnly(DateTime.now());
    final time = parseApiTime(asString(json['time']));

    return TrainingSession(
      id: asString(json['id'] ?? json['_id']),
      clientId: asString(json['clientId'] ?? client['clientId']),
      clientName: asString(json['clientName'] ?? client['fullName']),
      membershipPlan: asString(
        json['membershipPlan'] ?? client['membershipPlan'],
      ),
      start: DateTime(day.year, day.month, day.day, time.hour, time.minute),
      durationMinutes: asInt(json['duration'], fallback: 60),
      type: asString(json['sessionType'], fallback: 'Personal Training'),
      location: asString(json['location']),
      status: SessionStatusApi.fromApi(asString(json['status'])),
      notes: asString(json['notes']),
    );
  }

  /// Body for POST /api/trainers/sessions and for full updates.
  Map<String, dynamic> toApiJson() => {
    'clientId': clientId,
    'date': formatApiDate(start),
    'time': formatTime(start),
    'duration': durationMinutes,
    'sessionType': type,
    'location': location,
    if (notes.isNotEmpty) 'notes': notes,
  };

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  bool get isCompleted => status == SessionStatus.completed;

  bool get isCancelled => status == SessionStatus.cancelled;

  String get statusLabel {
    switch (status) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.upcoming:
        return 'Upcoming';
    }
  }

  /// Rough calorie estimate per session type (kcal per minute).
  String get calories {
    const perMinute = {
      'Personal Training': 7.0,
      'Strength Training': 8.5,
      'HIIT Workout': 10.2,
      'Cardio Training': 6.5,
      'Weight Loss Session': 8.0,
      'Muscle Building': 8.5,
      'Mobility & Stretching': 3.5,
    };
    final kcal = (perMinute[type] ?? 7.0) * durationMinutes;
    return '${kcal.round()} kcal';
  }

  TrainingSession copy() => TrainingSession(
    id: id,
    clientId: clientId,
    clientName: clientName,
    membershipPlan: membershipPlan,
    start: start,
    durationMinutes: durationMinutes,
    type: type,
    location: location,
    status: status,
    notes: notes,
  );
}

// =============================================================================
// DASHBOARD  —  GET /api/trainers/dashboard
// =============================================================================

class DaySessionCount {
  final String day; // Mon..Sun
  final int sessions;
  final int completed;

  const DaySessionCount({
    required this.day,
    required this.sessions,
    this.completed = 0,
  });

  factory DaySessionCount.fromJson(Map<String, dynamic> json) =>
      DaySessionCount(
        day: asString(json['day']),
        sessions: asInt(json['sessions']),
        completed: asInt(json['completed']),
      );
}

class TrainerDashboardData {
  final int totalClients;
  final int activeClients;
  final int todaySessions;
  final int scheduledToday;
  final int completedToday;
  final int totalCompletedSessions;
  final List<TrainingSession> todaySchedule;
  final List<DaySessionCount> weeklySessions;

  const TrainerDashboardData({
    this.totalClients = 0,
    this.activeClients = 0,
    this.todaySessions = 0,
    this.scheduledToday = 0,
    this.completedToday = 0,
    this.totalCompletedSessions = 0,
    this.todaySchedule = const [],
    this.weeklySessions = const [],
  });

  factory TrainerDashboardData.fromJson(Map<String, dynamic> json) {
    final o = json['overview'] is Map
        ? Map<String, dynamic>.from(json['overview'])
        : const <String, dynamic>{};
    return TrainerDashboardData(
      totalClients: asInt(o['totalClients']),
      activeClients: asInt(o['activeClients']),
      todaySessions: asInt(o['todaySessions']),
      scheduledToday: asInt(o['scheduledToday']),
      completedToday: asInt(o['completedToday']),
      totalCompletedSessions: asInt(o['totalCompletedSessions']),
      todaySchedule: asMapList(
        json['todaySchedule'],
      ).map(TrainingSession.fromJson).toList(),
      weeklySessions: asMapList(
        json['weeklySessions'],
      ).map(DaySessionCount.fromJson).toList(),
    );
  }
}

// =============================================================================
// PROGRESS  —  GET /api/trainers/progress
// =============================================================================

class TrainerProgressData {
  final int totalClients;
  final int totalSessions;
  final int completedSessions;
  final int scheduledSessions;
  final int cancelledSessions;
  final double trainingHours;
  final double averageSessionDuration;
  final double completionRate; // 0 - 100
  final int completedThisMonth;
  final List<DaySessionCount> weeklyPerformance;

  const TrainerProgressData({
    this.totalClients = 0,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.scheduledSessions = 0,
    this.cancelledSessions = 0,
    this.trainingHours = 0,
    this.averageSessionDuration = 0,
    this.completionRate = 0,
    this.completedThisMonth = 0,
    this.weeklyPerformance = const [],
  });

  factory TrainerProgressData.fromJson(Map<String, dynamic> json) {
    final o = json['overview'] is Map
        ? Map<String, dynamic>.from(json['overview'])
        : const <String, dynamic>{};
    final m = json['thisMonth'] is Map
        ? Map<String, dynamic>.from(json['thisMonth'])
        : const <String, dynamic>{};
    return TrainerProgressData(
      totalClients: asInt(o['totalClients']),
      totalSessions: asInt(o['totalSessions']),
      completedSessions: asInt(o['completedSessions']),
      scheduledSessions: asInt(o['scheduledSessions']),
      cancelledSessions: asInt(o['cancelledSessions']),
      trainingHours: asDouble(o['trainingHours']),
      averageSessionDuration: asDouble(o['averageSessionDuration']),
      completionRate: asDouble(o['completionRate']),
      completedThisMonth: asInt(m['completedSessions']),
      weeklyPerformance: asMapList(
        json['weeklyPerformance'],
      ).map(DaySessionCount.fromJson).toList(),
    );
  }
}

/// Response of GET /api/trainers/clients (overview block).
class ClientOverview {
  final int total;
  final int active;
  final int expiring;
  final int expired;

  const ClientOverview({
    this.total = 0,
    this.active = 0,
    this.expiring = 0,
    this.expired = 0,
  });

  factory ClientOverview.fromJson(Map<String, dynamic> json) => ClientOverview(
    total: asInt(json['total']),
    active: asInt(json['active']),
    expiring: asInt(json['expiring']),
    expired: asInt(json['expired']),
  );

  int countFor(String label) {
    switch (label) {
      case 'Active':
        return active;
      case 'Expiring':
        return expiring;
      case 'Expired':
        return expired;
      default:
        return total;
    }
  }
}

/// Response of GET /api/trainers/progress/clients/{clientId}.
class ClientProgressDetail {
  final TrainerClient client;
  final List<TrainingSession> sessions;

  const ClientProgressDetail({required this.client, required this.sessions});

  factory ClientProgressDetail.fromJson(Map<String, dynamic> json) {
    final c = json['client'] is Map
        ? Map<String, dynamic>.from(json['client'])
        : <String, dynamic>{};
    final client = TrainerClient.fromJson(c);
    if (json['progress'] is Map) {
      client.applyProgress(Map<String, dynamic>.from(json['progress']));
    }
    return ClientProgressDetail(
      client: client,
      sessions: asMapList(
        json['sessions'],
      ).map(TrainingSession.fromJson).toList(),
    );
  }
}

// =============================================================================
// CONSTANTS
// =============================================================================

class TrainerOptions {
  static const List<String> sessionTypes = [
    'Personal Training',
    'Strength Training',
    'HIIT Workout',
    'Cardio Training',
    'Weight Loss Session',
    'Muscle Building',
    'Mobility & Stretching',
  ];

  /// Same text format the backend stores ("Gym Floor - Zone A").
  static const List<String> locations = [
    'Gym Floor - Zone A',
    'Weight Area - Zone B',
    'Functional Area',
    'Cardio Zone',
    'Studio Room',
  ];

  static const List<int> durations = [30, 45, 60, 90];

  static const Map<String, List<String>> workoutTemplates = {
    'Strength Builder': [
      'Barbell Squat — 4 x 8',
      'Bench Press — 4 x 8',
      'Deadlift — 3 x 6',
      'Overhead Press — 3 x 10',
      'Plank — 3 x 45 sec',
    ],
    'Fat Loss Circuit': [
      'Jump Rope — 3 min',
      'Kettlebell Swings — 4 x 15',
      'Burpees — 4 x 12',
      'Mountain Climbers — 3 x 30 sec',
      'Incline Walk — 15 min',
    ],
    'Muscle Gain (Push/Pull)': [
      'Incline Dumbbell Press — 4 x 10',
      'Lat Pulldown — 4 x 10',
      'Seated Row — 3 x 12',
      'Lateral Raises — 3 x 15',
      'Bicep Curl + Tricep Pushdown — 3 x 12',
    ],
    'Cardio Endurance': [
      'Treadmill Intervals — 20 min',
      'Rowing — 10 min',
      'Cycling — 15 min',
      'Stair Climber — 8 min',
    ],
    'Full Body Toning': [
      'Goblet Squat — 3 x 12',
      'Push Ups — 3 x 12',
      'Walking Lunges — 3 x 20',
      'Cable Row — 3 x 12',
      'Glute Bridge — 3 x 15',
    ],
  };

  static IconData iconForType(String type) {
    switch (type) {
      case 'Strength Training':
        return Icons.fitness_center_rounded;
      case 'HIIT Workout':
        return Icons.local_fire_department_rounded;
      case 'Cardio Training':
        return Icons.directions_run_rounded;
      case 'Weight Loss Session':
        return Icons.monitor_weight_rounded;
      case 'Muscle Building':
        return Icons.sports_gymnastics_rounded;
      case 'Mobility & Stretching':
        return Icons.self_improvement_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  static Color colorForType(String type) {
    switch (type) {
      case 'Strength Training':
      case 'Muscle Building':
        return const Color(0xFF38BDF8);
      case 'HIIT Workout':
        return const Color(0xFF22C55E);
      case 'Weight Loss Session':
        return const Color(0xFFFFA000);
      default:
        return const Color(0xFFFFC107);
    }
  }
}

// =============================================================================
// JSON HELPERS (tolerant of null / wrong types from the API)
// =============================================================================

String asString(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  final s = v.toString();
  return s.isEmpty ? fallback : s;
}

int asInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v?.toString() ?? '') ??
      double.tryParse(v?.toString() ?? '')?.round() ??
      fallback;
}

double asDouble(dynamic v, {double fallback = 0}) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

/// Reads the calendar date the backend meant. "2026-09-27T00:00:00.000Z" is
/// read as 27 Sep (local), not shifted by the device time zone.
DateTime? asDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  final full = DateTime.tryParse(s);
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  final isPureDate =
      s.length == 10 ||
      (full != null &&
          full.isUtc &&
          full.hour == 0 &&
          full.minute == 0 &&
          full.second == 0 &&
          full.millisecond == 0);
  if (m != null && isPureDate) {
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }
  return full?.toLocal();
}

List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return const [];
  return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

/// "12:00 PM" / "09:30 am" / "18:15" -> TimeOfDay
TimeOfDay parseApiTime(String raw) {
  final m = RegExp(
    r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])?\s*$',
  ).firstMatch(raw);
  if (m == null) return const TimeOfDay(hour: 0, minute: 0);
  var hour = int.parse(m.group(1)!);
  final minute = int.parse(m.group(2)!);
  final period = m.group(3)?.toUpperCase();
  if (period == 'PM' && hour < 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  return TimeOfDay(hour: hour % 24, minute: minute % 60);
}

/// "2026-09-27"
String formatApiDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// "PREMIUM" -> "Premium", "EXPIRING" -> "Expiring"
String titleCase(String s) {
  if (s.isEmpty) return s;
  return s
      .toLowerCase()
      .split(RegExp(r'[\s_]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

// =============================================================================
// DATE HELPERS
// =============================================================================

const List<String> kMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> kWeekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfWeek(DateTime d) =>
    dateOnly(d).subtract(Duration(days: d.weekday - 1));

/// "12:00 PM" — also the format sent to the backend.
String formatTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour < 12 ? 'AM' : 'PM';
  return '${hour12.toString().padLeft(2, '0')}:$minute $period';
}

/// "Monday, September 16"
String formatFullDate(DateTime d) =>
    '${kWeekdayNames[d.weekday - 1]}, ${kMonthNames[d.month - 1]} ${d.day}';

/// "September 16, 2026"
String formatLongDate(DateTime d) =>
    '${kMonthNames[d.month - 1]} ${d.day}, ${d.year}';

/// "28 Sep 2026"
String formatShortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${kMonthNames[d.month - 1].substring(0, 3)} ${d.year}';

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
  return letters.isEmpty ? '?' : letters;
}
