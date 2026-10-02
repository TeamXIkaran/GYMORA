import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/sheets/member_sheets.dart';
import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

/// Workout tab: today's plan, live stats and the exercise list.
class MemberWorkoutScreen extends StatefulWidget {
  const MemberWorkoutScreen({super.key});

  @override
  State<MemberWorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<MemberWorkoutScreen> {
  MuscleGroup? _filter;
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final plan = controller.plan;
    final all = controller.exercises;
    final visible = _filter == null
        ? all
        : all.where((e) => e.muscle == _filter).toList();

    return MemberPage(
      children: [
        PageHeader(
          eyebrow: controller.isSessionActive ? 'Session live' : 'Training',
          title: 'Your Workout',
          subtitle: 'Build strength. Stay consistent.',
          accent: controller.isSessionActive ? GymColors.lime : GymColors.cyan,
          actions: [
            if (controller.isSessionActive)
              GestureDetector(
                onTap: () => openWorkoutSession(context),
                child: const SessionTimerPill(),
              ),
          ],
        ),
        WorkoutHeroCard(
          plan: plan,
          progress: controller.workoutProgress,
          completedSets: controller.completedSets,
          totalSets: controller.totalSets,
          sessionActive: controller.isSessionActive,
          onStart: () => openWorkoutSession(context),
        ),
        const SessionStatsCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: "Today's plan",
              subtitle: 'Tap an exercise for details and to log sets',
              trailing: Text(
                '${all.length} exercises',
                style: const TextStyle(
                  color: GymColors.cyan,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            MuscleFilterBar(
              muscles: plan.muscles,
              selected: _filter,
              onChanged: (muscle) => setState(() => _filter = muscle),
              countFor: (muscle) => muscle == null
                  ? all.length
                  : all.where((e) => e.muscle == muscle).length,
            ),
            const SizedBox(height: 14),
            if (visible.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No exercises in this group',
              )
            else
              for (final exercise in visible) ...[
                ExerciseCard(
                  key: ValueKey(exercise.id),
                  exercise: exercise,
                  number: all.indexOf(exercise) + 1,
                  expanded: _expandedId == exercise.id,
                  onToggleExpanded: () => setState(() {
                    _expandedId = _expandedId == exercise.id
                        ? null
                        : exercise.id;
                  }),
                  onLogSet: () => controller.logSet(exercise.id),
                  onUndoSet: () => controller.undoSet(exercise.id),
                  onToggleComplete: () =>
                      controller.toggleExerciseComplete(exercise.id),
                  onGuide: () => showExerciseGuideSheet(context, exercise),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
        GymButton(
          label: controller.isSessionActive
              ? 'Back to live session'
              : 'Start guided session',
          icon: controller.isSessionActive
              ? Icons.open_in_full_rounded
              : Icons.play_arrow_rounded,
          variant: GymButtonVariant.outline,
          onPressed: () => openWorkoutSession(context),
        ),
      ],
    );
  }
}

/// Starts (or resumes) the session and opens the full-screen live view.
/// When the member finishes, the summary sheet is shown on the caller.
Future<void> openWorkoutSession(BuildContext context) async {
  final controller = MemberScope.read(context);
  if (!controller.isWorkoutComplete) controller.startSession();

  final summary = await Navigator.of(context).push<WorkoutSummary>(
    PageRouteBuilder<WorkoutSummary>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (routeContext, animation, secondaryAnimation) => MemberScope(
        controller: controller,
        child: const WorkoutSessionScreen(),
      ),
      transitionsBuilder: (routeContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );

  if (summary != null && context.mounted) {
    await showWorkoutSummarySheet(context, summary);
  }
}

/// Full-screen live workout: current exercise, rest timer, plan overview.
class WorkoutSessionScreen extends StatelessWidget {
  const WorkoutSessionScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    final controller = MemberScope.read(context);
    final setsLeft = controller.totalSets - controller.completedSets;

    if (setsLeft > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .7),
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GymColors.surfaceHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('Finish workout?', style: GymText.h2),
          content: Text(
            'You still have $setsLeft ${setsLeft == 1 ? 'set' : 'sets'} left. '
            'Your progress so far will be saved.',
            style: GymText.body,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: GymColors.textSecondary,
              ),
              child: const Text('Keep going'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: GymColors.cyan,
                foregroundColor: GymColors.background,
              ),
              child: const Text(
                'Finish',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (!context.mounted) return;
    final summary = controller.finishSession();
    Navigator.of(context).pop(summary);
  }

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final exercises = controller.exercises;
    final current = controller.currentExercise;
    final currentIndex = current == null ? -1 : exercises.indexOf(current);

    return Scaffold(
      backgroundColor: GymColors.background,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: controller.plan.title,
                  focus: controller.plan.focus,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    children: [
                      LinearMeter(
                        progress: controller.workoutProgress,
                        height: 6,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${controller.completedSets} of ${controller.totalSets} sets',
                            style: GymText.caption,
                          ),
                          const Spacer(),
                          Text(
                            '~${controller.estimatedBurnedCalories} kcal burned',
                            style: GymText.caption.copyWith(
                              color: GymColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 380),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(.08, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: current == null
                            ? _AllDoneCard(
                                key: const ValueKey('done'),
                                onFinish: () => _finish(context),
                              )
                            : CurrentExerciseCard(
                                key: ValueKey(current.id),
                                exercise: current,
                                position: currentIndex + 1,
                                total: exercises.length,
                              ),
                      ),
                      const SizedBox(height: 26),
                      SectionHeader(
                        title: 'Session plan',
                        subtitle:
                            '${controller.completedExercises} of ${exercises.length} exercises done',
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < exercises.length; i++) ...[
                        _PlanRow(
                          exercise: exercises[i],
                          number: i + 1,
                          isCurrent: i == currentIndex,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                _BottomBar(onFinish: () => _finish(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.focus});

  final String title;
  final String focus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
      child: Row(
        children: [
          GymIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            tooltip: 'Minimise — the session keeps running',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focus.toUpperCase(),
                  style: GymText.overline.copyWith(color: GymColors.cyan),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GymText.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SessionTimerPill(),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final running = controller.isSessionRunning;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: GymColors.background.withValues(alpha: .92),
        border: const Border(top: BorderSide(color: GymColors.stroke)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GymButton(
              label: running ? 'Pause' : 'Resume',
              icon: running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              variant: GymButtonVariant.secondary,
              onPressed: controller.isWorkoutComplete
                  ? null
                  : controller.toggleSession,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GymButton(
              label: 'Finish',
              icon: Icons.flag_rounded,
              onPressed: onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.exercise,
    required this.number,
    required this.isCurrent,
  });

  final Exercise exercise;
  final int number;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final visual = exercise.muscle.visual;
    final done = exercise.isCompleted;
    final accent = done ? GymColors.green : visual.color;

    return Material(
      color: isCurrent
          ? visual.color.withValues(alpha: .07)
          : GymColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCurrent
              ? visual.color.withValues(alpha: .35)
              : GymColors.stroke,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showExerciseGuideSheet(context, exercise),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? GymColors.green : accent.withValues(alpha: .12),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: GymColors.background,
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: GymText.title.copyWith(
                        color: done ? GymColors.muted : GymColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(exercise.targetLabel, style: GymText.caption),
                  ],
                ),
              ),
              if (isCurrent)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: IconBadge(icon: Icons.play_arrow_rounded, size: 28),
                ),
              SetProgressDots(
                total: exercise.sets,
                done: exercise.completedSets,
                color: accent,
                segmentWidth: 10,
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              GymColors.green.withValues(alpha: .14),
              GymColors.surface,
            ),
            GymColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: GymColors.green.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [GymColors.lime, GymColors.green],
              ),
              boxShadow: [
                BoxShadow(
                  color: GymColors.green.withValues(alpha: .4),
                  blurRadius: 30,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 42,
              color: GymColors.background,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Every set done!',
            style: GymText.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Finish the session to save your time and calories.',
            style: GymText.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GymButton(
            label: 'Finish & save',
            icon: Icons.flag_rounded,
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }
}

/// The big "what do I do right now" card on the live session screen.
class CurrentExerciseCard extends StatelessWidget {
  const CurrentExerciseCard({
    super.key,
    required this.exercise,
    required this.position,
    required this.total,
  });

  final Exercise exercise;

  /// 1-based index of this exercise in the plan.
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final visual = exercise.muscle.visual;
    final nextSet = exercise.completedSets + 1;
    final weight = exercise.weightLabel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              visual.color.withValues(alpha: .14),
              GymColors.surface,
            ),
            GymColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: visual.color.withValues(alpha: .28)),
        boxShadow: [
          BoxShadow(
            color: visual.color.withValues(alpha: .12),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'EXERCISE $position OF $total',
                style: GymText.overline.copyWith(color: visual.color),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Exercise guide',
                onPressed: () => showExerciseGuideSheet(context, exercise),
                icon: const Icon(Icons.info_outline_rounded),
                color: GymColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(exercise.name, style: GymText.h1),
          const SizedBox(height: 4),
          Text(
            exercise.subtitle,
            style: GymText.body.copyWith(color: GymColors.muted),
          ),
          const SizedBox(height: 22),
          Center(
            child: ProgressRing(
              progress: exercise.progress,
              size: 184,
              strokeWidth: 14,
              colors: [visual.color, GymColors.blue],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SET', style: GymText.overline),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$nextSet'),
                      Text(
                        ' / ${exercise.sets}',
                        style: GymText.h3.copyWith(color: GymColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SetProgressDots(
                    total: exercise.sets,
                    done: exercise.completedSets,
                    color: visual.color,
                    segmentWidth: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GymPill(
                label: exercise.isTimed
                    ? '${exercise.reps} sec hold'
                    : '${exercise.reps} reps',
                icon: Icons.bolt_rounded,
                color: visual.color,
              ),
              if (weight != null)
                GymPill.neutral(
                  label: weight,
                  icon: Icons.fitness_center_rounded,
                ),
              GymPill.neutral(
                label: '${exercise.restSeconds}s rest',
                icon: Icons.hourglass_bottom_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          ValueListenableBuilder<int>(
            valueListenable: controller.restSecondsLeft,
            builder: (context, restLeft, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                child: restLeft > 0
                    ? RestTimerPanel(
                        key: const ValueKey('rest'),
                        nextLabel: 'Next: set $nextSet of ${exercise.sets}',
                      )
                    : _LogActions(
                        key: const ValueKey('log'),
                        exercise: exercise,
                        nextSet: nextSet,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LogActions extends StatelessWidget {
  const _LogActions({super.key, required this.exercise, required this.nextSet});

  final Exercise exercise;
  final int nextSet;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.read(context);

    return Row(
      children: [
        if (exercise.completedSets > 0) ...[
          GymIconButton(
            icon: Icons.undo_rounded,
            size: 56,
            tooltip: 'Undo last set',
            onPressed: () => controller.undoSet(exercise.id),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: GymButton(
            label: exercise.isTimed
                ? 'Hold done · set $nextSet'
                : 'Log set $nextSet',
            icon: Icons.check_rounded,
            onPressed: () => controller.logSet(exercise.id),
          ),
        ),
      ],
    );
  }
}

/// Expandable exercise row on the Workout tab.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.number,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onLogSet,
    required this.onUndoSet,
    required this.onToggleComplete,
    required this.onGuide,
  });

  final Exercise exercise;
  final int number;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onLogSet;
  final VoidCallback onUndoSet;
  final VoidCallback onToggleComplete;
  final VoidCallback onGuide;

  @override
  Widget build(BuildContext context) {
    final visual = exercise.muscle.visual;
    final done = exercise.isCompleted;
    final accent = done ? GymColors.green : visual.color;
    final weight = exercise.weightLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: done
            ? Color.alphaBlend(
                GymColors.green.withValues(alpha: .05),
                GymColors.surface,
              )
            : GymColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: expanded
              ? accent.withValues(alpha: .4)
              : done
              ? GymColors.green.withValues(alpha: .22)
              : GymColors.stroke,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: onToggleExpanded,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    _NumberBadge(
                      number: number,
                      done: done,
                      color: visual.color,
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
                                  exercise.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GymText.title.copyWith(
                                    fontSize: 16,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: GymColors.muted,
                                  ),
                                ),
                              ),
                              if (done) ...[
                                const SizedBox(width: 8),
                                const GymPill(
                                  label: 'Done',
                                  color: GymColors.green,
                                  dense: true,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(exercise.subtitle, style: GymText.caption),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SetProgressDots(
                                total: exercise.sets,
                                done: exercise.completedSets,
                                color: accent,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  '${exercise.targetLabel}${weight == null ? '' : ' · $weight'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GymText.caption.copyWith(
                                    color: GymColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? .5 : 0,
                      duration: const Duration(milliseconds: 240),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: GymColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _details(accent)
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _details(Color accent) {
    final weight = exercise.weightLabel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: GymColors.stroke),
          const SizedBox(height: 14),
          Row(
            children: [
              _DetailBox(
                icon: Icons.layers_outlined,
                value: '${exercise.sets}',
                label: 'Sets',
                color: accent,
              ),
              const SizedBox(width: 8),
              _DetailBox(
                icon: Icons.speed_rounded,
                value: '${exercise.reps}',
                label: exercise.isTimed ? 'Seconds' : 'Reps',
                color: accent,
              ),
              const SizedBox(width: 8),
              _DetailBox(
                icon: Icons.timer_outlined,
                value: '${exercise.restSeconds}s',
                label: 'Rest',
                color: accent,
              ),
              if (weight != null) ...[
                const SizedBox(width: 8),
                _DetailBox(
                  icon: Icons.fitness_center_rounded,
                  value: weight,
                  label: 'Load',
                  color: accent,
                ),
              ],
            ],
          ),
          if (exercise.instructions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              exercise.instructions,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GymText.body.copyWith(fontSize: 13.5),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              GymIconButton(
                icon: Icons.menu_book_rounded,
                onPressed: onGuide,
                size: 50,
                tooltip: 'Guide',
              ),
              const SizedBox(width: 8),
              if (exercise.completedSets > 0 && !exercise.isCompleted) ...[
                GymIconButton(
                  icon: Icons.undo_rounded,
                  onPressed: onUndoSet,
                  size: 50,
                  tooltip: 'Undo set',
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: exercise.isCompleted
                    ? GymButton(
                        label: 'Reset',
                        icon: Icons.restart_alt_rounded,
                        variant: GymButtonVariant.secondary,
                        height: 50,
                        onPressed: onToggleComplete,
                      )
                    : GymButton(
                        label: 'Log set ${exercise.completedSets + 1}',
                        icon: Icons.check_rounded,
                        height: 50,
                        onPressed: onLogSet,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({
    required this.number,
    required this.done,
    required this.color,
  });

  final int number;
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 50,
      height: 56,
      decoration: BoxDecoration(
        gradient: done
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GymColors.green, Color(0xFF14B87A)],
              )
            : null,
        color: done ? null : color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(17),
        border: done ? null : Border.all(color: color.withValues(alpha: .22)),
      ),
      child: done
          ? const Icon(
              Icons.check_rounded,
              color: GymColors.background,
              size: 26,
            )
          : Center(child: Text(number.toString().padLeft(2, '0'))),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: GymColors.background.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(height: 6),
            FittedBox(child: Text(value, style: GymText.title)),
            const SizedBox(height: 2),
            Text(label, style: GymText.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// Horizontal filter chips: "All" followed by each muscle group in the plan.
class MuscleFilterBar extends StatelessWidget {
  const MuscleFilterBar({
    super.key,
    required this.muscles,
    required this.selected,
    required this.onChanged,
    required this.countFor,
  });

  final List<MuscleGroup> muscles;

  /// null means "All".
  final MuscleGroup? selected;
  final ValueChanged<MuscleGroup?> onChanged;

  /// Number of exercises for a muscle (null → total).
  final int Function(MuscleGroup? muscle) countFor;

  @override
  Widget build(BuildContext context) {
    final options = <MuscleGroup?>[null, ...muscles];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final muscle = options[index];
          final isSelected = muscle == selected;
          final color = muscle?.visual.color ?? GymColors.cyan;

          return GestureDetector(
            onTap: () => onChanged(muscle),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? color : GymColors.surface,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: isSelected ? color : GymColors.stroke,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: .3),
                          blurRadius: 16,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    muscle?.label ?? 'All',
                    style: TextStyle(
                      color: isSelected
                          ? GymColors.background
                          : GymColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GymColors.background.withValues(alpha: .2)
                          : Colors.white.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${countFor(muscle)}',
                      style: TextStyle(
                        color: isSelected
                            ? GymColors.background
                            : GymColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Countdown shown between sets. Listens to the controller's rest notifier so
/// only this panel ticks every second.
class RestTimerPanel extends StatelessWidget {
  const RestTimerPanel({super.key, required this.nextLabel});

  /// e.g. "Next: Set 2 of 3".
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.read(context);

    return ValueListenableBuilder<int>(
      valueListenable: controller.restSecondsLeft,
      builder: (context, left, child) {
        final total = controller.restTotalSeconds == 0
            ? 1
            : controller.restTotalSeconds;
        final almostDone = left <= 5;
        final accent = almostDone ? GymColors.lime : GymColors.violet;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: accent.withValues(alpha: .25)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.self_improvement_rounded, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Text('REST', style: GymText.overline.copyWith(color: accent)),
                  const Spacer(),
                  Text(nextLabel, style: GymText.caption),
                ],
              ),
              const SizedBox(height: 16),
              ProgressRing(
                progress: left / total,
                size: 150,
                strokeWidth: 12,
                duration: const Duration(milliseconds: 350),
                colors: [accent, GymColors.blue],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(GymFormat.timer(left)),
                    const SizedBox(height: 2),
                    Text(
                      almostDone ? 'Get ready' : 'Breathe',
                      style: GymText.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GymButton(
                      label: '+15 s',
                      icon: Icons.add_rounded,
                      variant: GymButtonVariant.secondary,
                      height: 50,
                      onPressed: () => controller.addRestTime(15),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GymButton(
                      label: 'Skip rest',
                      icon: Icons.skip_next_rounded,
                      variant: GymButtonVariant.outline,
                      height: 50,
                      onPressed: controller.skipRest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ring + three live stats (exercises, sets, session clock).
class SessionStatsCard extends StatelessWidget {
  const SessionStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final percent = (controller.workoutProgress * 100).round();

    return GymCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ProgressRing(
            progress: controller.workoutProgress,
            size: 84,
            strokeWidth: 9,
            child: Text('$percent%'),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _StatLine(
                  icon: Icons.check_circle_rounded,
                  color: GymColors.green,
                  label: 'Exercises',
                  value: Text(
                    '${controller.completedExercises}/${controller.totalExercises}',
                    style: GymText.title,
                  ),
                ),
                const SizedBox(height: 10),
                _StatLine(
                  icon: Icons.layers_rounded,
                  color: GymColors.violet,
                  label: 'Sets',
                  value: Text(
                    '${controller.completedSets}/${controller.totalSets}',
                    style: GymText.title,
                  ),
                ),
                const SizedBox(height: 10),
                _StatLine(
                  icon: Icons.timer_rounded,
                  color: controller.isSessionRunning
                      ? GymColors.cyan
                      : GymColors.muted,
                  label: controller.isSessionActive
                      ? (controller.isSessionRunning
                            ? 'Session · live'
                            : 'Session · paused')
                      : 'Session',
                  value: const SessionTimerText(style: GymText.title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: GymText.caption.copyWith(fontSize: 13)),
        ),
        value,
      ],
    );
  }
}

/// Live session clock. Rebuilds itself every second without rebuilding the
/// rest of the screen.
class SessionTimerText extends StatelessWidget {
  const SessionTimerText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.read(context);
    return ValueListenableBuilder<int>(
      valueListenable: controller.sessionSeconds,
      builder: (context, seconds, child) =>
          Text(GymFormat.timer(seconds), style: style),
    );
  }
}

/// Pill with a pulsing dot + live timer, used in headers.
class SessionTimerPill extends StatelessWidget {
  const SessionTimerPill({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final running = controller.sessionStatus == SessionStatus.running;
    final color = running ? GymColors.cyan : GymColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: color, active: running),
          const SizedBox(width: 8),
          SessionTimerText(
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .35, end: 1).animate(_pulse),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: widget.color.withValues(alpha: .7), blurRadius: 8),
          ],
        ),
      ),
    );
  }
}

/// Row of segments showing completed vs remaining sets.
class SetProgressDots extends StatelessWidget {
  const SetProgressDots({
    super.key,
    required this.total,
    required this.done,
    this.color = GymColors.cyan,
    this.height = 6,
    this.segmentWidth = 18,
  });

  final int total;
  final int done;
  final Color color;
  final double height;
  final double segmentWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: segmentWidth,
            height: height,
            decoration: BoxDecoration(
              color: i < done ? color : Colors.white.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(height),
              boxShadow: i < done
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: .4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

/// Big gradient hero for today's plan on the Workout tab.
class WorkoutHeroCard extends StatelessWidget {
  const WorkoutHeroCard({
    super.key,
    required this.plan,
    required this.progress,
    required this.completedSets,
    required this.totalSets,
    required this.sessionActive,
    required this.onStart,
  });

  final WorkoutPlan plan;
  final double progress;
  final int completedSets;
  final int totalSets;
  final bool sessionActive;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final done = totalSets > 0 && completedSets >= totalSets;

    final String ctaLabel;
    final IconData ctaIcon;
    if (sessionActive) {
      ctaLabel = 'Open live session';
      ctaIcon = Icons.open_in_full_rounded;
    } else if (done) {
      ctaLabel = 'Workout complete · Review';
      ctaIcon = Icons.emoji_events_rounded;
    } else if (completedSets > 0) {
      ctaLabel = 'Resume workout';
      ctaIcon = Icons.play_arrow_rounded;
    } else {
      ctaLabel = 'Start workout';
      ctaIcon = Icons.play_arrow_rounded;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: GymColors.cyan.withValues(alpha: .28)),
        boxShadow: [
          BoxShadow(
            color: GymColors.cyan.withValues(alpha: .10),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GymColors.cyan.withValues(alpha: .28),
                    GymColors.cyan.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 56,
            child: Transform.rotate(
              angle: -.35,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 120,
                color: GymColors.cyan.withValues(alpha: .07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TODAY · ${plan.focus.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GymText.overline.copyWith(color: GymColors.cyan),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GymPill(
                      label: plan.difficulty,
                      color: GymColors.pink,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(plan.title),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final muscle in plan.muscles)
                      GymPill(
                        label: muscle.label,
                        icon: muscle.visual.icon,
                        color: muscle.visual.color,
                        dense: true,
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _HeroMetric(
                      icon: Icons.timer_outlined,
                      value: '${plan.durationMinutes}',
                      unit: 'min',
                    ),
                    _divider(),
                    _HeroMetric(
                      icon: Icons.local_fire_department_rounded,
                      value: '${plan.estimatedCalories}',
                      unit: 'kcal',
                    ),
                    _divider(),
                    _HeroMetric(
                      icon: Icons.bolt_rounded,
                      value: '${plan.exercises.length}',
                      unit: 'moves',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      '$completedSets of $totalSets sets',
                      style: GymText.caption,
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: GymText.caption.copyWith(
                        color: GymColors.cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearMeter(progress: progress),
                const SizedBox(height: 20),
                GymButton(label: ctaLabel, icon: ctaIcon, onPressed: onStart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white.withValues(alpha: .08),
  );
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: GymColors.cyan, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value),
            Text(unit, style: GymText.caption.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
