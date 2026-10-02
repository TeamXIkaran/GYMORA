import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/feature/auth/providers/auth_provider.dart';
import 'package:gymora_fitness_management/config/theme/app_text.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/model/user_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';
import 'package:gymora_fitness_management/feature/member/sheets/member_sheets.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final profile = controller.profile;

    return MemberPage(
      children: [
        PageHeader(
          eyebrow: 'Account',
          title: 'Profile',
          subtitle: 'Member since ${GymFormat.longDate(profile.memberSince)}',
          accent: GymColors.violet,
          actions: [
            GymIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: () => showSettingsSheet(
                context,
                onPrivacy: () => _showPrivacy(context),
              ),
            ),
          ],
        ),
        ProfileHeaderCard(
          profile: profile,
          streak: controller.streakDays,
          workouts: controller.totalWorkouts,
          badges: controller.unlockedAchievements,
          currentWeight: controller.currentWeight,
        ),
        MembershipCard(profile: profile),
        ProfileMenuSection(
          title: 'Account',
          items: [
            ProfileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal information',
              subtitle: 'Name, email and phone',
              onTap: () => showInfoSheet(
                context,
                title: 'Personal information',
                icon: Icons.person_outline_rounded,
                rows: [
                  InfoRow(
                    label: 'Name',
                    value: profile.fullName,
                    icon: Icons.badge_outlined,
                  ),
                  InfoRow(
                    label: 'Email',
                    value: profile.email,
                    icon: Icons.alternate_email_rounded,
                  ),
                  InfoRow(
                    label: 'Phone',
                    value: profile.phone,
                    icon: Icons.phone_outlined,
                  ),
                  InfoRow(
                    label: 'Member ID',
                    value: profile.memberId,
                    icon: Icons.qr_code_rounded,
                  ),
                ],
              ),
            ),
            ProfileMenuItem(
              icon: Icons.flag_outlined,
              title: 'My goals',
              subtitle: profile.primaryGoal,
              color: GymColors.green,
              onTap: () => showInfoSheet(
                context,
                title: 'My goals',
                icon: Icons.flag_outlined,
                iconColor: GymColors.green,
                rows: [
                  InfoRow(label: 'Primary goal', value: profile.primaryGoal),
                  InfoRow(
                    label: 'Target weight',
                    value: '${GymFormat.decimal(profile.targetWeightKg)} kg',
                  ),
                  InfoRow(
                    label: 'Workouts',
                    value: '${profile.weeklyWorkoutTarget} days / week',
                  ),
                  InfoRow(
                    label: 'Daily calories',
                    value:
                        '${GymFormat.thousands(profile.dailyCalorieTarget)} kcal',
                  ),
                  InfoRow(
                    label: 'Macros (P / C / F)',
                    value:
                        '${profile.proteinTargetG} / ${profile.carbsTargetG} / ${profile.fatTargetG} g',
                  ),
                ],
              ),
            ),
            ProfileMenuItem(
              icon: Icons.monitor_weight_outlined,
              title: 'Measurements',
              subtitle:
                  '${controller.measurements.length} check-ins · log a new one',
              color: GymColors.violet,
              onTap: () => showAddMeasurementSheet(context),
            ),
            ProfileMenuItem(
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              subtitle: '${controller.unlockedAchievements} unlocked',
              color: GymColors.amber,
              onTap: () => showAchievementsSheet(context),
            ),
          ],
        ),
        ProfileMenuSection(
          title: 'Preferences',
          items: [
            ProfileMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: controller.notificationsEnabled
                  ? '${controller.unreadNotifications} unread'
                  : 'Turned off',
              color: GymColors.blue,
              onTap: () => showNotificationsSheet(context),
              trailing: Switch.adaptive(
                value: controller.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
                activeTrackColor: GymColors.cyan,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? GymColors.background
                      : GymColors.muted,
                ),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                inactiveTrackColor: GymColors.surfaceHighest,
              ),
            ),
            ProfileMenuItem(
              icon: Icons.tune_rounded,
              title: 'Settings',
              subtitle: 'Rest timer, privacy and more',
              color: GymColors.cyan,
              onTap: () => showSettingsSheet(
                context,
                onPrivacy: () => _showPrivacy(context),
              ),
            ),
            ProfileMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy',
              subtitle: 'Who can see your data',
              color: GymColors.green,
              onTap: () => _showPrivacy(context),
            ),
          ],
        ),
        ProfileMenuSection(
          title: 'Support',
          items: [
            ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & support',
              subtitle: 'How to use GYMORA',
              color: GymColors.orange,
              onTap: () => _showHelp(context),
            ),
          ],
        ),
        GymButton(
          label: 'Sign out',
          icon: Icons.logout_rounded,
          variant: GymButtonVariant.danger,
          onPressed: () => _confirmLogout(context),
        ),
        Center(
          child: Text(
            'GYMORA · v1.0.0',
            style: GymText.caption.copyWith(fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  void _showPrivacy(BuildContext context) {
    showInfoSheet(
      context,
      title: 'Privacy',
      icon: Icons.lock_outline_rounded,
      iconColor: GymColors.green,
      rows: const [
        InfoRow(label: 'Profile', value: 'Visible to your trainer'),
        InfoRow(label: 'Progress', value: 'You and your trainer'),
        InfoRow(label: 'Leaderboards', value: 'First name only'),
        InfoRow(label: 'Notifications', value: 'As set in Settings'),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showInfoSheet(
      context,
      title: 'Help & support',
      icon: Icons.help_outline_rounded,
      iconColor: GymColors.orange,
      rows: const [
        InfoRow(label: 'Workout', value: 'Tap Start workout, then Log set'),
        InfoRow(label: 'Rest timer', value: 'Starts after each set'),
        InfoRow(label: 'Progress', value: 'Use + to add a measurement'),
        InfoRow(label: 'Nutrition', value: 'Tap a meal to log it'),
        InfoRow(label: 'Account', value: 'Contact your gym front desk'),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .7),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Sign out?', style: GymText.h2),
        content: const Text(
          'You can sign back in any time with your member ID.',
          style: GymText.body,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: GymColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: GymColors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Sign out',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<AuthProvider>().logout();
    } catch (_) {
      if (context.mounted) {
        showGymSnack(context, 'Could not sign out. Please try again.');
      }
      return;
    }

    if (context.mounted) context.go(AppRoutes.roleSelectionRoute);
  }
}

/// Avatar, member ID and headline fitness stats.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.streak,
    required this.workouts,
    required this.badges,
    required this.currentWeight,
  });

  final MemberProfile profile;
  final int streak;
  final int workouts;
  final int badges;
  final double currentWeight;

  @override
  Widget build(BuildContext context) {
    return GymCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            GymColors.cyan.withValues(alpha: .14),
            GymColors.surfaceHigh,
          ),
          GymColors.surface,
        ],
      ),
      borderColor: GymColors.cyan.withValues(alpha: .2),
      glowColor: GymColors.cyan,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          GradientAvatar(
            initials: GymFormat.initials(profile.fullName),
            size: 96,
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: GymText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              GymPill(
                label: profile.planName.toUpperCase(),
                icon: Icons.workspace_premium_rounded,
                dense: true,
              ),
              GymPill.neutral(
                label: profile.memberId,
                icon: Icons.badge_outlined,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ProfileStat(
                value: '$streak',
                label: 'Day streak',
                icon: Icons.local_fire_department_rounded,
                color: GymColors.orange,
              ),
              _profileDivider(),
              _ProfileStat(
                value: '$workouts',
                label: 'Workouts',
                icon: Icons.fitness_center_rounded,
                color: GymColors.cyan,
              ),
              _profileDivider(),
              _ProfileStat(
                value: '$badges',
                label: 'Badges',
                icon: Icons.emoji_events_rounded,
                color: GymColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: GymColors.background.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _ProfileBodyStat(
                  label: 'Height',
                  value: '${GymFormat.decimal(profile.heightCm)} cm',
                ),
                _ProfileBodyStat(
                  label: 'Weight',
                  value: '${GymFormat.decimal(currentWeight)} kg',
                ),
                _ProfileBodyStat(
                  label: 'Target',
                  value: '${GymFormat.decimal(profile.targetWeightKg)} kg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: .08),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(
                value,
                style: GymText.title.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _ProfileBodyStat extends StatelessWidget {
  const _ProfileBodyStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GymText.caption.copyWith(fontSize: 11.5)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GymText.title.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Credit-card style membership pass.
class MembershipCard extends StatelessWidget {
  const MembershipCard({super.key, required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = profile.daysLeft(now);
    final expiringSoon = daysLeft <= 30;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F6B), Color(0xFF15235C), Color(0xFF0A1A33)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GymColors.violet.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: GymColors.violet.withValues(alpha: .22),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GymColors.cyan.withValues(alpha: .22),
                    GymColors.cyan.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 14,
            child: Icon(
              Icons.fitness_center_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GYMORA',
                      style: GymText.title.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.contactless_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.planName.toUpperCase(),
                  style: GymText.overline.copyWith(color: GymColors.cyan),
                ),
                const SizedBox(height: 34),
                Text(profile.fullName, style: GymText.h3),
                const SizedBox(height: 4),
                Text(
                  'Trainer · ${profile.trainerName}',
                  style: GymText.caption.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Valid till ${GymFormat.longDate(profile.validUntil)}',
                      style: GymText.caption.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$daysLeft days left',
                      style: TextStyle(
                        color: expiringSoon ? GymColors.amber : GymColors.cyan,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearMeter(
                  progress: profile.membershipElapsed(now),
                  height: 5,
                  colors: expiringSoon
                      ? const [GymColors.amber, GymColors.orange]
                      : const [GymColors.cyan, GymColors.violet],
                  trackColor: Colors.white.withValues(alpha: .1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = GymColors.cyan,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  /// Replaces the default chevron (e.g. a Switch).
  final Widget? trailing;
}

/// A titled group of menu rows inside one rounded card.
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(title.toUpperCase(), style: GymText.overline),
        ),
        Material(
          color: GymColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GymColors.stroke),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 72,
                    color: GymColors.stroke,
                  ),
                _MenuRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: item.icon, color: item.color, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: GymText.title),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: GymText.caption),
                ],
              ),
            ),
            item.trailing ??
                const Icon(Icons.chevron_right_rounded, color: GymColors.muted),
          ],
        ),
      ),
    );
  }
}
