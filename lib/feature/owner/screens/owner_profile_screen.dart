import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class OwnerProfileScreen extends StatefulWidget {
  /// Called by the back arrow. The dashboard passes a callback that
  /// switches to the Home tab. When null, the arrow pops (if possible).
  final VoidCallback? onBack;

  const OwnerProfileScreen({super.key, this.onBack});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _buttonShimmerController;
  bool _isLoggingOut = false;
  String? _ownerPhotoPath;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _buttonShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OwnerDashboardProvider>().ensureLoaded();
      _loadOwnerProfile();
    });
  }

  Future<void> _loadOwnerProfile() async {
    final loginProvider = context.read<OwnerLoginProvider>();
    if (loginProvider.owner == null) await loginProvider.fetchProfile();
    final account = loginProvider.owner;
    if (account == null) return;
    final prefs = await SharedPreferences.getInstance();
    final photo = prefs.getString('owner_profile_photo_${account.gymId}');
    if (mounted) setState(() => _ownerPhotoPath = photo);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    _buttonShimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070609),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) {
                return CustomPaint(
                  painter: ProfileParticlePainter(_particleController.value),
                );
              },
            ),
          ),
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 280 + (_glowController.value * 30);
                return Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.16),
                          AppColors.primary.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Consumer<OwnerDashboardProvider>(
              builder: (context, dashProvider, _) {
                final owner = dashProvider.owner;
                final account = context.watch<OwnerLoginProvider>().owner;

                if (dashProvider.isLoading && owner == null) {
                  return const DashboardShimmer(
                    message: 'Loading owner profile...',
                  );
                }
                if (owner == null && dashProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Could not load your profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dashProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: dashProvider.fetchDashboard,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.roleSelectionRoute),
                            icon: const Icon(Icons.switch_account_rounded),
                            label: const Text('Back to role selection'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileCard(owner, _ownerPhotoPath),
                            const SizedBox(height: 18),
                            _buildPlanCard(account),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Owner Information'),
                            const SizedBox(height: 10),

                            DetailRow(
                              icon: Icons.person_outline_rounded,
                              title: 'Name',
                              value: owner?.name ?? 'N/A',
                            ),
                            DetailRow(
                              icon: Icons.fitness_center_rounded,
                              title: 'Gym Name',
                              value: owner?.gymName ?? 'N/A',
                            ),
                            DetailRow(
                              icon: Icons.mail_outline_rounded,
                              title: 'Email',
                              value: account?.email ?? 'N/A',
                            ),
                            DetailRow(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              value: account?.phone ?? 'N/A',
                            ),
                            DetailRow(
                              icon: Icons.badge_outlined,
                              title: 'Role',
                              value: 'Owner',
                            ),
                            DetailRow(
                              icon: Icons.verified_rounded,
                              title: 'Status',
                              value: 'Verified',
                              isStatus: true,
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Gym Stats'),
                            const SizedBox(height: 10),

                            DetailRow(
                              icon: Icons.people_alt_rounded,
                              title: 'Total Members',
                              value:
                                  '${dashProvider.summary?.totalMembers ?? 0}',
                            ),
                            DetailRow(
                              icon: Icons.fitness_center_rounded,
                              title: 'Total Trainers',
                              value:
                                  '${dashProvider.summary?.totalTrainers ?? 0}',
                            ),
                            DetailRow(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Total Revenue',
                              value:
                                  dashProvider.summary?.formattedRevenueFull ??
                                  '₹0',
                            ),

                            const SizedBox(height: 24),

                            _buildEditProfileButton(),
                            const SizedBox(height: 12),
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Row(
        children: [
          if (widget.onBack != null || context.canPop()) ...[
            CircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: widget.onBack ?? () => context.pop(),
            ),
            const SizedBox(width: 12),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.05,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your account, your gym, your progress',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(OwnerInfo? owner, String? photoPath) {
    final name = owner?.name ?? 'Owner';
    final initials = owner?.initials ?? '?';
    final gymName = owner?.gymName ?? 'Your Gym';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9AA9), Color(0xFFFF3158), Color(0xFF71152B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3158).withValues(alpha: .15),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 19, 20, 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF241018), Color(0xFF100D13), Color(0xFF0B0B10)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -58,
              right: -58,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF3158).withValues(alpha: .20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x22FF526F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0x55FF526F)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFFFF7187),
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'GYMORA OWNER',
                            style: TextStyle(
                              color: Color(0xFFFFA0AE),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFFFF7187),
                      size: 17,
                    ),
                  ],
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFA0AE),
                            Color(0xFFFF3158),
                            Color(0xFF7F142D),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF100D13),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child:
                              photoPath != null && File(photoPath).existsSync()
                              ? Image.file(File(photoPath), fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFF32121E),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const Icon(
                                Icons.fitness_center_rounded,
                                color: Color(0xFFFF7187),
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  gymName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF123024),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x5542DB82),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF55DB91),
                                  size: 12,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Verified account',
                                  style: TextStyle(
                                    color: Color(0xFF8DE6B2),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: .07),
                ),
                const SizedBox(height: 13),
                const Row(
                  children: [
                    Icon(
                      Icons.shield_moon_rounded,
                      color: Color(0xFFFF7187),
                      size: 14,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'GYM MANAGEMENT  /  CONTROL CENTER',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildPlanCard(dynamic account) {
    final plan = account?.plan?.toString() ?? '';
    final status = account?.membershipStatus?.toString() ?? '';
    final endRaw = account?.membershipEndDate?.toString() ?? '';
    final endDate = DateTime.tryParse(endRaw)?.toLocal();
    final today = DateTime.now();
    final daysLeft = endDate == null
        ? null
        : DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
          ).difference(DateTime(today.year, today.month, today.day)).inDays;
    final expired = daysLeft != null
        ? daysLeft < 0
        : status.toUpperCase() == 'EXPIRED';
    final tint = expired ? const Color(0xFFFF647C) : const Color(0xFFFF8A9D);
    final dateText = endDate == null
        ? 'Renewal date unavailable'
        : '${endDate.day.toString().padLeft(2, '0')} ${_month(endDate.month)} ${endDate.year}';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: .16), const Color(0xFF100D13)],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: tint.withValues(alpha: .26)),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: .07),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.workspace_premium_rounded, color: tint, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GYM MEMBERSHIP PLAN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.isEmpty ? 'Plan details' : plan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                daysLeft == null
                    ? '—'
                    : daysLeft < 0
                    ? '0'
                    : '$daysLeft',
                style: TextStyle(
                  color: tint,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                daysLeft == null ? 'DAYS' : 'DAYS LEFT',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  Widget _buildEditProfileButton() {
    return ShimmerButton(
      shimmerCtrl: _buttonShimmerController,
      gradientColors: const [Color(0xFFFF526F), Color(0xFFB91438)],
      accentColor: AppColors.ownerBright,
      height: 54,
      borderRadius: 16,
      onPressed: () async {
        await context.pushNamed('ownerEditProfile');
        if (mounted) await _loadOwnerProfile();
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded, color: Colors.white, size: 18),
          SizedBox(width: 9),
          Text(
            'Edit profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111722),
        title: const Text(
          'Log out of GYMORA?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your owner session will end on this device.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF647C),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      final ownerLoginProvider = context.read<OwnerLoginProvider>();
      final dashboardProvider = context.read<OwnerDashboardProvider>();
      final memberProvider = context.read<OwnerMemberProvider>();
      final trainerProvider = context.read<OwnerTrainerProvider>();

      await ownerLoginProvider.logout();
      dashboardProvider.reset();
      memberProvider.reset();
      trainerProvider.reset();

      if (!mounted) return;
      context.goNamed('role-selection');
    } catch (error) {
      debugPrint('OWNER_LOGOUT_ERROR: ${error.runtimeType}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not log out. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _confirmLogout,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded, size: 18),
        label: Text(_isLoggingOut ? 'Logging out...' : 'Log out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF647C),
          side: BorderSide(
            color: const Color(0xFFFF647C).withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
