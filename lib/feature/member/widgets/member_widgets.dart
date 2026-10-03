// Ambient colour glows painted behind the whole member app.
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';

///
/// Uses cheap radial gradients (no blur filters) so it costs nothing while
/// scrolling.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -180,
              left: -160,
              child: _Glow(color: GymColors.cyan, size: 460, opacity: .13),
            ),
            Positioned(
              top: 260,
              right: -220,
              child: _Glow(color: GymColors.blue, size: 440, opacity: .10),
            ),
            Positioned(
              bottom: -220,
              left: -140,
              child: _Glow(color: GymColors.violet, size: 460, opacity: .09),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, required this.opacity});

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

enum GymButtonVariant { primary, secondary, outline, danger }

/// Pill-shaped action button. The primary variant uses the brand gradient
/// with a soft cyan glow.
class GymButton extends StatelessWidget {
  const GymButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GymButtonVariant.primary,
    this.height = 56,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GymButtonVariant variant;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(height / 2.6);

    final Color foreground;
    final Color? background;
    final Gradient? gradient;
    final Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case GymButtonVariant.primary:
        foreground = GymColors.background;
        background = null;
        gradient = GymColors.primaryGradient;
        border = null;
        shadow = [
          BoxShadow(
            color: GymColors.cyan.withValues(alpha: .32),
            blurRadius: 26,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ];
      case GymButtonVariant.secondary:
        foreground = GymColors.text;
        background = GymColors.surfaceHigh;
        gradient = null;
        border = Border.all(color: GymColors.strokeStrong);
      case GymButtonVariant.outline:
        foreground = GymColors.cyan;
        background = GymColors.cyan.withValues(alpha: .06);
        gradient = null;
        border = Border.all(color: GymColors.cyan.withValues(alpha: .35));
      case GymButtonVariant.danger:
        foreground = GymColors.pink;
        background = GymColors.pink.withValues(alpha: .08);
        gradient = null;
        border = Border.all(color: GymColors.pink.withValues(alpha: .3));
    }

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : .45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          gradient: gradient,
          borderRadius: radius,
          border: border,
          boxShadow: enabled ? shadow : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            splashColor: foreground.withValues(alpha: .12),
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foreground, size: 21),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GymText.button.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Square icon-only button used in headers (bell, calendar, close…).
class GymIconButton extends StatelessWidget {
  const GymIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
    this.size = 48,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int badgeCount;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * .34);

    Widget child = DecoratedBox(
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: radius,
        border: Border.all(color: GymColors.stroke),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: GymColors.text, size: size * .46),
          ),
        ),
      ),
    );

    if (badgeCount > 0) {
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GymColors.pink,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GymColors.background, width: 2),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

/// Base surface for every card in the member app.
///
/// Dark glassy surface, hairline border, optional gradient, optional coloured
/// glow and optional tap ripple clipped to the card radius.
class GymCard extends StatelessWidget {
  const GymCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.onTap,
    this.gradient,
    this.color,
    this.borderColor,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;

  /// When set, adds a soft coloured shadow under the card.
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final glow = glowColor;

    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? GymColors.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? GymColors.stroke),
        boxShadow: glow == null
            ? null
            : [
                BoxShadow(
                  color: glow.withValues(alpha: .16),
                  blurRadius: 36,
                  spreadRadius: -6,
                  offset: const Offset(0, 16),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                splashColor: GymColors.cyan.withValues(alpha: .08),
                highlightColor: Colors.white.withValues(alpha: .03),
                child: content,
              ),
      ),
    );
  }
}

/// Small rounded label, e.g. "INTERMEDIATE" or "3 × 12 reps".
class GymPill extends StatelessWidget {
  const GymPill({
    super.key,
    required this.label,
    this.icon,
    this.color = GymColors.cyan,
    this.filled = false,
    this.dense = false,
  });

  /// Neutral grey pill for secondary metadata.
  const GymPill.neutral({
    super.key,
    required this.label,
    this.icon,
    this.dense = false,
  }) : color = GymColors.textSecondary,
       filled = false;

  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? GymColors.background : color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens a styled bottom sheet that still has access to [MemberScope].
///
/// Set [expand] for tall sheets (forms, long lists); they start at 88% of the
/// screen height and scroll internally.
Future<T?> showGymSheet<T>(
  BuildContext context, {
  required Widget child,
  bool expand = false,
}) {
  final controller = MemberScope.read(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .6),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final maxHeight = media.size.height * (expand ? .88 : .82);

      return MemberScope(
        controller: controller,
        child: Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minHeight: expand ? maxHeight : 0,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: GymColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const SheetHandle(),
                    Flexible(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

/// Title row used at the top of every sheet.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor = GymColors.cyan,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Row(
        children: [
          if (icon != null) ...[
            IconBadge(icon: icon!, color: iconColor, size: 46),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GymText.h2),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: GymText.caption),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Floating dark snackbar with a leading icon.
void showGymSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
  Color color = GymColors.cyan,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GymColors.surfaceHigh,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: color.withValues(alpha: .28)),
        ),
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: GymColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

/// Circular avatar with a brand-gradient ring and initials.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({super.key, required this.initials, this.size = 52});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .05),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            GymColors.cyan,
            GymColors.blue,
            GymColors.violet,
            GymColors.cyan,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: GymColors.cyan.withValues(alpha: .25),
            blurRadius: 18,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: GymColors.surfaceHigh,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: GymColors.text,
            fontSize: size * .34,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}

/// Rounded-square icon container with a tinted background.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = GymColors.cyan,
    this.size = 44,
    this.gradient,
  });

  final IconData icon;
  final Color color;
  final double size;

  /// When provided the badge is filled with this gradient and the icon is dark.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final filled = gradient != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? null : color.withValues(alpha: .12),
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * .32),
        border: filled ? null : Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Icon(
        icon,
        size: size * .48,
        color: filled ? GymColors.background : color,
      ),
    );
  }
}

/// Label / value row used inside information sheets.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GymColors.stroke),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: GymColors.muted, size: 19),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: const TextStyle(
              color: GymColors.muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: GymColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated horizontal progress bar with a gradient fill.
class LinearMeter extends StatelessWidget {
  const LinearMeter({
    super.key,
    required this.progress,
    this.height = 8,
    this.colors = const [GymColors.cyan, GymColors.blue],
    this.trackColor,
    this.duration = const Duration(milliseconds: 800),
  });

  final double progress;
  final double height;
  final List<Color> colors;
  final Color? trackColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: trackColor ?? Colors.white.withValues(alpha: .06),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        colors: colors.length >= 2
                            ? colors
                            : [colors.first, colors.first],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MemberNavItem {
  const MemberNavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const List<MemberNavItem> memberNavItems = [
  MemberNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  MemberNavItem(
    Icons.fitness_center_outlined,
    Icons.fitness_center_rounded,
    'Workout',
  ),
  MemberNavItem(Icons.insights_outlined, Icons.insights_rounded, 'Progress'),
  MemberNavItem(
    Icons.restaurant_outlined,
    Icons.restaurant_rounded,
    'Nutrition',
  ),
  MemberNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

/// Floating frosted-glass navigation bar.
///
/// The selected tab gets a gradient indicator pill behind its icon (Material 3
/// style) plus a glowing dot, so it reads clearly even at a glance.
class MemberBottomNav extends StatelessWidget {
  const MemberBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .55),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: GymColors.surface.withValues(alpha: .82),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < memberNavItems.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: memberNavItems[i],
                      selected: i == selectedIndex,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MemberNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GymColors.cyan : GymColors.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: selected ? 54 : 40,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          GymColors.cyan.withValues(alpha: .22),
                          GymColors.blue.withValues(alpha: .14),
                        ],
                      )
                    : null,
                border: selected
                    ? Border.all(color: GymColors.cyan.withValues(alpha: .28))
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey<bool>(selected),
                  color: color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: selected ? GymColors.text : GymColors.muted,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable page body shared by all tabs.
///
/// Adds pull-to-refresh, bouncing physics and enough bottom padding to clear
/// the floating navigation bar.
class MemberPage extends StatelessWidget {
  const MemberPage({super.key, required this.children, this.spacing = 22});

  final List<Widget> children;

  /// Vertical gap inserted between [children].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return RefreshIndicator(
      color: GymColors.cyan,
      backgroundColor: GymColors.surfaceHigh,
      onRefresh: () => MemberScope.read(context).refresh(),
      child: ListView.separated(
        // Each tab lives in an IndexedStack, so none of them may claim the
        // shared PrimaryScrollController.
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 128 + bottomInset),
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(height: spacing),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Top-of-page header used by Workout, Progress, Nutrition and Profile.
///
/// ```
/// ● EYEBROW
/// Big title                         [actions]
/// Subtitle
/// ```
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.accent = GymColors.cyan,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: .6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      eyebrow.toUpperCase(),
                      style: GymText.overline.copyWith(color: accent),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title, style: GymText.h1),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: GymText.body.copyWith(color: GymColors.muted),
                  ),
                ],
              ],
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 10), action],
        ],
      ),
    );
  }
}

/// Animated circular progress ring with a sweep gradient and rounded caps.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.colors = const [GymColors.cyan, GymColors.blue],
    this.trackColor,
    this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  /// 0..1
  final double progress;
  final double size;
  final double strokeWidth;

  /// At least two colours; drawn clockwise from 12 o'clock.
  final List<Color> colors;
  final Color? trackColor;
  final Widget? child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, inner) {
          return CustomPaint(
            painter: RingPainter(
              progress: value,
              strokeWidth: strokeWidth,
              colors: colors,
              trackColor: trackColor ?? Colors.white.withValues(alpha: .06),
            ),
            child: Center(child: inner),
          );
        },
        child: child,
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  const RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final gradientColors = colors.length >= 2
        ? colors
        : [colors.first, colors.first];

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    // Soft glow behind the arc.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = gradientColors.last.withValues(alpha: .35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * .6);

    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        !_sameColors(oldDelegate.colors, colors);
  }

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Data for one ring inside [ActivityRings].
class RingData {
  const RingData({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;
}

/// Concentric "activity rings" (outer → inner).
class ActivityRings extends StatelessWidget {
  const ActivityRings({
    super.key,
    required this.rings,
    this.size = 150,
    this.strokeWidth = 13,
    this.gap = 4,
    this.center,
  });

  final List<RingData> rings;
  final double size;
  final double strokeWidth;
  final double gap;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < rings.length; i++)
            ProgressRing(
              progress: rings[i].progress,
              colors: rings[i].colors,
              strokeWidth: strokeWidth,
              size: size - i * 2 * (strokeWidth + gap),
              trackColor: rings[i].colors.first.withValues(alpha: .10),
              duration: Duration(milliseconds: 900 + i * 180),
            ),
          ?center,
        ],
      ),
    );
  }
}

/// Section title with optional subtitle and trailing text action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GymText.h3),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: GymText.caption),
              ],
            ],
          ),
        ),
        ?trailing,
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: GymColors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

/// Pill-style segmented control with an animated sliding thumb.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 38,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: GymColors.background,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: GymColors.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / options.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: segmentWidth * selectedIndex,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: GymColors.primaryGradient,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < options.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: i == selectedIndex
                                  ? GymColors.background
                                  : GymColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                            child: Text(options[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Smooth, animated line chart with a gradient area fill and a glowing
/// "current value" dot on the last point.
class SmoothLineChart extends StatelessWidget {
  const SmoothLineChart({
    super.key,
    required this.values,
    this.labels = const [],
    this.color = GymColors.cyan,
    this.height = 160,
    this.showGrid = true,
    this.showDots = true,
  });

  final List<double> values;

  /// Optional x-axis labels, spread evenly under the chart.
  final List<String> labels;
  final Color color;
  final double height;
  final bool showGrid;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            // Re-animate when the data changes.
            key: ValueKey<int>(Object.hashAll(values)),
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, reveal, child) {
              return CustomPaint(
                painter: _LineChartPainter(
                  values: values,
                  color: color,
                  reveal: reveal,
                  showGrid: showGrid,
                  showDots: showDots,
                ),
              );
            },
          ),
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in labels)
                Text(
                  label,
                  style: const TextStyle(
                    color: GymColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.values,
    required this.color,
    required this.reveal,
    required this.showGrid,
    required this.showDots,
  });

  final List<double> values;
  final Color color;
  final double reveal;
  final bool showGrid;
  final bool showDots;

  static const double _dotRadius = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      final grid = Paint()
        ..color = Colors.white.withValues(alpha: .05)
        ..strokeWidth = 1;
      const lines = 4;
      for (var i = 0; i < lines; i++) {
        final y = size.height * i / (lines - 1);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
    }

    if (values.isEmpty) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < .001
        ? 1.0
        : maxValue - minValue;

    // Keep the line away from the top/bottom edges.
    const verticalPadding = 14.0;
    final usableHeight = size.height - verticalPadding * 2;
    final horizontalInset = showDots ? _dotRadius + 4 : 0.0;
    final usableWidth = size.width - horizontalInset * 2;

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          values.length == 1
              ? size.width / 2
              : horizontalInset + usableWidth * i / (values.length - 1),
          verticalPadding + usableHeight * (1 - (values[i] - minValue) / range),
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      line.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * reveal, size.height));

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .30), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (showDots) {
      final dot = Paint()..color = color;
      final hole = Paint()..color = GymColors.surface;
      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawCircle(points[i], 3.2, dot);
        canvas.drawCircle(points[i], 1.4, hole);
      }
    }
    canvas.restore();

    // Highlight the latest value once the reveal reaches it.
    if (showDots && reveal > .98) {
      final last = points.last;
      canvas.drawCircle(
        last,
        12,
        Paint()..color = color.withValues(alpha: .18),
      );
      canvas.drawCircle(
        last,
        _dotRadius + 1.5,
        Paint()..color = GymColors.background,
      );
      canvas.drawCircle(last, _dotRadius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.color != color ||
        oldDelegate.values != values;
  }
}

/// Branded loading state shown while the dashboard is first fetched.
class MemberLoadingView extends StatelessWidget {
  const MemberLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardShimmer(
      message: 'Preparing your training dashboard...',
    );
  }
}

class MemberErrorView extends StatelessWidget {
  const MemberErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(
              icon: Icons.wifi_off_rounded,
              color: GymColors.pink,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: GymText.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, style: GymText.body, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GymButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.roleSelectionRoute),
              icon: const Icon(Icons.switch_account_rounded),
              label: const Text('Back to role selection'),
              style: TextButton.styleFrom(
                foregroundColor: GymColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft empty-state block used inside cards and sheets.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          IconBadge(icon: icon, color: GymColors.muted, size: 52),
          const SizedBox(height: 14),
          Text(title, style: GymText.title, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(message!, style: GymText.caption, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Icon + accent colour for model enums. Keeps models free of UI imports.
class Visual {
  const Visual(this.icon, this.color, [this.gradient]);

  final IconData icon;
  final Color color;
  final Gradient? gradient;
}

extension MealTypeVisual on MealType {
  Visual get visual => switch (this) {
    MealType.breakfast => const Visual(
      Icons.free_breakfast_rounded,
      GymColors.amber,
    ),
    MealType.lunch => const Visual(Icons.lunch_dining_rounded, GymColors.green),
    MealType.snack => const Visual(Icons.local_cafe_rounded, GymColors.violet),
    MealType.dinner => const Visual(
      Icons.dinner_dining_rounded,
      GymColors.blue,
    ),
  };
}

extension AchievementKindVisual on AchievementKind {
  Visual get visual => switch (this) {
    AchievementKind.streak => const Visual(
      Icons.local_fire_department_rounded,
      GymColors.orange,
      GymColors.fireGradient,
    ),
    AchievementKind.workouts => const Visual(
      Icons.fitness_center_rounded,
      GymColors.cyan,
      GymColors.primaryGradient,
    ),
    AchievementKind.hydration => const Visual(
      Icons.water_drop_rounded,
      GymColors.blue,
      GymColors.violetGradient,
    ),
    AchievementKind.tracking => const Visual(
      Icons.monitor_weight_rounded,
      GymColors.green,
    ),
    AchievementKind.nutrition => const Visual(
      Icons.restaurant_rounded,
      GymColors.lime,
    ),
    AchievementKind.earlyBird => const Visual(
      Icons.wb_sunny_rounded,
      GymColors.amber,
    ),
  };
}

extension NotificationKindVisual on NotificationKind {
  Visual get visual => switch (this) {
    NotificationKind.workout => const Visual(
      Icons.fitness_center_rounded,
      GymColors.cyan,
    ),
    NotificationKind.streak => const Visual(
      Icons.local_fire_department_rounded,
      GymColors.orange,
    ),
    NotificationKind.nutrition => const Visual(
      Icons.restaurant_rounded,
      GymColors.green,
    ),
    NotificationKind.membership => const Visual(
      Icons.card_membership_rounded,
      GymColors.violet,
    ),
    NotificationKind.trainer => const Visual(
      Icons.sports_rounded,
      GymColors.blue,
    ),
  };
}

extension MuscleGroupVisual on MuscleGroup {
  Visual get visual => switch (this) {
    MuscleGroup.chest => const Visual(
      Icons.accessibility_new_rounded,
      GymColors.cyan,
    ),
    MuscleGroup.back => const Visual(
      Icons.airline_seat_flat_rounded,
      GymColors.blue,
    ),
    MuscleGroup.shoulders => const Visual(
      Icons.sports_gymnastics_rounded,
      GymColors.violet,
    ),
    MuscleGroup.arms => const Visual(
      Icons.fitness_center_rounded,
      GymColors.pink,
    ),
    MuscleGroup.core => const Visual(
      Icons.self_improvement_rounded,
      GymColors.amber,
    ),
    MuscleGroup.legs => const Visual(
      Icons.directions_run_rounded,
      GymColors.green,
    ),
  };
}

/// Vertical bar chart for a week of values. The highlighted bar (usually
/// today) gets the brand gradient and a glow.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.highlightIndex,
    this.height = 150,
    this.barWidth = 22,
    this.valueSuffix = '',
  }) : assert(values.length == labels.length);

  final List<int> values;
  final List<String> labels;
  final int? highlightIndex;
  final double height;
  final double barWidth;

  /// Appended to the value tooltip above the highlighted bar, e.g. "m".
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (max, v) => v > max ? v : max);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: _Bar(
                value: values[i],
                ratio: values[i] / safeMax,
                label: labels[i],
                highlighted: i == highlightIndex,
                width: barWidth,
                delay: i,
                valueSuffix: valueSuffix,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.ratio,
    required this.label,
    required this.highlighted,
    required this.width,
    required this.delay,
    required this.valueSuffix,
  });

  final int value;
  final double ratio;
  final String label;
  final bool highlighted;
  final double width;
  final int delay;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final empty = value == 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 18,
          child: value > 0
              ? Text(
                  '$value$valueSuffix',
                  style: TextStyle(
                    color: highlighted ? GymColors.cyan : GymColors.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: Duration(milliseconds: 650 + delay * 70),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  heightFactor: empty ? .04 : value.clamp(.06, 1.0),
                  child: child,
                );
              },
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / 2.4),
                  gradient: highlighted
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [GymColors.cyan, GymColors.blue],
                        )
                      : null,
                  color: highlighted
                      ? null
                      : empty
                      ? Colors.white.withValues(alpha: .05)
                      : GymColors.surfaceHighest,
                  boxShadow: highlighted
                      ? [
                          BoxShadow(
                            color: GymColors.cyan.withValues(alpha: .35),
                            blurRadius: 18,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: highlighted ? GymColors.text : GymColors.muted,
            fontSize: 12,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
