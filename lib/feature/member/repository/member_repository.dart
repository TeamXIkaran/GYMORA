import 'package:gymora_fitness_management/core/model/user_model.dart';

/// Local, in-memory implementation used until the member API is available.
///
/// Every method is safe to call; writes are no-ops with a short delay so the
/// UI behaves like it would against a network.
class MockMemberRepository implements MemberRepository {
  const MockMemberRepository({
    this.latency = const Duration(milliseconds: 450),
  });

  final Duration latency;

  @override
  Future<MemberDashboardData> fetchDashboard() async {
    await Future<void>.delayed(latency);
    return MemberSeedData.dashboard(DateTime.now());
  }

  @override
  Future<void> saveMeasurement(BodyMeasurement measurement) async {
    // TODO(api): POST /members/me/measurements
    await Future<void>.delayed(latency);
  }

  @override
  Future<void> saveWorkout(WorkoutSummary summary) async {
    // TODO(api): POST /members/me/workouts
    await Future<void>.delayed(latency);
  }

  @override
  Future<void> setMealLogged(String mealId, {required bool logged}) async {
    // TODO(api): PATCH /members/me/meals/{mealId}
  }

  @override
  Future<void> setExerciseProgress(
    String exerciseId, {
    required int completedSets,
  }) async {
    // TODO(api): PATCH /members/me/workout/exercises/{exerciseId}
  }
}

/// Contract between the member UI and the GYMORA backend.
///
/// The screens never talk to HTTP directly. Implement this interface with your
/// real API client (Dio/http) and pass it to `MemberDashboardScreen(repository: ...)`.
/// Until the member endpoints exist, [MockMemberRepository] is used.
abstract interface class MemberRepository {
  Future<MemberDashboardData> fetchDashboard();

  Future<void> saveMeasurement(BodyMeasurement measurement);

  Future<void> saveWorkout(WorkoutSummary summary);

  Future<void> setMealLogged(String mealId, {required bool logged});

  Future<void> setExerciseProgress(
    String exerciseId, {
    required int completedSets,
  });
}



/// Demo content for the member dashboard. Replace with API data.
abstract final class MemberSeedData {
  static MemberDashboardData dashboard(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    return MemberDashboardData(
      profile: MemberProfile(
        fullName: 'Karan Bisht',
        email: 'member@gymora.com',
        phone: '+91 98765 43210',
        memberId: 'GYM-001',
        planName: 'Pro · Annual',
        memberSince: today.subtract(const Duration(days: 182)),
        validUntil: today.add(const Duration(days: 183)),
        trainerName: 'Arjun Mehta',
        heightCm: 172,
        primaryGoal: 'Build Strength',
        targetWeightKg: 56,
        weeklyWorkoutTarget: 5,
        dailyCalorieTarget: 2000,
        proteinTargetG: 120,
        carbsTargetG: 220,
        fatTargetG: 60,
      ),
      plan: const WorkoutPlan(
        title: 'Power Session',
        focus: 'Upper Body',
        difficulty: 'Intermediate',
        durationMinutes: 45,
        estimatedCalories: 320,
        exercises: _exercises,
      ),
      meals: _meals,
      measurements: [
        BodyMeasurement(
          date: today.subtract(const Duration(days: 21)),
          weightKg: 60,
          bodyFatPercent: 24,
          waistCm: 80,
        ),
        BodyMeasurement(
          date: today.subtract(const Duration(days: 14)),
          weightKg: 59.2,
          bodyFatPercent: 23.5,
          waistCm: 79.1,
        ),
        BodyMeasurement(
          date: today.subtract(const Duration(days: 7)),
          weightKg: 58.6,
          bodyFatPercent: 22.7,
          waistCm: 78.2,
        ),
        BodyMeasurement(
          date: today,
          weightKg: 58,
          bodyFatPercent: 22,
          waistCm: 77.5,
        ),
      ],
      achievements: _achievements,
      notifications: _notifications,
      activity: const DailyActivity(
        steps: 6842,
        stepGoal: 10000,
        waterMl: 2000,
        waterGoalMl: 2500,
        activeMinutes: 34,
      ),
      weeklyMinutes: const [45, 28, 60, 38, 52, 70, 0],
      streakDays: 18,
      totalWorkouts: 42,
      coachTip:
          'Slow down the lowering phase on every rep today — 3 seconds down builds more strength than adding weight.',
    );
  }

  static const List<Exercise> _exercises = [
    Exercise(
      id: 'ex-push-ups',
      name: 'Push Ups',
      muscle: MuscleGroup.chest,
      equipment: 'Bodyweight',
      sets: 3,
      reps: 15,
      restSeconds: 45,
      completedSets: 3,
      instructions:
          'Keep your body in a straight line, brace your core, lower with control, then press through your palms. Keep elbows slightly tucked.',
      tips: ['Elbows at ~45° from your body', 'Chest touches just above the floor'],
    ),
    Exercise(
      id: 'ex-db-rows',
      name: 'Dumbbell Rows',
      muscle: MuscleGroup.back,
      equipment: 'Dumbbell',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      weightKg: 12.5,
      completedSets: 3,
      instructions:
          'Keep your back neutral, pull the dumbbell toward your hip, squeeze your back at the top, then lower slowly without twisting.',
      tips: ['Drive the elbow, not the hand', 'Pause 1 second at the top'],
    ),
    Exercise(
      id: 'ex-shoulder-press',
      name: 'Shoulder Press',
      muscle: MuscleGroup.shoulders,
      equipment: 'Dumbbell',
      sets: 3,
      reps: 10,
      restSeconds: 60,
      weightKg: 10,
      instructions:
          'Brace your core, keep wrists stacked over elbows, press overhead smoothly and lower under control. Avoid overextending your lower back.',
      tips: ['Ribs down, glutes squeezed', 'Finish with biceps by your ears'],
    ),
    Exercise(
      id: 'ex-bicep-curls',
      name: 'Bicep Curls',
      muscle: MuscleGroup.arms,
      equipment: 'Dumbbell',
      sets: 3,
      reps: 12,
      restSeconds: 45,
      weightKg: 8,
      instructions:
          'Keep elbows close to your body, curl without swinging, squeeze at the top and lower the weight slowly for a controlled eccentric.',
      tips: ['No hip swing', '3 seconds on the way down'],
    ),
    Exercise(
      id: 'ex-tricep-pushdown',
      name: 'Tricep Pushdown',
      muscle: MuscleGroup.arms,
      equipment: 'Cable',
      sets: 3,
      reps: 12,
      restSeconds: 45,
      weightKg: 15,
      instructions:
          'Keep elbows fixed near your sides, push the handle down until arms are extended, squeeze the triceps, then return slowly.',
      tips: ['Elbows pinned to your sides', 'Full lockout every rep'],
    ),
    Exercise(
      id: 'ex-plank',
      name: 'Plank',
      muscle: MuscleGroup.core,
      equipment: 'Bodyweight',
      sets: 3,
      reps: 45,
      restSeconds: 30,
      unit: 'sec',
      instructions:
          'Keep shoulders stacked over elbows, squeeze your glutes and core, and maintain a straight line from shoulders to heels throughout the hold.',
      tips: ['Push the floor away', 'Breathe slowly through the hold'],
    ),
  ];

  static const List<Meal> _meals = [
    Meal(
      id: 'meal-breakfast',
      type: MealType.breakfast,
      name: 'Oats + Eggs',
      time: '8:00 AM',
      calories: 320,
      proteinG: 22,
      carbsG: 34,
      fatG: 10,
      items: ['Rolled oats 50 g', '2 boiled eggs', 'Banana'],
      logged: true,
    ),
    Meal(
      id: 'meal-lunch',
      type: MealType.lunch,
      name: 'Rice + Chicken',
      time: '1:30 PM',
      calories: 480,
      proteinG: 38,
      carbsG: 55,
      fatG: 11,
      items: ['Brown rice 150 g', 'Grilled chicken 120 g', 'Sautéed vegetables'],
    ),
    Meal(
      id: 'meal-snack',
      type: MealType.snack,
      name: 'Protein Shake',
      time: '5:00 PM',
      calories: 220,
      proteinG: 25,
      carbsG: 18,
      fatG: 5,
      items: ['Whey protein 1 scoop', 'Almond milk 250 ml'],
    ),
    Meal(
      id: 'meal-dinner',
      type: MealType.dinner,
      name: 'Salad + Paneer',
      time: '8:30 PM',
      calories: 230,
      proteinG: 18,
      carbsG: 12,
      fatG: 12,
      items: ['Paneer tikka 100 g', 'Greek salad'],
    ),
  ];

  static const List<Achievement> _achievements = [
    Achievement(
      id: 'ach-streak-7',
      kind: AchievementKind.streak,
      title: 'On Fire',
      description: 'Train 7 days in a row',
      current: 18,
      target: 7,
    ),
    Achievement(
      id: 'ach-hydration',
      kind: AchievementKind.hydration,
      title: 'Hydration Hero',
      description: 'Hit your water goal 10 times',
      current: 10,
      target: 10,
    ),
    Achievement(
      id: 'ach-tracker',
      kind: AchievementKind.tracking,
      title: 'Progress Tracker',
      description: 'Log 3 body measurements',
      current: 4,
      target: 3,
    ),
    Achievement(
      id: 'ach-workouts-50',
      kind: AchievementKind.workouts,
      title: '50 Workouts',
      description: 'Complete 50 workouts',
      current: 42,
      target: 50,
    ),
    Achievement(
      id: 'ach-streak-30',
      kind: AchievementKind.streak,
      title: 'Unstoppable',
      description: 'Train 30 days in a row',
      current: 18,
      target: 30,
    ),
    Achievement(
      id: 'ach-early-bird',
      kind: AchievementKind.earlyBird,
      title: 'Early Bird',
      description: 'Finish 10 workouts before 8 AM',
      current: 5,
      target: 10,
    ),
    Achievement(
      id: 'ach-macro',
      kind: AchievementKind.nutrition,
      title: 'Macro Master',
      description: 'Hit your protein target 14 days',
      current: 9,
      target: 14,
    ),
  ];

  static const List<MemberNotification> _notifications = [
    MemberNotification(
      id: 'n-1',
      kind: NotificationKind.workout,
      title: 'Workout reminder',
      message: 'Your Upper Body power session is ready.',
      timeAgo: 'Now',
    ),
    MemberNotification(
      id: 'n-2',
      kind: NotificationKind.streak,
      title: 'Streak update',
      message: 'You are on an 18 day streak. Keep going!',
      timeAgo: '2h',
    ),
    MemberNotification(
      id: 'n-3',
      kind: NotificationKind.nutrition,
      title: 'Nutrition reminder',
      message: 'Lunch is waiting in your meal plan.',
      timeAgo: '4h',
    ),
    MemberNotification(
      id: 'n-4',
      kind: NotificationKind.trainer,
      title: 'Message from your trainer',
      message: 'Great form on rows yesterday. Add 2.5 kg next week.',
      timeAgo: '1d',
      read: true,
    ),
  ];
}
