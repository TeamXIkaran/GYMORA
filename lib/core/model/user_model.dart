import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
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
    required this.title,
    required this.focus,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
  });

  /// e.g. "Power Session".
  final String title;

  /// e.g. "Upper Body".
  final String focus;

  /// e.g. "Intermediate".
  final String difficulty;
  final int durationMinutes;
  final int estimatedCalories;
  final List<Exercise> exercises;

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
