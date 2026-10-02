import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

class MemberNutritionScreen extends StatelessWidget {
  const MemberNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final meals = controller.meals;

    return MemberPage(
      children: [
        const PageHeader(
          eyebrow: 'Nutrition',
          title: 'Fuel your body',
          subtitle: 'Hit your macros, feel the difference.',
          accent: GymColors.orange,
        ),
        const CalorieSummaryCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: "Today's meals",
              subtitle: 'Your entries for today',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${controller.loggedMealCount} logged',
                    style: const TextStyle(
                      color: GymColors.cyan,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GymIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Log a meal',
                    size: 42,
                    onPressed: () => _showLogMealDialog(context, controller),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (meals.isEmpty)
              const EmptyState(
                icon: Icons.restaurant_menu_rounded,
                title: 'No meals logged today',
                message: 'Add a meal to track today’s nutrition.',
              ),
            for (final meal in meals) ...[
              MealCard(
                key: ValueKey(meal.id),
                meal: meal,
                onToggle: meal.logged
                    ? null
                    : () => controller.logMeal(
                        type: meal.type,
                        name: meal.name,
                        calories: meal.calories,
                        protein: meal.proteinG,
                        carbs: meal.carbsG,
                        fat: meal.fatG,
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
        const WaterTrackerCard(),
        GymCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                color: GymColors.amber,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protein timing', style: GymText.title),
                    const SizedBox(height: 4),
                    Text(
                      'Aim for ${(controller.profile.proteinTargetG / 4).round()} g of protein per meal. '
                      'Spreading it evenly helps recovery after training.',
                      style: GymText.body.copyWith(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _showLogMealDialog(
  BuildContext context,
  MemberController controller,
) async {
  final name = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();
  var type = MealType.breakfast;

  final submitted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: GymColors.surfaceHigh,
        title: const Text('Log a meal', style: GymText.h2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MealType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Meal type'),
                items: MealType.values
                    .map(
                      (mealType) => DropdownMenuItem(
                        value: mealType,
                        child: Text(mealType.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => type = value);
                },
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Meal name'),
                textCapitalization: TextCapitalization.sentences,
              ),
              Row(
                children: [
                  Expanded(child: _numberField(calories, 'Calories')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(protein, 'Protein (g)')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _numberField(carbs, 'Carbs (g)')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(fat, 'Fat (g)')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  if (submitted == true && context.mounted) {
    final parsedCalories = int.tryParse(calories.text);
    final parsedProtein = int.tryParse(protein.text);
    final parsedCarbs = int.tryParse(carbs.text);
    final parsedFat = int.tryParse(fat.text);
    if (name.text.trim().isEmpty ||
        parsedCalories == null ||
        parsedProtein == null ||
        parsedCarbs == null ||
        parsedFat == null) {
      showGymSnack(context, 'Enter a meal name and valid nutrition values.');
    } else {
      try {
        await controller.logMeal(
          type: type,
          name: name.text.trim(),
          calories: parsedCalories,
          protein: parsedProtein,
          carbs: parsedCarbs,
          fat: parsedFat,
        );
        if (context.mounted) {
          showGymSnack(context, 'Meal saved', icon: Icons.restaurant_rounded);
        }
      } catch (error) {
        if (context.mounted) showGymSnack(context, error.toString());
      }
    }
  }

  name.dispose();
  calories.dispose();
  protein.dispose();
  carbs.dispose();
  fat.dispose();
}

Widget _numberField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.number,
  );
}

/// Calorie ring + remaining calories + macro breakdown.
class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final profile = controller.profile;

    return GymCard(
      borderColor: GymColors.cyan.withValues(alpha: .22),
      glowColor: GymColors.cyan,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                progress: controller.calorieProgress,
                size: 140,
                strokeWidth: 13,
                colors: const [
                  GymColors.amber,
                  GymColors.orange,
                  GymColors.pink,
                ],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: GymColors.orange,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(GymFormat.thousands(controller.consumedCalories)),
                    Text(
                      'kcal eaten',
                      style: GymText.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REMAINING', style: GymText.overline),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              GymFormat.thousands(controller.remainingCalories),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kcal',
                          style: GymText.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Line(
                      label: 'Goal',
                      value:
                          '${GymFormat.thousands(profile.dailyCalorieTarget)} kcal',
                    ),
                    const SizedBox(height: 4),
                    _Line(
                      label: 'Meals logged',
                      value:
                          '${controller.loggedMealCount} of ${controller.meals.length}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MacroBar(
                  label: 'Protein',
                  consumed: controller.consumedProtein,
                  target: profile.proteinTargetG,
                  colors: const [GymColors.cyan, GymColors.blue],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MacroBar(
                  label: 'Carbs',
                  consumed: controller.consumedCarbs,
                  target: profile.carbsTargetG,
                  colors: const [GymColors.lime, GymColors.green],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MacroBar(
                  label: 'Fat',
                  consumed: controller.consumedFat,
                  target: profile.fatTargetG,
                  colors: const [GymColors.amber, GymColors.orange],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GymText.caption),
        const Spacer(),
        Text(
          value,
          style: GymText.caption.copyWith(
            color: GymColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.target,
    required this.colors,
  });

  final String label;
  final int consumed;
  final int target;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GymText.caption.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$consumed', style: GymText.title),
              TextSpan(
                text: ' / ${target}g',
                style: GymText.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        LinearMeter(
          progress: target == 0 ? 0 : consumed / target,
          height: 6,
          colors: colors,
        ),
      ],
    );
  }
}

/// Meal row with type icon, foods, macros and an animated "logged" check.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.onToggle});

  final Meal meal;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final visual = meal.type.visual;
    final logged = meal.logged;
    final radius = BorderRadius.circular(24);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: logged
            ? Color.alphaBlend(
                visual.color.withValues(alpha: .06),
                GymColors.surface,
              )
            : GymColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: logged
              ? visual.color.withValues(alpha: .28)
              : GymColors.stroke,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: meal.logged ? null : onToggle,
          splashColor: visual.color.withValues(alpha: .08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(icon: visual.icon, color: visual.color, size: 46),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${meal.type.label.toUpperCase()} · ${meal.time}',
                            style: GymText.overline.copyWith(
                              color: visual.color,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal.name,
                            style: GymText.title.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    _Check(logged: logged, color: visual.color),
                  ],
                ),
                if (meal.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    meal.items.join('  ·  '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GymText.caption.copyWith(
                      color: GymColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Macro(
                      label: 'P',
                      grams: meal.proteinG,
                      color: GymColors.cyan,
                    ),
                    const SizedBox(width: 6),
                    _Macro(
                      label: 'C',
                      grams: meal.carbsG,
                      color: GymColors.lime,
                    ),
                    const SizedBox(width: 6),
                    _Macro(
                      label: 'F',
                      grams: meal.fatG,
                      color: GymColors.amber,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: GymColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.calories} kcal',
                      style: GymText.title.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.logged, required this.color});

  final bool logged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: logged ? color : Colors.transparent,
        border: Border.all(
          color: logged ? color : GymColors.strokeStrong,
          width: 2,
        ),
        boxShadow: logged
            ? [
                BoxShadow(
                  color: color.withValues(alpha: .4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: logged
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey('on'),
                size: 19,
                color: GymColors.background,
              )
            : const SizedBox.shrink(key: ValueKey('off')),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.grams, required this.color});

  final String label;
  final int grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: '${grams}g',
              style: const TextStyle(
                color: GymColors.text,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-by-glass water tracker (250 ml per glass).
class WaterTrackerCard extends StatelessWidget {
  const WaterTrackerCard({super.key});

  static const int glassMl = 250;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final activity = controller.activity;
    final glasses = (activity.waterGoalMl / glassMl).ceil();
    final filled = activity.waterMl ~/ glassMl;
    final reached = activity.waterMl >= activity.waterGoalMl;

    return GymCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            GymColors.violet.withValues(alpha: .10),
            GymColors.surface,
          ),
          GymColors.surface,
        ],
      ),
      borderColor: GymColors.violet.withValues(alpha: .2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                icon: Icons.water_drop_rounded,
                color: GymColors.violet,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hydration', style: GymText.title),
                    const SizedBox(height: 2),
                    Text(
                      reached
                          ? 'Goal reached — nice work!'
                          : '${GymFormat.water(activity.waterGoalMl - activity.waterMl)} to go',
                      style: GymText.caption,
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: GymFormat.water(activity.waterMl)),
                    TextSpan(
                      text: ' / ${GymFormat.water(activity.waterGoalMl)}',
                      style: GymText.caption.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < glasses; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _Glass(
                      filled: i < filled,
                      // Tapping glass N sets today's intake to N glasses.
                      onTap: () =>
                          controller.addWater((i + 1 - filled) * glassMl),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              GymIconButton(
                icon: Icons.remove_rounded,
                size: 48,
                tooltip: 'Remove a glass',
                onPressed: activity.waterMl == 0
                    ? null
                    : () => controller.addWater(-glassMl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GymButton(
                  label: 'Add glass · $glassMl ml',
                  icon: Icons.add_rounded,
                  variant: GymButtonVariant.outline,
                  height: 48,
                  onPressed: () => controller.addWater(glassMl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(4),
            bottom: Radius.circular(9),
          ),
          gradient: filled
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [GymColors.violet, GymColors.blue],
                )
              : null,
          color: filled ? null : Colors.white.withValues(alpha: .05),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : Colors.white.withValues(alpha: .10),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: GymColors.violet.withValues(alpha: .35),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
