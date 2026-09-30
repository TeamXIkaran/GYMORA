import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/sheets/member_sheets.dart';
import 'package:gymora_fitness_management/feature/member/state/member_state.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

class MemberProgressScreen extends StatelessWidget {
  const MemberProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);

    return MemberPage(
      children: [
        PageHeader(
          eyebrow: 'Progress',
          title: 'Your transformation',
          subtitle: 'Every check-in brings the goal closer.',
          accent: GymColors.green,
          actions: [
            GymIconButton(
              icon: Icons.add_rounded,
              tooltip: 'Add measurement',
              onPressed: () => showAddMeasurementSheet(context),
            ),
          ],
        ),
        const BodyMetricsRow(),
        const GoalProgressCard(),
        const TrendChartCard(),
        const WeeklyActivityCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Achievements',
              subtitle:
                  '${controller.unlockedAchievements} of ${controller.achievements.length} unlocked',
              actionLabel: 'See all',
              onAction: () => showAchievementsSheet(context),
            ),
            const SizedBox(height: 12),
            const AchievementsStrip(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Check-in history',
              subtitle:
                  '${controller.measurements.length} measurements recorded',
            ),
            const SizedBox(height: 12),
            const MeasurementHistoryCard(),
            const SizedBox(height: 14),
            GymButton(
              label: 'Add measurement',
              icon: Icons.add_rounded,
              variant: GymButtonVariant.outline,
              onPressed: () => showAddMeasurementSheet(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Horizontal carousel of achievement medals, unlocked first.
class AchievementsStrip extends StatelessWidget {
  const AchievementsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [...MemberScope.of(context).achievements]
      ..sort((a, b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
        return b.progress.compareTo(a.progress);
      });

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: achievements.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 164,
          child: AchievementTile(achievement: achievements[index]),
        ),
      ),
    );
  }
}

/// Weight · Body fat · BMI tiles.
class BodyMetricsRow extends StatelessWidget {
  const BodyMetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final bmi = controller.bmi;

    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.monitor_weight_rounded,
            color: GymColors.cyan,
            label: 'Weight',
            value: GymFormat.decimal(controller.currentWeight),
            unit: 'kg',
            footer: '${GymFormat.signed(controller.weightChange)} kg',
            footerGood: controller.weightChange <= 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.water_drop_rounded,
            color: GymColors.violet,
            label: 'Body fat',
            value: GymFormat.decimal(controller.currentBodyFat),
            unit: '%',
            footer: '${GymFormat.signed(controller.bodyFatChange)} %',
            footerGood: controller.bodyFatChange <= 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.speed_rounded,
            color: GymColors.green,
            label: 'BMI',
            value: bmi.toStringAsFixed(1),
            unit: '',
            footer: _bmiLabel(bmi),
            footerGood: bmi >= 18.5 && bmi < 25,
          ),
        ),
      ],
    );
  }

  static String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.footer,
    required this.footerGood,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final String footer;
  final bool footerGood;

  @override
  Widget build(BuildContext context) {
    return GymCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 36),
          const SizedBox(height: 14),
          Text(label, style: GymText.caption),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: GymText.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: footerGood ? GymColors.green : GymColors.amber,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Start → current → target weight journey.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final profile = controller.profile;
    final start = controller.firstMeasurement.weightKg;
    final current = controller.currentWeight;
    final target = profile.targetWeightKg;
    final progress = controller.weightGoalProgress;
    final remaining = (current - target).abs();
    final reached = progress >= 1;

    return GymCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOAL · ${profile.primaryGoal.toUpperCase()}',
                      style: GymText.overline,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reached
                          ? 'Target reached 🎉'
                          : '${GymFormat.decimal(remaining)} kg to go',
                      style: GymText.h2,
                    ),
                  ],
                ),
              ),
              GymPill(
                label: '${(progress * 100).round()}%',
                color: GymColors.green,
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearMeter(
            progress: progress,
            height: 10,
            colors: const [GymColors.green, GymColors.cyan],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Endpoint(
                label: 'Start',
                value: '${GymFormat.decimal(start)} kg',
              ),
              const Spacer(),
              _Endpoint(
                label: 'Now',
                value: '${GymFormat.decimal(current)} kg',
                highlight: true,
                align: CrossAxisAlignment.center,
              ),
              const Spacer(),
              _Endpoint(
                label: 'Target',
                value: '${GymFormat.decimal(target)} kg',
                align: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.label,
    required this.value,
    this.highlight = false,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final bool highlight;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GymText.title.copyWith(
            color: highlight ? GymColors.cyan : GymColors.text,
          ),
        ),
      ],
    );
  }
}

/// Newest-first log of body check-ins with change vs the previous entry.
class MeasurementHistoryCard extends StatelessWidget {
  const MeasurementHistoryCard({super.key, this.maxItems = 5});

  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final measurements = MemberScope.of(context).measurements;
    final newestFirst = measurements.reversed.toList();
    final shown = newestFirst.take(maxItems).toList();

    return GymCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) Container(height: 1, color: GymColors.stroke),
            _HistoryRow(
              measurement: shown[i],
              previous: i + 1 < newestFirst.length ? newestFirst[i + 1] : null,
              isLatest: i == 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.measurement,
    required this.previous,
    required this.isLatest,
  });

  final BodyMeasurement measurement;
  final BodyMeasurement? previous;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final prev = previous;
    final delta = prev == null ? null : measurement.weightKg - prev.weightKg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isLatest
                  ? GymColors.cyan.withValues(alpha: .1)
                  : GymColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLatest
                    ? GymColors.cyan.withValues(alpha: .3)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text('${measurement.date.day}'),
                Text(
                  GymFormat.shortDate(
                    measurement.date,
                  ).split(' ').first.toUpperCase(),
                  style: GymText.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${GymFormat.decimal(measurement.weightKg)} kg',
                  style: GymText.title,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    '${GymFormat.decimal(measurement.bodyFatPercent)}% fat',
                    if (measurement.waistCm != null)
                      '${GymFormat.decimal(measurement.waistCm!)} cm waist',
                  ].join(' · '),
                  style: GymText.caption,
                ),
              ],
            ),
          ),
          if (delta != null)
            Text(
              '${GymFormat.signed(delta)} kg',
              style: TextStyle(
                color: delta <= 0 ? GymColors.green : GymColors.amber,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            Text(
              'Start',
              style: GymText.caption.copyWith(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

enum _Metric { weight, bodyFat, waist }

/// Switchable trend chart for weight / body fat / waist.
class TrendChartCard extends StatefulWidget {
  const TrendChartCard({super.key});

  @override
  State<TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends State<TrendChartCard> {
  _Metric _metric = _Metric.weight;

  @override
  Widget build(BuildContext context) {
    final measurements = MemberScope.of(context).measurements;
    final points = _pointsFor(measurements);
    final values = [for (final p in points) p.$2];
    final color = switch (_metric) {
      _Metric.weight => GymColors.cyan,
      _Metric.bodyFat => GymColors.violet,
      _Metric.waist => GymColors.green,
    };
    final unit = switch (_metric) {
      _Metric.weight => 'kg',
      _Metric.bodyFat => '%',
      _Metric.waist => 'cm',
    };

    final latest = values.isEmpty ? null : values.last;
    final change = values.length < 2 ? 0.0 : values.last - values.first;

    return GymCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Body trends', style: GymText.h3),
              const Spacer(),
              Text('${measurements.length} check-ins', style: GymText.caption),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedToggle(
            options: const ['Weight', 'Body fat', 'Waist'],
            selectedIndex: _metric.index,
            onChanged: (index) =>
                setState(() => _metric = _Metric.values[index]),
          ),
          const SizedBox(height: 18),
          if (latest == null)
            SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'No data logged for this metric yet.',
                  style: GymText.caption,
                ),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  GymFormat.decimal(latest),
                 
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GymText.caption.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${GymFormat.signed(change)} $unit since start',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: change <= 0 ? GymColors.green : GymColors.amber,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SmoothLineChart(
              height: 170,
              color: color,
              values: values,
              labels: [for (final p in points) GymFormat.shortDate(p.$1)],
            ),
          ],
        ],
      ),
    );
  }

  List<(DateTime, double)> _pointsFor(List<BodyMeasurement> measurements) {
    final result = <(DateTime, double)>[];
    for (final m in measurements) {
      final double? value = switch (_metric) {
        _Metric.weight => m.weightKg,
        _Metric.bodyFat => m.bodyFatPercent,
        _Metric.waist => m.waistCm,
      };
      if (value != null) result.add((m.date, value));
    }
    // Keep the axis readable: show at most the last 8 check-ins.
    return result.length > 8 ? result.sublist(result.length - 8) : result;
  }
}

/// Active minutes for the last 7 days + weekly totals.
class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final minutes = controller.weeklyMinutes;
    final today = DateTime.now();
    final labels = [
      for (var i = 0; i < minutes.length; i++)
        GymFormat.weekdayShort(
          today.subtract(Duration(days: minutes.length - 1 - i)),
        ),
    ];
    final activeDays = controller.workoutsThisWeek;
    final average = activeDays == 0
        ? 0
        : (controller.minutesThisWeek / activeDays).round();

    return GymCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('This week', style: GymText.h3),
              const Spacer(),
              Text('Active minutes', style: GymText.caption),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Total(
                value: '${controller.minutesThisWeek}',
                label: 'Total min',
                color: GymColors.cyan,
              ),
              _Total(
                value: '$activeDays/${controller.profile.weeklyWorkoutTarget}',
                label: 'Workouts',
                color: GymColors.violet,
              ),
              _Total(
                value: '$average',
                label: 'Avg min',
                color: GymColors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          WeeklyBarChart(
            values: minutes,
            labels: labels,
            highlightIndex: minutes.length - 1,
            height: 160,
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value),
              Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }
}
