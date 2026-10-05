import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/api/network/member_service.dart';

enum SessionStatus { idle, running, paused }

abstract final class MemberTabs {
  static const int home = 0;
  static const int workout = 1;
  static const int progress = 2;
  static const int nutrition = 3;
  static const int profile = 4;
}

/// Single source of truth for the member experience.
///
/// Screens read state through `MemberScope.of(context)` and call methods on
/// this controller; they never mutate models directly. Fast-ticking values
/// (session clock, rest countdown) live in [ValueNotifier]s so only the small
/// widgets that show them rebuild every second.
class MemberController extends ChangeNotifier {
  MemberController({MemberService? service})
    : _service = service ?? const MemberService();

  final MemberService _service;

  MemberDashboardData? _data;
  bool _loading = false;
  bool _refreshing = false;
  bool _disposed = false;
  String? _error;
  int _selectedTab = 0;

  bool _notificationsEnabled = true;
  bool _autoRestTimer = true;

  // Session ------------------------------------------------------------------
  final ValueNotifier<int> sessionSeconds = ValueNotifier<int>(0);
  final ValueNotifier<int> restSecondsLeft = ValueNotifier<int>(0);
  SessionStatus _sessionStatus = SessionStatus.idle;
  int _restTotalSeconds = 0;
  bool _workoutStartedOnServer = false;
  Future<void>? _startRequest;
  Timer? _sessionTimer;
  Timer? _restTimer;

  // ---------------------------------------------------------------------------
  // Read-only state
  // ---------------------------------------------------------------------------

  bool get isLoading => _loading;
  bool get isRefreshing => _refreshing;
  bool get hasData => _data != null;
  String? get error => _error;
  int get selectedTab => _selectedTab;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoRestTimer => _autoRestTimer;

  MemberDashboardData get data {
    final value = _data;
    if (value == null) {
      throw StateError('MemberController.data read before load() completed.');
    }
    return value;
  }

  MemberProfile get profile => data.profile;
  WorkoutPlan get plan => data.plan;
  List<Exercise> get exercises => data.plan.exercises;
  List<Meal> get meals => data.meals;
  List<BodyMeasurement> get measurements => data.measurements;
  List<Achievement> get achievements => data.achievements;
  List<MemberNotification> get notifications => data.notifications;
  DailyActivity get activity => data.activity;
  List<int> get weeklyMinutes => data.weeklyMinutes;
  int get streakDays => data.streakDays;
  int get totalWorkouts => data.totalWorkouts;
  String get coachTip => data.coachTip;

  // Workout -------------------------------------------------------------------
  SessionStatus get sessionStatus => _sessionStatus;
  bool get isSessionActive => _sessionStatus != SessionStatus.idle;
  bool get isSessionRunning => _sessionStatus == SessionStatus.running;
  int get restTotalSeconds => _restTotalSeconds;

  int get totalExercises => exercises.length;
  int get completedExercises => exercises.where((e) => e.isCompleted).length;
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
  int get completedSets => exercises.fold(0, (sum, e) => sum + e.completedSets);
  bool get isWorkoutComplete =>
      exercises.isNotEmpty && completedExercises == totalExercises;

  double get workoutProgress => totalSets == 0 ? 0 : completedSets / totalSets;

  /// First exercise that still has sets left, or null when everything is done.
  Exercise? get currentExercise {
    for (final exercise in exercises) {
      if (!exercise.isCompleted) return exercise;
    }
    return null;
  }

  int get estimatedBurnedCalories =>
      (plan.estimatedCalories * workoutProgress).round();

  // Nutrition -----------------------------------------------------------------
  Iterable<Meal> get _loggedMeals => meals.where((m) => m.logged);
  int get loggedMealCount => _loggedMeals.length;
  int get consumedCalories =>
      _loggedMeals.fold(0, (sum, m) => sum + m.calories);
  int get consumedProtein => _loggedMeals.fold(0, (sum, m) => sum + m.proteinG);
  int get consumedCarbs => _loggedMeals.fold(0, (sum, m) => sum + m.carbsG);
  int get consumedFat => _loggedMeals.fold(0, (sum, m) => sum + m.fatG);
  int get remainingCalories {
    final left = profile.dailyCalorieTarget - consumedCalories;
    return left < 0 ? 0 : left;
  }

  double get calorieProgress => profile.dailyCalorieTarget == 0
      ? 0
      : (consumedCalories / profile.dailyCalorieTarget).clamp(0.0, 1.0);

  // Body ----------------------------------------------------------------------
  bool get hasMeasurements => measurements.isNotEmpty;

  // These never throw: a member with no check-ins yet gets a zeroed
  // placeholder instead of a StateError.
  BodyMeasurement get latestMeasurement =>
      hasMeasurements ? measurements.last : _emptyMeasurement();
  BodyMeasurement get firstMeasurement =>
      hasMeasurements ? measurements.first : _emptyMeasurement();

  static BodyMeasurement _emptyMeasurement() =>
      BodyMeasurement(date: DateTime.now(), weightKg: 0, bodyFatPercent: 0);

  double get currentWeight => latestMeasurement.weightKg;
  double get currentBodyFat => latestMeasurement.bodyFatPercent;
  double get weightChange =>
      measurements.length < 2 ? 0 : currentWeight - firstMeasurement.weightKg;
  double get bodyFatChange => measurements.length < 2
      ? 0
      : currentBodyFat - firstMeasurement.bodyFatPercent;

  double get bmi {
    final metres = profile.heightCm / 100;
    return metres <= 0 ? 0 : currentWeight / (metres * metres);
  }

  /// True when the member has a target weight and at least one check-in.
  bool get hasGoal => profile.targetWeightKg > 0 && hasMeasurements;

  /// How far the member is from their first measurement to the target weight.
  double get weightGoalProgress {
    if (!hasGoal) return 0;
    final start = firstMeasurement.weightKg;
    final target = profile.targetWeightKg;
    final total = start - target;
    if (total.abs() < .01) return 1;
    return ((start - currentWeight) / total).clamp(0.0, 1.0);
  }

  // Misc ----------------------------------------------------------------------
  int get unreadNotifications => notifications.where((n) => !n.read).length;
  int get unlockedAchievements => achievements.where((a) => a.unlocked).length;

  /// Workouts in the last 7 days (days with any active minutes).
  int get workoutsThisWeek => weeklyMinutes.where((m) => m > 0).length;
  int get minutesThisWeek => weeklyMinutes.fold(0, (sum, m) => sum + m);

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      _data = await _service.getDashboard();
    } catch (error, stack) {
      debugPrint('MemberController.load failed: $error\n$stack');
      _error =
          'We could not load your dashboard. Check your connection and try again.';
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Replaces local view state with the latest server-owned member data.
  /// Sets logged during an active session are kept (the server only knows
  /// about fully completed exercises).
  Future<void> refresh() async {
    if (_refreshing) return;
    if (_data == null) return load();

    _refreshing = true;
    _notify();
    try {
      final fresh = await _service.getDashboard();
      _data = _mergeLocalProgress(fresh);
    } catch (error) {
      debugPrint('MemberController.refresh failed: $error');
    } finally {
      _refreshing = false;
      _notify();
    }
  }

  MemberDashboardData _mergeLocalProgress(MemberDashboardData fresh) {
    if (!isSessionActive || fresh.plan.id != plan.id) return fresh;
    final local = {for (final e in exercises) e.id: e.completedSets};
    return fresh.copyWith(
      plan: fresh.plan.copyWith(
        exercises: [
          for (final e in fresh.plan.exercises)
            e.copyWith(
              completedSets: math.max(e.completedSets, local[e.id] ?? 0),
            ),
        ],
      ),
    );
  }

  void selectTab(int index) {
    if (index == _selectedTab) return;
    _selectedTab = index;
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Workout session
  // ---------------------------------------------------------------------------

  void startSession() {
    if (_sessionStatus == SessionStatus.running) return;
    if (!_workoutStartedOnServer && plan.id.isNotEmpty) {
      final start = _service.startWorkout(plan.id);
      _startRequest = start;
      _persist(start);
      _workoutStartedOnServer = true;
    }
    _sessionStatus = SessionStatus.running;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      sessionSeconds.value = sessionSeconds.value + 1;
    });
    if (restSecondsLeft.value > 0) _runRestTimer();
    _notify();
  }

  void pauseSession() {
    if (_sessionStatus != SessionStatus.running) return;
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    _sessionStatus = SessionStatus.paused;
    _notify();
  }

  void toggleSession() {
    if (isSessionRunning) {
      pauseSession();
    } else {
      startSession();
    }
  }

  WorkoutSummary finishSession() {
    final seconds = sessionSeconds.value;
    final summary = WorkoutSummary(
      durationSeconds: seconds,
      exercisesCompleted: completedExercises,
      totalExercises: totalExercises,
      setsCompleted: completedSets,
      totalSets: totalSets,
      estimatedCalories: estimatedBurnedCalories,
      finishedAt: DateTime.now(),
    );

    _sessionTimer?.cancel();
    _restTimer?.cancel();
    restSecondsLeft.value = 0;
    _restTotalSeconds = 0;
    sessionSeconds.value = 0;
    _sessionStatus = SessionStatus.idle;

    _workoutStartedOnServer = false;
    _startRequest = null;
    if (seconds > 0 && isWorkoutComplete) unawaited(refresh());

    _notify();
    return summary;
  }

  /// Logs one completed set. While a session is running this also starts the
  /// rest countdown (if enabled and there is still work left).
  void logSet(String exerciseId) {
    final exercise = _findExercise(exerciseId);
    if (exercise == null || exercise.isCompleted) return;

    final updated = exercise.copyWith(
      completedSets: exercise.completedSets + 1,
    );
    _replaceExercise(updated);

    if (_autoRestTimer && isSessionRunning && !isWorkoutComplete) {
      startRest(updated.restSeconds);
    }
  }

  void undoSet(String exerciseId) {
    final exercise = _findExercise(exerciseId);
    if (exercise == null ||
        exercise.completedSets == 0 ||
        exercise.isCompleted) {
      return;
    }
    _replaceExercise(
      exercise.copyWith(completedSets: exercise.completedSets - 1),
    );
  }

  /// Marks every set done, or resets the exercise if it was already complete.
  void toggleExerciseComplete(String exerciseId) {
    final exercise = _findExercise(exerciseId);
    if (exercise == null || exercise.isCompleted) return;
    _replaceExercise(exercise.copyWith(completedSets: exercise.sets));
  }

  void startRest(int seconds) {
    if (seconds <= 0) return;
    _restTotalSeconds = seconds;
    restSecondsLeft.value = seconds;
    _runRestTimer();
    _notify();
  }

  void addRestTime(int seconds) {
    if (restSecondsLeft.value <= 0) return;
    restSecondsLeft.value = restSecondsLeft.value + seconds;
    _restTotalSeconds += seconds;
    _notify();
  }

  void skipRest() {
    _restTimer?.cancel();
    restSecondsLeft.value = 0;
    _restTotalSeconds = 0;
    _notify();
  }

  void _runRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restSecondsLeft.value <= 1) {
        timer.cancel();
        restSecondsLeft.value = 0;
        _restTotalSeconds = 0;
        _notify();
      } else {
        restSecondsLeft.value = restSecondsLeft.value - 1;
      }
    });
  }

  Exercise? _findExercise(String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  void _replaceExercise(Exercise updated) {
    final previous = _findExercise(updated.id);
    final list = [
      for (final exercise in exercises)
        exercise.id == updated.id ? updated : exercise,
    ];
    _data = data.copyWith(plan: plan.copyWith(exercises: list));
    _notify();
    if (previous != null &&
        !previous.isCompleted &&
        updated.isCompleted &&
        plan.id.isNotEmpty) {
      final workoutId = plan.id;
      final startRequest = _startRequest;
      _persist(() async {
        // Make sure the server has seen "start" before "complete".
        if (startRequest != null) {
          try {
            await startRequest;
          } catch (_) {
            // Already reported by the start request's own handler.
          }
        }
        await _service.completeExercise(
          workoutId: workoutId,
          exerciseId: updated.id,
        );
      }());
    }
  }

  // ---------------------------------------------------------------------------
  // Nutrition & activity
  // ---------------------------------------------------------------------------

  Future<void> logMeal({
    required MealType type,
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final saved = await _service.logMeal(
      type: type,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
    _data = data.copyWith(meals: [...meals, saved]);
    _notify();
  }

  void addWater(int millilitres) {
    if (millilitres == 0) return;
    final max = activity.waterGoalMl > 0 ? activity.waterGoalMl * 2 : 10000;
    final next = (activity.waterMl + millilitres).clamp(0, max);
    _data = data.copyWith(activity: activity.copyWith(waterMl: next));
    _notify();
    _persist(_service.addHydration(millilitres.abs(), add: millilitres > 0));
  }

  // ---------------------------------------------------------------------------
  // Body measurements
  // ---------------------------------------------------------------------------

  Future<void> addMeasurement(BodyMeasurement measurement) async {
    final saved = await _service.saveMeasurement(measurement);
    final list = [...measurements, saved]
      ..sort((a, b) => a.date.compareTo(b.date));
    _data = data.copyWith(measurements: list);
    _notify();
  }

  void _persist(Future<void> request) {
    unawaited(
      request.catchError((Object error) {
        debugPrint('Member API action failed: $error');
        _error = 'Could not save that change. Refresh and try again.';
        _notify();
        unawaited(refresh());
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Preferences & notifications
  // ---------------------------------------------------------------------------

  Future<void> markAllNotificationsRead() async {
    if (unreadNotifications == 0) return;
    final unread = notifications
        .where((notification) => !notification.read)
        .toList();
    _data = data.copyWith(
      notifications: [for (final n in notifications) n.copyWith(read: true)],
    );
    _notify();
    for (final notification in unread) {
      try {
        await _service.markNotificationRead(notification.id);
      } catch (error) {
        debugPrint('Could not mark notification read: $error');
      }
    }
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _notify();
  }

  void setAutoRestTimer(bool value) {
    _autoRestTimer = value;
    if (!value) skipRest();
    _notify();
  }

  // ---------------------------------------------------------------------------

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    sessionSeconds.dispose();
    restSecondsLeft.dispose();
    super.dispose();
  }
}

/// Makes the [MemberController] available to every member widget without an
/// external state-management package.
///
/// * `MemberScope.of(context)` — read and rebuild when the controller changes.
/// * `MemberScope.read(context)` — read once (use inside callbacks).
///
/// Routes and bottom sheets are built outside this scope, so they must be
/// wrapped again — use `showGymSheet` / `MemberScope.wrap` which do that.
class MemberScope extends InheritedNotifier<MemberController> {
  const MemberScope({
    super.key,
    required MemberController controller,
    required super.child,
  }) : super(notifier: controller);

  static MemberController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MemberScope>();
    assert(scope != null, 'MemberScope.of() called outside a MemberScope.');
    return scope!.notifier!;
  }

  static MemberController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<MemberScope>();
    assert(scope != null, 'MemberScope.read() called outside a MemberScope.');
    return scope!.notifier!;
  }

  /// Re-provides the current controller to a widget that will be shown in a
  /// new route (dialog, sheet, page).
  static Widget wrap(BuildContext context, Widget child) {
    return MemberScope(controller: read(context), child: child);
  }
}
