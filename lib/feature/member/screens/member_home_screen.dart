import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_workout_screen.dart';
import 'package:gymora_fitness_management/feature/member/sheets/member_sheets.dart';
import 'package:gymora_fitness_management/feature/member/state/member_state.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final profile = controller.profile;

    return MemberPage(
      children: [
        HomeHeader(
          fullName: profile.fullName,
          unreadCount: controller.unreadNotifications,
          onNotifications: () => showNotificationsSheet(context),
          onAvatar: () => controller.selectTab(MemberTabs.profile),
        ),
        TodayWorkoutCard(
          plan: controller.plan,
          progress: controller.workoutProgress,
          completedExercises: controller.completedExercises,
          sessionActive: controller.isSessionActive,
          onStart: () => openWorkoutSession(context),
          onViewPlan: () => controller.selectTab(MemberTabs.workout),
        ),
        WeekStreakCard(
          streakDays: controller.streakDays,
          weeklyMinutes: controller.weeklyMinutes,
          weeklyTarget: profile.weeklyWorkoutTarget,
        ),
        const DailyRingsCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Quick actions'),
            const SizedBox(height: 12),
            QuickActionsGrid(
              actions: [
                QuickAction(
                  icon: Icons.fitness_center_rounded,
                  title: 'Start workout',
                  subtitle:
                      '${controller.completedExercises}/${controller.totalExercises} done today',
                  color: GymColors.cyan,
                  onTap: () => openWorkoutSession(context),
                ),
                QuickAction(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Meal plan',
                  subtitle:
                      '${controller.loggedMealCount}/${controller.meals.length} meals logged',
                  color: GymColors.green,
                  onTap: () => controller.selectTab(MemberTabs.nutrition),
                ),
                QuickAction(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Measurements',
                  subtitle: 'Log weight & body fat',
                  color: GymColors.violet,
                  onTap: () => showAddMeasurementSheet(context),
                ),
                QuickAction(
                  icon: Icons.emoji_events_outlined,
                  title: 'Achievements',
                  subtitle: '${controller.unlockedAchievements} unlocked',
                  color: GymColors.amber,
                  onTap: () => showAchievementsSheet(context),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Your progress',
              subtitle: 'Last ${controller.measurements.length} check-ins',
              actionLabel: 'View all',
              onAction: () => controller.selectTab(MemberTabs.progress),
            ),
            const SizedBox(height: 12),
            ProgressSnapshotCard(
              onTap: () => controller.selectTab(MemberTabs.progress),
            ),
          ],
        ),
        CoachTipCard(
          trainerName: profile.trainerName,
          tip: controller.coachTip,
        ),
      ],
    );
  }
}

/// Daily tip from the member's assigned trainer.
class CoachTipCard extends StatelessWidget {
  const CoachTipCard({super.key, required this.trainerName, required this.tip});

  final String trainerName;
  final String tip;

  @override
  Widget build(BuildContext context) {
    return GymCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            GymColors.violet.withValues(alpha: .12),
            GymColors.surface,
          ),
          GymColors.surface,
        ],
      ),
      borderColor: GymColors.violet.withValues(alpha: .22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: GymColors.violetGradient,
            ),
            child: Text(
              GymFormat.initials(trainerName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Coach $trainerName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GymText.title,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: GymColors.violet,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'TIP OF THE DAY',
                  style: GymText.overline.copyWith(color: GymColors.violet),
                ),
                const SizedBox(height: 10),
                Text(
                  '“$tip”',
                  style: GymText.body.copyWith(
                    color: GymColors.text.withValues(alpha: .85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three concentric rings: calories eaten, steps, water.
class DailyRingsCard extends StatelessWidget {
  const DailyRingsCard({super.key});

  static const List<Color> _calorieColors = [GymColors.amber, GymColors.pink];
  static const List<Color> _stepColors = [GymColors.cyan, GymColors.blue];
  static const List<Color> _waterColors = [GymColors.violet, GymColors.blue];

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final activity = controller.activity;
    final profile = controller.profile;

    return GymCard(
      child: Column(
        children: [
          Row(
            children: [
              Text("Today's rings", style: GymText.h3),
              const Spacer(),
              Text(GymFormat.longDate(DateTime.now()), style: GymText.caption),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ActivityRings(
                size: 138,
                strokeWidth: 12,
                gap: 3,
                rings: [
                  RingData(
                    progress: controller.calorieProgress,
                    colors: _calorieColors,
                  ),
                  RingData(
                    progress: activity.stepProgress,
                    colors: _stepColors,
                  ),
                  RingData(
                    progress: activity.waterProgress,
                    colors: _waterColors,
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _RingLegend(
                      color: _calorieColors.last,
                      icon: Icons.local_fire_department_rounded,
                      label: 'Calories',
                      value: GymFormat.thousands(controller.consumedCalories),
                      goal:
                          '/ ${GymFormat.thousands(profile.dailyCalorieTarget)} kcal',
                    ),
                    const SizedBox(height: 14),
                    _RingLegend(
                      color: _stepColors.first,
                      icon: Icons.directions_walk_rounded,
                      label: 'Steps',
                      value: GymFormat.thousands(activity.steps),
                      goal: '/ ${GymFormat.thousands(activity.stepGoal)}',
                    ),
                    const SizedBox(height: 14),
                    _RingLegend(
                      color: _waterColors.first,
                      icon: Icons.water_drop_rounded,
                      label: 'Water',
                      value: GymFormat.water(activity.waterMl),
                      goal: '/ ${GymFormat.water(activity.waterGoalMl)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _QuickAdd(
                  icon: Icons.water_drop_outlined,
                  label: '+250 ml water',
                  color: GymColors.violet,
                  onTap: () => controller.addWater(250),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAdd(
                  icon: Icons.timer_outlined,
                  label: '${activity.activeMinutes} active min',
                  color: GymColors.green,
                  onTap: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingLegend extends StatelessWidget {
  const _RingLegend({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
              const SizedBox(height: 1),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: value, style: GymText.title),
                    TextSpan(
                      text: ' $goal',
                      style: GymText.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: .2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar, greeting and notification bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.fullName,
    required this.unreadCount,
    required this.onNotifications,
    required this.onAvatar,
  });

  final String fullName;
  final int unreadCount;
  final VoidCallback onNotifications;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final firstName = fullName.trim().split(' ').first;

    return Row(
      children: [
        GestureDetector(
          onTap: onAvatar,
          child: GradientAvatar(
            initials: GymFormat.initials(fullName),
            size: 52,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GymFormat.greeting(DateTime.now()).toUpperCase(),
                style: GymText.overline,
              ),
              const SizedBox(height: 4),
              Text(
                '$firstName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GymText.h1,
              ),
            ],
          ),
        ),
        GymIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: unreadCount,
          tooltip: 'Notifications',
          onPressed: onNotifications,
        ),
      ],
    );
  }
}

/// Weight + body-fat snapshot with a mini trend line.
class ProgressSnapshotCard extends StatelessWidget {
  const ProgressSnapshotCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final measurements = controller.measurements;
    final weightDelta = controller.weightChange;
    final fatDelta = controller.bodyFatChange;

    return GymCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Value(
                  label: 'WEIGHT',
                  value: GymFormat.decimal(controller.currentWeight),
                  unit: 'kg',
                  delta: weightDelta,
                  deltaUnit: 'kg',
                ),
              ),
              Container(width: 1, height: 44, color: GymColors.stroke),
              const SizedBox(width: 18),
              Expanded(
                child: _Value(
                  label: 'BODY FAT',
                  value: GymFormat.decimal(controller.currentBodyFat),
                  unit: '%',
                  delta: fatDelta,
                  deltaUnit: '%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SmoothLineChart(
            height: 96,
            values: [for (final m in measurements) m.weightKg],
            labels: [
              for (var i = 0; i < measurements.length; i++)
                i == measurements.length - 1
                    ? 'Today'
                    : GymFormat.shortDate(measurements[i].date),
            ],
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
    required this.deltaUnit,
  });

  final String label;
  final String value;
  final String unit;
  final double delta;
  final String deltaUnit;

  @override
  Widget build(BuildContext context) {
    // For weight loss / fat loss goals a negative change is good news.
    final improving = delta <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GymText.overline),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value),
            const SizedBox(width: 3),
            Text(
              unit,
              style: GymText.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GymPill(
          label: '${GymFormat.signed(delta)} $deltaUnit',
          icon: improving
              ? Icons.trending_down_rounded
              : Icons.trending_up_rounded,
          color: improving ? GymColors.green : GymColors.pink,
          dense: true,
        ),
      ],
    );
  }
}

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

/// 2 × 2 grid of shortcut tiles.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 128,
      ),
      itemBuilder: (context, index) => _QuickActionTile(action: actions[index]),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              action.color.withValues(alpha: .10),
              GymColors.surface,
            ),
            GymColors.surface,
          ],
        ),
        border: Border.all(color: action.color.withValues(alpha: .16)),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action.onTap,
          splashColor: action.color.withValues(alpha: .10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(icon: action.icon, color: action.color, size: 42),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: action.color.withValues(alpha: .7),
                      size: 18,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GymText.title,
                ),
                const SizedBox(height: 2),
                Text(
                  action.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GymText.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home hero: today's session with a progress ring and a single CTA.
class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({
    super.key,
    required this.plan,
    required this.progress,
    required this.completedExercises,
    required this.sessionActive,
    required this.onStart,
    required this.onViewPlan,
  });

  final WorkoutPlan plan;
  final double progress;
  final int completedExercises;
  final bool sessionActive;
  final VoidCallback onStart;
  final VoidCallback onViewPlan;

  @override
  Widget build(BuildContext context) {
    final done = progress >= 1;
    final started = progress > 0;
    final label = sessionActive
        ? 'Open live session'
        : done
        ? 'View summary'
        : started
        ? 'Continue workout'
        : 'Start workout';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: GymColors.cyan.withValues(alpha: .3)),
        boxShadow: [
          BoxShadow(
            color: GymColors.cyan.withValues(alpha: .12),
            blurRadius: 44,
            spreadRadius: -8,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -80,
            bottom: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GymColors.blue.withValues(alpha: .25),
                    GymColors.blue.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const GymPill(
                                label: "Today's workout",
                                icon: Icons.bolt_rounded,
                                dense: true,
                              ),
                              if (sessionActive) ...[
                                const SizedBox(width: 6),
                                const GymPill(
                                  label: 'LIVE',
                                  color: GymColors.lime,
                                  dense: true,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            plan.focus,
                            style: GymText.h1.copyWith(fontSize: 30),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.title,
                            style: GymText.body.copyWith(
                              color: GymColors.cyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProgressRing(
                      progress: progress,
                      size: 92,
                      strokeWidth: 9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(progress * 100).round()}%'),
                          Text(
                            '$completedExercises/${plan.exercises.length}',
                            style: GymText.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Build strength.\nPush your limits.',
                  style: TextStyle(
                    color: GymColors.text,
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GymPill.neutral(
                      label: '${plan.durationMinutes} min',
                      icon: Icons.timer_outlined,
                    ),
                    GymPill.neutral(
                      label: '${plan.estimatedCalories} kcal',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    GymPill.neutral(
                      label: plan.difficulty,
                      icon: Icons.speed_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GymButton(
                        label: label,
                        icon: done
                            ? Icons.emoji_events_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: onStart,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GymIconButton(
                      icon: Icons.list_alt_rounded,
                      size: 56,
                      tooltip: 'View plan',
                      onPressed: onViewPlan,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak flame + last-7-days check-ins + weekly goal.
class WeekStreakCard extends StatelessWidget {
  const WeekStreakCard({
    super.key,
    required this.streakDays,
    required this.weeklyMinutes,
    required this.weeklyTarget,
  });

  final int streakDays;

  /// Oldest → today, length 7.
  final List<int> weeklyMinutes;
  final int weeklyTarget;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final workouts = weeklyMinutes.where((m) => m > 0).length;

    return GymCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: GymColors.fireGradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: GymColors.orange.withValues(alpha: .35),
                      blurRadius: 18,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streakDays-day streak', style: GymText.h3),
                    const SizedBox(height: 2),
                    Text(
                      streakDays >= 7
                          ? "You're on fire. Don't break the chain!"
                          : 'Keep showing up every day.',
                      style: GymText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < weeklyMinutes.length; i++)
                _DayDot(
                  letter: GymFormat.weekdayLetter(
                    today.subtract(
                      Duration(days: weeklyMinutes.length - 1 - i),
                    ),
                  ),
                  done: weeklyMinutes[i] > 0,
                  isToday: i == weeklyMinutes.length - 1,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('Weekly goal', style: GymText.caption),
              const Spacer(),
              Text(
                '$workouts / $weeklyTarget workouts',
                style: GymText.caption.copyWith(
                  color: GymColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearMeter(
            progress: weeklyTarget == 0 ? 0 : workouts / weeklyTarget,
            colors: const [GymColors.amber, GymColors.orange],
            height: 7,
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.letter,
    required this.done,
    required this.isToday,
  });

  final String letter;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          letter,
          style: TextStyle(
            color: isToday ? GymColors.text : GymColors.muted,
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: done ? GymColors.fireGradient : null,
            color: done ? null : GymColors.surfaceHigh,
            border: isToday && !done
                ? Border.all(color: GymColors.orange, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Icon(
            done
                ? Icons.check_rounded
                : (isToday ? Icons.bolt_rounded : Icons.remove_rounded),
            size: 18,
            color: done
                ? Colors.white
                : (isToday ? GymColors.orange : Colors.amber),
          ),
        ),
      ],
    );
  }
}
