import 'package:flutter/material.dart';

// =============================================================================
// TRAINER MODELS
// Clients are ASSIGNED to a trainer by the gym owner. A trainer can only view
// their assigned clients, schedule sessions with them and assign workouts.
// =============================================================================

enum SessionStatus { upcoming, completed }

class TrainerProfile {
  String name;
  String email;
  String phone;
  String location;
  String specialization;
  String experience;
  String certification;
  final String gymName;
  final String gymId;
  final double rating;

  TrainerProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialization,
    required this.experience,
    required this.certification,
    required this.gymName,
    required this.gymId,
    required this.rating,
  });

  String get initials => initialsOf(name);
}

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

class TrainerClient {
  final String id;
  final String name;
  final String goal;
  final String plan;
  final DateTime expiry;
  final String age;
  final String height;
  final String weight;

  int progress; // 0 - 100
  int attendance; // 0 - 100
  int sessions; // sessions completed in current package
  int remainingSessions; // sessions left in current package
  WorkoutPlan? workoutPlan;

  TrainerClient({
    required this.id,
    required this.name,
    required this.goal,
    required this.plan,
    required this.expiry,
    required this.age,
    required this.height,
    required this.weight,
    required this.progress,
    required this.attendance,
    required this.sessions,
    required this.remainingSessions,
    this.workoutPlan,
  });

  String get initials => initialsOf(name);

  /// Active / Expiring (within 7 days) / Expired — computed from membership expiry.
  String get status {
    final today = dateOnly(DateTime.now());
    final end = dateOnly(expiry);
    if (end.isBefore(today)) return 'Expired';
    if (end.difference(today).inDays <= 7) return 'Expiring';
    return 'Active';
  }

  String get expiryLabel => formatShortDate(expiry);
}

class TrainingSession {
  final String id;
  String clientId;
  DateTime start;
  int durationMinutes;
  String type;
  String location;
  SessionStatus status;

  TrainingSession({
    required this.id,
    required this.clientId,
    required this.start,
    required this.durationMinutes,
    required this.type,
    required this.location,
    this.status = SessionStatus.upcoming,
  });

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  bool get isCompleted => status == SessionStatus.completed;

  String get statusLabel => isCompleted ? 'Completed' : 'Upcoming';

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
    start: start,
    durationMinutes: durationMinutes,
    type: type,
    location: location,
    status: status,
  );
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

  static const List<String> locations = [
    'Gym Floor • Zone A',
    'Weight Area • Zone B',
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
