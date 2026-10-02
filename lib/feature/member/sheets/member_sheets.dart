import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

Future<void> showAchievementsSheet(BuildContext context) {
  return showGymSheet<void>(
    context,
    expand: true,
    child: const AchievementsSheet(),
  );
}

class AchievementsSheet extends StatelessWidget {
  const AchievementsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final all = controller.achievements;
    final unlocked = all.where((a) => a.unlocked).toList();
    final locked = all.where((a) => !a.unlocked).toList();

    return Column(
      children: [
        SheetHeader(
          title: 'Achievements',
          subtitle: '${unlocked.length} of ${all.length} unlocked',
          icon: Icons.emoji_events_rounded,
          iconColor: GymColors.amber,
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (unlocked.isNotEmpty) ...[
                const _GroupTitle('UNLOCKED'),
                _AchievementGrid(items: unlocked),
              ],
              if (locked.isNotEmpty) ...[
                const _GroupTitle('IN PROGRESS'),
                _AchievementGrid(items: locked),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      sliver: SliverToBoxAdapter(child: Text(text)),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({required this.items});

  final List<Achievement> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      sliver: SliverGrid.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 190,
        ),
        itemBuilder: (context, index) =>
            AchievementTile(achievement: items[index]),
      ),
    );
  }
}

/// Medal-style tile; reused on the Progress screen.
class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final visual = achievement.kind.visual;
    final unlocked = achievement.unlocked;
    final gradient =
        visual.gradient ??
        LinearGradient(
          colors: [visual.color, visual.color.withValues(alpha: .6)],
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked
              ? visual.color.withValues(alpha: .28)
              : GymColors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: unlocked ? gradient : null,
                  color: unlocked ? null : GymColors.surfaceHighest,
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: visual.color.withValues(alpha: .35),
                            blurRadius: 18,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  unlocked ? visual.icon : Icons.lock_rounded,
                  color: unlocked ? GymColors.background : GymColors.muted,
                  size: 22,
                ),
              ),
              const Spacer(),
              if (unlocked)
                Icon(Icons.verified_rounded, color: visual.color, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GymText.title,
          ),
          const SizedBox(height: 3),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GymText.caption,
          ),
          const SizedBox(height: 12),
          if (unlocked)
            Text(
              'UNLOCKED',
              style: GymText.overline.copyWith(
                color: visual.color,
                fontSize: 10.5,
              ),
            )
          else ...[
            LinearMeter(
              progress: achievement.progress,
              height: 6,
              colors: [visual.color, visual.color.withValues(alpha: .6)],
            ),
            const SizedBox(height: 6),
            Text(
              achievement.progressLabel,
              style: GymText.caption.copyWith(fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showAddMeasurementSheet(BuildContext context) {
  return showGymSheet<void>(context, child: const AddMeasurementSheet());
}

/// Form for logging weight, body fat and waist.
class AddMeasurementSheet extends StatefulWidget {
  const AddMeasurementSheet({super.key});

  @override
  State<AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<AddMeasurementSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weight;
  late final TextEditingController _bodyFat;
  late final TextEditingController _waist;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final latest = MemberScope.read(context).latestMeasurement;
    _weight = TextEditingController(text: latest.weightKg.toStringAsFixed(1));
    _bodyFat = TextEditingController(
      text: latest.bodyFatPercent.toStringAsFixed(1),
    );
    _waist = TextEditingController(
      text: latest.waistCm?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    _bodyFat.dispose();
    _waist.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final controller = MemberScope.read(context);
    final waist = double.tryParse(_waist.text.trim());

    await controller.addMeasurement(
      BodyMeasurement(
        date: DateTime.now(),
        weightKg: double.parse(_weight.text.trim()),
        bodyFatPercent: double.parse(_bodyFat.text.trim()),
        waistCm: waist,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    showGymSnack(
      context,
      'Measurement saved',
      icon: Icons.monitor_weight_rounded,
    );
  }

  String? _validateRange(
    String? raw, {
    required double min,
    required double max,
    bool optional = false,
  }) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return optional ? null : 'Required';
    final value = double.tryParse(text);
    if (value == null) return 'Enter a number';
    if (value < min || value > max) {
      return 'Between ${GymFormat.decimal(min)} and ${GymFormat.decimal(max)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final latest = MemberScope.of(context).latestMeasurement;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              title: 'New measurement',
              subtitle: 'Last logged ${GymFormat.shortDate(latest.date)}',
              icon: Icons.straighten_rounded,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MeasurementField(
                    controller: _weight,
                    label: 'Body weight',
                    suffix: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    validator: (v) => _validateRange(v, min: 20, max: 300),
                  ),
                  const SizedBox(height: 12),
                  _MeasurementField(
                    controller: _bodyFat,
                    label: 'Body fat',
                    suffix: '%',
                    icon: Icons.percent_rounded,
                    validator: (v) => _validateRange(v, min: 2, max: 70),
                  ),
                  const SizedBox(height: 12),
                  _MeasurementField(
                    controller: _waist,
                    label: 'Waist (optional)',
                    suffix: 'cm',
                    icon: Icons.straighten_rounded,
                    validator: (v) =>
                        _validateRange(v, min: 30, max: 250, optional: true),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 22),
                  GymButton(
                    label: _saving ? 'Saving…' : 'Save measurement',
                    icon: Icons.check_rounded,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: textInputAction,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      cursorColor: GymColors.cyan,

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: GymColors.muted,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: GymColors.cyan,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: GymColors.muted),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          color: GymColors.muted,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: GymColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: border(GymColors.stroke),
        focusedBorder: border(GymColors.cyan, 1.5),
        errorBorder: border(GymColors.pink),
        focusedErrorBorder: border(GymColors.pink, 1.5),
        errorStyle: const TextStyle(color: GymColors.pink),
      ),
    );
  }
}

Future<void> showExerciseGuideSheet(BuildContext context, Exercise exercise) {
  return showGymSheet<void>(
    context,
    child: ExerciseGuideSheet(exercise: exercise),
  );
}

class ExerciseGuideSheet extends StatelessWidget {
  const ExerciseGuideSheet({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final visual = exercise.muscle.visual;
    final weight = exercise.weightLabel;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: exercise.name,
            subtitle: exercise.subtitle,
            icon: visual.icon,
            iconColor: visual.color,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _GuideMetric(value: '${exercise.sets}', label: 'Sets'),
                    const SizedBox(width: 10),
                    _GuideMetric(
                      value: '${exercise.reps}',
                      label: exercise.isTimed ? 'Seconds' : 'Reps',
                    ),
                    const SizedBox(width: 10),
                    _GuideMetric(
                      value: '${exercise.restSeconds}s',
                      label: 'Rest',
                    ),
                    if (weight != null) ...[
                      const SizedBox(width: 10),
                      _GuideMetric(value: weight, label: 'Load'),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'HOW TO PERFORM',
                  style: GymText.overline.copyWith(color: visual.color),
                ),
                const SizedBox(height: 10),
                Text(
                  exercise.instructions.isEmpty
                      ? 'Use controlled movement, keep good posture, breathe steadily and stop if your form breaks down.'
                      : exercise.instructions,
                  style: GymText.body.copyWith(
                    fontSize: 15,
                    color: GymColors.text.withValues(alpha: .85),
                  ),
                ),
                if (exercise.tips.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text(
                    'COACH CUES',
                    style: GymText.overline.copyWith(color: visual.color),
                  ),
                  const SizedBox(height: 12),
                  for (final tip in exercise.tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: visual.color.withValues(alpha: .14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: visual.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(tip, style: GymText.body)),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GymPill(
                      label: exercise.muscle.label,
                      icon: visual.icon,
                      color: visual.color,
                    ),
                    GymPill.neutral(
                      label: exercise.equipment,
                      icon: Icons.handyman_outlined,
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

class _GuideMetric extends StatelessWidget {
  const _GuideMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: GymColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GymColors.stroke),
        ),
        child: Column(
          children: [
            FittedBox(child: Text(value)),
            const SizedBox(height: 4),
            Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

// Simple read-only sheet: a header and a list of [InfoRow]s.
Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<InfoRow> rows,
  String? subtitle,
  Color iconColor = GymColors.cyan,
  Widget? footer,
}) {
  return showGymSheet<void>(
    context,
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...rows,
                if (footer != null) ...[const SizedBox(height: 8), footer],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showNotificationsSheet(BuildContext context) {
  return showGymSheet<void>(context, child: const NotificationsSheet());
}

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final unread = controller.unreadNotifications;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(
          title: 'Notifications',
          subtitle: unread == 0 ? 'You are all caught up' : '$unread unread',
          icon: Icons.notifications_rounded,
          trailing: unread == 0
              ? null
              : TextButton(
                  onPressed: controller.markAllNotificationsRead,
                  style: TextButton.styleFrom(foregroundColor: GymColors.cyan),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
        ),
        Flexible(
          child: controller.notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'No notifications yet',
                  message:
                      'Workout reminders and trainer messages will show up here.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) => _NotificationTile(
                    notification: controller.notifications[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final MemberNotification notification;

  @override
  Widget build(BuildContext context) {
    final visual = notification.kind.visual;
    final unread = !notification.read;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? visual.color.withValues(alpha: .06) : GymColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unread
              ? visual.color.withValues(alpha: .22)
              : GymColors.stroke,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: visual.icon, color: visual.color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title, style: GymText.title),
                    ),
                    Text(notification.timeAgo, style: GymText.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GymText.body.copyWith(fontSize: 13.5),
                ),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: visual.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showSettingsSheet(
  BuildContext context, {
  VoidCallback? onPrivacy,
}) {
  return showGymSheet<void>(
    context,
    child: SettingsSheet(onPrivacy: onPrivacy),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, this.onPrivacy});

  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            title: 'Settings',
            subtitle: 'Tune GYMORA to the way you train',
            icon: Icons.tune_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SettingSwitch(
                  icon: Icons.notifications_active_outlined,
                  title: 'Workout notifications',
                  subtitle: 'Reminders, streak alerts and trainer messages',
                  value: controller.notificationsEnabled,
                  onChanged: controller.setNotificationsEnabled,
                ),
                const SizedBox(height: 10),
                _SettingSwitch(
                  icon: Icons.timer_outlined,
                  title: 'Auto rest timer',
                  subtitle: 'Start the rest countdown after each logged set',
                  value: controller.autoRestTimer,
                  onChanged: controller.setAutoRestTimer,
                ),
                const SizedBox(height: 10),
                _SettingLink(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy',
                  subtitle: 'Who can see your profile and progress',
                  onTap: onPrivacy == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onPrivacy!();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          IconBadge(icon: icon, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: _Texts(title: title, subtitle: subtitle),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: GymColors.cyan,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? GymColors.background
                  : GymColors.muted,
            ),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            inactiveTrackColor: GymColors.surfaceHighest,
          ),
        ],
      ),
    );
  }
}

class _SettingLink extends StatelessWidget {
  const _SettingLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: icon, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: _Texts(title: title, subtitle: subtitle),
          ),
          const Icon(Icons.chevron_right_rounded, color: GymColors.muted),
        ],
      ),
    );
  }
}

class _SettingShell extends StatelessWidget {
  const _SettingShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: GymColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: GymColors.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GymText.title),
        const SizedBox(height: 3),
        Text(subtitle, style: GymText.caption),
      ],
    );
  }
}

Future<void> showWorkoutSummarySheet(
  BuildContext context,
  WorkoutSummary summary,
) {
  return showGymSheet<void>(
    context,
    child: WorkoutSummarySheet(summary: summary),
  );
}

/// Celebration sheet shown after "Finish workout".
class WorkoutSummarySheet extends StatelessWidget {
  const WorkoutSummarySheet({super.key, required this.summary});

  final WorkoutSummary summary;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.completion * 100).round();
    final great = summary.completion >= .99;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(
            progress: summary.completion,
            size: 150,
            strokeWidth: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$percent%'),
                Text('complete', style: GymText.caption),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            great ? 'Workout crushed! 💪' : 'Nice work — session saved',
            style: GymText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            great
                ? 'Every set done. Recover well and hydrate.'
                : 'Finished ${summary.setsCompleted} of ${summary.totalSets} sets. Pick up the rest next time.',
            style: GymText.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _SummaryTile(
                icon: Icons.timer_outlined,
                color: GymColors.cyan,
                value: GymFormat.timer(summary.durationSeconds),
                label: 'Duration',
              ),
              const SizedBox(width: 10),
              _SummaryTile(
                icon: Icons.local_fire_department_rounded,
                color: GymColors.orange,
                value: '${summary.estimatedCalories}',
                label: 'kcal',
              ),
              const SizedBox(width: 10),
              _SummaryTile(
                icon: Icons.fitness_center_rounded,
                color: GymColors.violet,
                value:
                    '${summary.exercisesCompleted}/${summary.totalExercises}',
                label: 'Exercises',
              ),
            ],
          ),
          const SizedBox(height: 24),
          GymButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            FittedBox(child: Text(value)),
            const SizedBox(height: 2),
            Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
