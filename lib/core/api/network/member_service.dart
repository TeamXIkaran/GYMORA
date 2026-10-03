import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';

class MemberService {
  const MemberService();

  Future<ClientLoginResponse> login({
    required String clientId,
    required String password,
  }) async {
    final response = await ApiService.post('api/client/auth/login', {
      'clientId': clientId,
      'password': password,
    });
    return ClientLoginResponse.fromJson(_data(response));
  }

  Future<MemberDashboardData> getDashboard() async {
    final responses = await Future.wait([
      ApiService.get('api/client/dashboard'),
      ApiService.get('api/client/workouts'),
      // Non-critical endpoints: a failure here must not block the dashboard.
      _optional('api/client/progress'),
      _optional('api/client/progress/measurements'),
      _optional('api/client/nutrition'),
      ApiService.get('api/client/profile'),
    ]);
    final dashboard = _data(responses[0]);
    final workoutsData = _data(responses[1]);
    final progress = _data(responses[2]);
    final measurementData = _data(responses[3]);
    final nutrition = _data(responses[4]);
    final profileData = _data(responses[5]);

    final personal = _asMap(profileData['personalInfo']);
    final membership = _asMap(profileData['membership']);
    final trainer = _asMap(profileData['trainer']);
    final currentMeasurement = _asMap(profileData['measurements']);
    final nutritionGoals = _asMap(nutrition['macros']);
    final calories = _asMap(nutrition['calories']);
    final workouts = _asList(
      workoutsData['workouts'],
    ).map((item) => WorkoutPlan.fromJson(_asMap(item))).toList();
    final measurements = _asList(
      measurementData['measurements'],
    ).map((item) => BodyMeasurement.fromJson(_asMap(item))).toList();
    if (measurements.isEmpty) {
      final progressMeasurement = _asMap(progress['current']);
      final fallbackMeasurement = currentMeasurement.isNotEmpty
          ? currentMeasurement
          : progressMeasurement;
      if (fallbackMeasurement.isNotEmpty) {
        measurements.add(BodyMeasurement.fromJson(fallbackMeasurement));
      }
    }
    measurements.sort((a, b) => a.date.compareTo(b.date));

    final latestWorkout = _currentWorkout(workouts);
    final goals = _asMap(dashboard['weeklyGoal']);
    final hydration = _asMap(nutrition['hydration']);
    final meals = _asList(
      nutrition['meals'],
    ).map((item) => Meal.fromJson(_asMap(item))).toList();
    final profile = MemberProfile.fromJson({
      ...personal,
      'memberId': personal['clientId'],
      'planName': membership['planName'],
      'memberSince': membership['startDate'],
      'validUntil': membership['endDate'],
      'trainerName': trainer['fullName'],
      'heightCm': currentMeasurement['height'],
      'primaryGoal': 'Not set',
      'targetWeightKg': 0,
      'weeklyWorkoutTarget': goals['target'],
      'dailyCalorieTarget': calories['goal'],
      'proteinTargetG': _asMap(nutritionGoals['protein'])['goal'],
      'carbsTargetG': _asMap(nutritionGoals['carbs'])['goal'],
      'fatTargetG': _asMap(nutritionGoals['fat'])['goal'],
    });

    return MemberDashboardData(
      profile: profile,
      plan:
          latestWorkout ??
          const WorkoutPlan(
            title: 'No workout assigned',
            focus: '',
            difficulty: '',
            durationMinutes: 0,
            estimatedCalories: 0,
            exercises: [],
          ),
      meals: meals,
      measurements: measurements,
      achievements: const [],
      notifications: const [],
      activity: DailyActivity(
        steps: 0,
        stepGoal: 0,
        waterMl: _asInt(hydration['consumed']),
        waterGoalMl: _asInt(hydration['goal']),
        activeMinutes: _asInt(_asMap(dashboard['today'])['activeMinutes']),
      ),
      weeklyMinutes: _weeklyWorkoutMinutes(workouts),
      streakDays: 0,
      totalWorkouts: _asInt(dashboard['totalCompletedSessions']),
      coachTip: '',
    );
  }

  Future<BodyMeasurement> saveMeasurement(BodyMeasurement measurement) async {
    final response = await ApiService.post('api/client/progress/measurements', {
      'weight': measurement.weightKg,
      'bodyFat': measurement.bodyFatPercent,
      if (measurement.waistCm != null) 'waist': measurement.waistCm,
    });
    final data = _data(response);
    final payload = data['measurement'] ?? data;
    final saved = BodyMeasurement.fromJson(_asMap(payload));
    // If the server only acknowledged the request (no measurement echoed
    // back), keep what the member actually entered.
    return saved.weightKg == 0 ? measurement : saved;
  }

  Future<void> startWorkout(String workoutId) async {
    await ApiService.post(
      'api/client/workouts/${Uri.encodeComponent(workoutId)}/start',
      const {},
    );
  }

  Future<void> completeExercise({
    required String workoutId,
    required String exerciseId,
  }) async {
    await ApiService.post(
      'api/client/workouts/${Uri.encodeComponent(workoutId)}'
      '/exercises/${Uri.encodeComponent(exerciseId)}/complete',
      const {},
    );
  }

  Future<Meal> logMeal({
    required MealType type,
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final response = await ApiService.post('api/client/nutrition/meals', {
      'mealType': type.name.toUpperCase(),
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    });
    final data = _data(response);
    return Meal.fromJson(_asMap(data['meal'] ?? data));
  }

  Future<void> addHydration(int amount, {required bool add}) async {
    await ApiService.post('api/client/nutrition/hydration', {
      'amount': amount,
      'action': add ? 'ADD' : 'REMOVE',
    });
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> changes,
  ) async {
    final response = await ApiService.patch('api/client/profile', changes);
    return _data(response);
  }
}

/// GET that never throws: used for endpoints the dashboard can live without.
Future<Map<String, dynamic>> _optional(String endpoint) async {
  try {
    return await ApiService.get(endpoint);
  } catch (_) {
    return <String, dynamic>{};
  }
}

Map<String, dynamic> _data(Map<String, dynamic> response) =>
    _asMap(response['data'] ?? response);

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

WorkoutPlan? _currentWorkout(List<WorkoutPlan> workouts) {
  if (workouts.isEmpty) return null;
  for (final workout in workouts) {
    if (workout.status == 'IN_PROGRESS') return workout;
  }
  final assigned = workouts.where((w) => w.status == 'ASSIGNED').toList();
  if (assigned.isNotEmpty) {
    // The API's list ordering is not guaranteed. Prefer the most recently
    // assigned plan so an older pending plan cannot hide a trainer's update.
    assigned.sort((a, b) {
      final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    final now = DateTime.now();
    for (final workout in assigned) {
      final date = workout.date?.toLocal();
      if (date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return workout;
      }
    }
    return assigned.first;
  }
  return workouts.first;
}

List<int> _weeklyWorkoutMinutes(List<WorkoutPlan> workouts) {
  final today = DateTime.now();
  final start = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(days: 6));
  final minutes = List<int>.filled(7, 0);
  for (final workout in workouts) {
    // Only finished sessions count as active days.
    if (workout.status != 'COMPLETED') continue;
    final date = workout.date?.toLocal();
    if (date == null) continue;
    final day = DateTime(date.year, date.month, date.day);
    final index = day.difference(start).inDays;
    if (index >= 0 && index < minutes.length) {
      minutes[index] += workout.durationMinutes;
    }
  }
  return minutes;
}

/// Lenient: a missing or malformed section becomes an empty map instead of
/// failing the whole dashboard load.
Map<String, dynamic> _asMap(dynamic value, [String fieldName = 'value']) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
