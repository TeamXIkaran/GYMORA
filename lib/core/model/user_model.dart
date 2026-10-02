import 'package:flutter/foundation.dart';

Map<String, dynamic> _asMap(dynamic value, [String fieldName = 'value']) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected a map for $fieldName but received $value');
}

List<dynamic> _asList(dynamic value, [String fieldName = 'value']) {
  if (value == null) return const [];
  if (value is List) return value;
  throw FormatException('Expected a list for $fieldName but received $value');
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

DateTime _parseDate(dynamic value, {DateTime? fallback}) {
  if (value == null) return fallback ?? DateTime.now();
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback ?? DateTime.now();
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };

  bool get isOwner => role == 'owner';
  bool get isTrainer => role == 'trainer';
  bool get isClient => role == 'client';

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class CreateUserRequest {
  final String name;
  final String email;
  final String password;

  const CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final UserModel user;

  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ClientLoginResponse {
  final String token;
  final UserModel client;

  const ClientLoginResponse({required this.token, required this.client});

  factory ClientLoginResponse.fromJson(Map<String, dynamic> json) {
    final client = _asMap(json['client'], 'client');
    return ClientLoginResponse(
      token: _asString(json['token']),
      client: UserModel(
        id: _asString(client['id'] ?? client['_id']),
        name: _asString(client['fullName']),
        email: _asString(client['email']),
        role: 'client',
      ),
    );
  }
}

enum AchievementKind {
  streak,
  workouts,
  hydration,
  tracking,
  nutrition,
  earlyBird,
}

@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
  });

  final String id;
  final AchievementKind kind;
  final String title;
  final String description;
  final int current;
  final int target;

  bool get unlocked => current >= target;

  double get progress => target == 0 ? 1 : (current / target).clamp(0.0, 1.0);

  String get progressLabel => unlocked ? 'Unlocked' : '$current / $target';

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: _asString(json['id']),
      kind: _achievementKindFromJson(json['kind']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      current: _asInt(json['current']),
      target: _asInt(json['target']),
    );
  }

  static AchievementKind _achievementKindFromJson(dynamic value) {
    final raw = _asString(value).toLowerCase();
    switch (raw) {
      case 'streak':
        return AchievementKind.streak;
      case 'workouts':
        return AchievementKind.workouts;
      case 'hydration':
        return AchievementKind.hydration;
      case 'tracking':
        return AchievementKind.tracking;
      case 'nutrition':
        return AchievementKind.nutrition;
      case 'earlybird':
      case 'early_bird':
        return AchievementKind.earlyBird;
      default:
        return AchievementKind.tracking;
    }
  }
}

@immutable
class BodyMeasurement {
  const BodyMeasurement({
    required this.date,
    required this.weightKg,
    required this.bodyFatPercent,
    this.waistCm,
  });

  final DateTime date;
  final double weightKg;
  final double bodyFatPercent;
  final double? waistCm;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      date: _parseDate(json['date'] ?? json['recordedAt']),
      weightKg: _asDouble(json['weightKg'] ?? json['weight']),
      bodyFatPercent: _asDouble(json['bodyFatPercent'] ?? json['bodyFat']),
      waistCm: (json['waistCm'] ?? json['waist']) == null
          ? null
          : _asDouble(json['waistCm'] ?? json['waist']),
    );
  }
}

@immutable
class DailyActivity {
  const DailyActivity({
    required this.steps,
    required this.stepGoal,
    required this.waterMl,
    required this.waterGoalMl,
    required this.activeMinutes,
  });

  final int steps;
  final int stepGoal;
  final int waterMl;
  final int waterGoalMl;
  final int activeMinutes;

  double get stepProgress =>
      stepGoal == 0 ? 0 : (steps / stepGoal).clamp(0.0, 1.0);

  double get waterProgress =>
      waterGoalMl == 0 ? 0 : (waterMl / waterGoalMl).clamp(0.0, 1.0);

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      steps: _asInt(json['steps']),
      stepGoal: _asInt(json['stepGoal']),
      waterMl: _asInt(json['waterMl']),
      waterGoalMl: _asInt(json['waterGoalMl']),
      activeMinutes: _asInt(json['activeMinutes']),
    );
  }

  DailyActivity copyWith({int? steps, int? waterMl, int? activeMinutes}) {
    return DailyActivity(
      steps: steps ?? this.steps,
      stepGoal: stepGoal,
      waterMl: waterMl ?? this.waterMl,
      waterGoalMl: waterGoalMl,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }
}

enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  arms('Arms'),
  core('Core'),
  legs('Legs');

  const MuscleGroup(this.label);

  final String label;
}

/// A single exercise inside today's workout plan.
///
/// Immutable: progress is tracked through [completedSets] and updated with
/// [copyWith] by the controller.
@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.unit = 'reps',
    this.weightKg,
    this.completedSets = 0,
    this.instructions = '',
    this.tips = const [],
  });

  final String id;
  final String name;
  final MuscleGroup muscle;
  final String equipment;
  final int sets;
  final int reps;
  final int restSeconds;

  /// "reps" or "sec" (for timed holds such as planks).
  final String unit;
  final double? weightKg;
  final int completedSets;
  final String instructions;
  final List<String> tips;

  bool get isCompleted => completedSets >= sets;

  bool get isStarted => completedSets > 0;

  bool get isTimed => unit == 'sec';

  double get progress => sets == 0 ? 0 : (completedSets / sets).clamp(0.0, 1.0);

  String get subtitle => '${muscle.label} • $equipment';

  String get targetLabel => '$sets × $reps $unit';

  String get repsLabel => '$reps ${isTimed ? 'sec' : 'reps'}';

  String? get weightLabel {
    final kg = weightKg;
    if (kg == null) return null;
    return kg % 1 == 0
        ? '${kg.toStringAsFixed(0)} kg'
        : '${kg.toStringAsFixed(1)} kg';
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final sets = _asInt(json['sets']);
    return Exercise(
      id: _asString(json['id'] ?? json['_id']),
      name: _asString(json['name']),
      muscle: _muscleFromJson(json['muscle']),
      equipment: _asString(json['equipment'], fallback: 'Bodyweight'),
      sets: sets,
      reps: _asInt(json['reps']),
      restSeconds: _asInt(json['restSeconds']),
      unit: _asString(json['unit'], fallback: 'reps'),
      weightKg: (json['weightKg'] ?? json['weight']) == null
          ? null
          : _asDouble(json['weightKg'] ?? json['weight']),
      completedSets: json['completed'] == true
          ? sets
          : _asInt(json['completedSets']),
      instructions: _asString(json['instructions']),
      tips: _asList(json['tips']).map((item) => _asString(item)).toList(),
    );
  }

  static MuscleGroup _muscleFromJson(dynamic value) {
    final raw = _asString(value).toLowerCase();
    for (final muscle in MuscleGroup.values) {
      if (muscle.name == raw || muscle.label.toLowerCase() == raw) {
        return muscle;
      }
    }
    return MuscleGroup.core;
  }

  Exercise copyWith({int? completedSets}) {
    return Exercise(
      id: id,
      name: name,
      muscle: muscle,
      equipment: equipment,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      unit: unit,
      weightKg: weightKg,
      completedSets: (completedSets ?? this.completedSets).clamp(0, sets),
      instructions: instructions,
      tips: tips,
    );
  }
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  snack('Snack'),
  dinner('Dinner');

  const MealType(this.label);

  final String label;
}

@immutable
class Meal {
  const Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.time,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.items = const [],
    this.logged = false,
  });

  final String id;
  final MealType type;

  /// e.g. "Oats + Eggs".
  final String name;

  /// Display time, e.g. "8:00 AM".
  final String time;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<String> items;
  final bool logged;

  factory Meal.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    final parsedTime = createdAt == null
        ? null
        : _parseDate(createdAt).toLocal();
    return Meal(
      id: _asString(json['id'] ?? json['_id']),
      type: _mealTypeFromJson(json['type'] ?? json['mealType']),
      name: _asString(json['name']),
      time: _asString(
        json['time'],
        fallback: parsedTime == null
            ? '—'
            : '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}',
      ),
      calories: _asInt(json['calories']),
      proteinG: _asInt(json['proteinG'] ?? json['protein']),
      carbsG: _asInt(json['carbsG'] ?? json['carbs']),
      fatG: _asInt(json['fatG'] ?? json['fat']),
      items: _asList(json['items']).map((item) => _asString(item)).toList(),
      logged: json['logged'] == null ? true : json['logged'] == true,
    );
  }

  static MealType _mealTypeFromJson(dynamic value) {
    final raw = _asString(value).toLowerCase();
    switch (raw) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.breakfast;
    }
  }

  Meal copyWith({bool? logged}) {
    return Meal(
      id: id,
      type: type,
      name: name,
      time: time,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      items: items,
      logged: logged ?? this.logged,
    );
  }
}

/// Everything the member dashboard needs, loaded in one call.
@immutable
class MemberDashboardData {
  const MemberDashboardData({
    required this.profile,
    required this.plan,
    required this.meals,
    required this.measurements,
    required this.achievements,
    required this.notifications,
    required this.activity,
    required this.weeklyMinutes,
    required this.streakDays,
    required this.totalWorkouts,
    required this.coachTip,
  });

  final MemberProfile profile;
  final WorkoutPlan plan;
  final List<Meal> meals;

  /// Sorted oldest → newest.
  final List<BodyMeasurement> measurements;
  final List<Achievement> achievements;
  final List<MemberNotification> notifications;
  final DailyActivity activity;

  /// Active minutes for the last 7 days, oldest → today (length 7).
  final List<int> weeklyMinutes;
  final int streakDays;
  final int totalWorkouts;
  final String coachTip;

  factory MemberDashboardData.fromJson(Map<String, dynamic> json) {
    return MemberDashboardData(
      profile: MemberProfile.fromJson(_asMap(json['profile'], 'profile')),
      plan: WorkoutPlan.fromJson(_asMap(json['plan'], 'plan')),
      meals: _asList(
        json['meals'],
      ).map((item) => Meal.fromJson(_asMap(item))).toList(),
      measurements: _asList(
        json['measurements'],
      ).map((item) => BodyMeasurement.fromJson(_asMap(item))).toList(),
      achievements: _asList(
        json['achievements'],
      ).map((item) => Achievement.fromJson(_asMap(item))).toList(),
      notifications: _asList(
        json['notifications'],
      ).map((item) => MemberNotification.fromJson(_asMap(item))).toList(),
      activity: DailyActivity.fromJson(_asMap(json['activity'], 'activity')),
      weeklyMinutes: _asList(
        json['weeklyMinutes'],
      ).map((item) => _asInt(item)).toList(),
      streakDays: _asInt(json['streakDays']),
      totalWorkouts: _asInt(json['totalWorkouts']),
      coachTip: _asString(json['coachTip']),
    );
  }

  MemberDashboardData copyWith({
    MemberProfile? profile,
    WorkoutPlan? plan,
    List<Meal>? meals,
    List<BodyMeasurement>? measurements,
    List<Achievement>? achievements,
    List<MemberNotification>? notifications,
    DailyActivity? activity,
    List<int>? weeklyMinutes,
    int? streakDays,
    int? totalWorkouts,
    String? coachTip,
  }) {
    return MemberDashboardData(
      profile: profile ?? this.profile,
      plan: plan ?? this.plan,
      meals: meals ?? this.meals,
      measurements: measurements ?? this.measurements,
      achievements: achievements ?? this.achievements,
      notifications: notifications ?? this.notifications,
      activity: activity ?? this.activity,
      weeklyMinutes: weeklyMinutes ?? this.weeklyMinutes,
      streakDays: streakDays ?? this.streakDays,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      coachTip: coachTip ?? this.coachTip,
    );
  }
}

enum NotificationKind { workout, streak, nutrition, membership, trainer }

@immutable
class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;

  /// Pre-formatted relative time, e.g. "2h".
  final String timeAgo;
  final bool read;

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    return MemberNotification(
      id: _asString(json['id']),
      kind: _notificationKindFromJson(json['kind']),
      title: _asString(json['title']),
      message: _asString(json['message']),
      timeAgo: _asString(json['timeAgo']),
      read: json['read'] == true,
    );
  }

  static NotificationKind _notificationKindFromJson(dynamic value) {
    final raw = _asString(value).toLowerCase();
    switch (raw) {
      case 'workout':
        return NotificationKind.workout;
      case 'streak':
        return NotificationKind.streak;
      case 'nutrition':
        return NotificationKind.nutrition;
      case 'membership':
        return NotificationKind.membership;
      case 'trainer':
        return NotificationKind.trainer;
      default:
        return NotificationKind.workout;
    }
  }

  MemberNotification copyWith({bool? read}) {
    return MemberNotification(
      id: id,
      kind: kind,
      title: title,
      message: message,
      timeAgo: timeAgo,
      read: read ?? this.read,
    );
  }
}

@immutable
class MemberProfile {
  const MemberProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.memberId,
    required this.planName,
    required this.memberSince,
    required this.validUntil,
    required this.trainerName,
    required this.heightCm,
    required this.primaryGoal,
    required this.targetWeightKg,
    required this.weeklyWorkoutTarget,
    required this.dailyCalorieTarget,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
  });

  final String fullName;
  final String email;
  final String phone;
  final String memberId;

  /// e.g. "Pro · Annual".
  final String planName;
  final DateTime memberSince;
  final DateTime validUntil;
  final String trainerName;
  final double heightCm;
  final String primaryGoal;
  final double targetWeightKg;
  final int weeklyWorkoutTarget;
  final int dailyCalorieTarget;
  final int proteinTargetG;
  final int carbsTargetG;
  final int fatTargetG;

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      fullName: _asString(json['fullName']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      memberId: _asString(json['memberId']),
      planName: _asString(json['planName']),
      memberSince: _parseDate(json['memberSince']),
      validUntil: _parseDate(json['validUntil']),
      trainerName: _asString(json['trainerName']),
      heightCm: _asDouble(json['heightCm']),
      primaryGoal: _asString(json['primaryGoal']),
      targetWeightKg: _asDouble(json['targetWeightKg']),
      weeklyWorkoutTarget: _asInt(json['weeklyWorkoutTarget']),
      dailyCalorieTarget: _asInt(json['dailyCalorieTarget']),
      proteinTargetG: _asInt(json['proteinTargetG']),
      carbsTargetG: _asInt(json['carbsTargetG']),
      fatTargetG: _asInt(json['fatTargetG']),
    );
  }

  String get firstName => fullName.trim().split(' ').first;

  int daysLeft(DateTime now) {
    final days = validUntil.difference(now).inDays;
    return days < 0 ? 0 : days;
  }

  /// Fraction of the membership period already used (0..1).
  double membershipElapsed(DateTime now) {
    final total = validUntil.difference(memberSince).inDays;
    if (total <= 0) return 1;
    final used = now.difference(memberSince).inDays;
    return (used / total).clamp(0.0, 1.0);
  }
}

@immutable
class WorkoutPlan {
  const WorkoutPlan({
    this.id = '',
    this.status = '',
    this.date,
    required this.title,
    required this.focus,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
  });

  final String id;
  final String status;
  final DateTime? date;

  /// e.g. "Power Session".
  final String title;

  /// e.g. "Upper Body".
  final String focus;

  /// e.g. "Intermediate".
  final String difficulty;
  final int durationMinutes;
  final int estimatedCalories;
  final List<Exercise> exercises;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final muscleGroups = _asList(json['muscleGroups'])
        .map((item) => _asString(item))
        .where((item) => item.isNotEmpty)
        .join(' · ');
    return WorkoutPlan(
      id: _asString(json['id'] ?? json['_id']),
      status: _asString(json['status']).toUpperCase(),
      date: json['date'] == null ? null : _parseDate(json['date']),
      title: _asString(json['title']),
      focus: _asString(json['focus'], fallback: muscleGroups),
      difficulty: _asString(json['difficulty'], fallback: 'Assigned'),
      durationMinutes: _asInt(json['durationMinutes'] ?? json['duration']),
      estimatedCalories: _asInt(json['estimatedCalories']),
      exercises: _asList(
        json['exercises'],
      ).map((item) => Exercise.fromJson(_asMap(item))).toList(),
    );
  }

  /// Unique muscle groups in plan order.
  List<MuscleGroup> get muscles {
    final seen = <MuscleGroup>[];
    for (final exercise in exercises) {
      if (!seen.contains(exercise.muscle)) seen.add(exercise.muscle);
    }
    return seen;
  }

  WorkoutPlan copyWith({List<Exercise>? exercises}) {
    return WorkoutPlan(
      id: id,
      status: status,
      date: date,
      title: title,
      focus: focus,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      estimatedCalories: estimatedCalories,
      exercises: exercises ?? this.exercises,
    );
  }
}

/// Result of a finished workout session.
@immutable
class WorkoutSummary {
  const WorkoutSummary({
    required this.durationSeconds,
    required this.exercisesCompleted,
    required this.totalExercises,
    required this.setsCompleted,
    required this.totalSets,
    required this.estimatedCalories,
    required this.finishedAt,
  });

  final int durationSeconds;
  final int exercisesCompleted;
  final int totalExercises;
  final int setsCompleted;
  final int totalSets;
  final int estimatedCalories;
  final DateTime finishedAt;

  double get completion => totalSets == 0 ? 0 : setsCompleted / totalSets;
}
