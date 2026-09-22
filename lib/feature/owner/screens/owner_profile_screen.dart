import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:provider/provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DashboardProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
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
            child: Consumer<DashboardProvider>(
              builder: (context, dashProvider, _) {
                final owner = dashProvider.owner;

                if (dashProvider.isLoading && owner == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
                            _buildProfileCard(owner),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your account details',
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

  Widget _buildProfileCard(OwnerInfo? owner) {
    final name = owner?.name ?? 'Owner';
    final initials = owner?.initials ?? '?';
    final gymName = owner?.gymName ?? 'Your Gym';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 25,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE62B52), Color(0xFF761326)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 22,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Owner • $gymName',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF42DB82).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF42DB82).withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF42DB82),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified Owner',
                  style: TextStyle(
                    color: Color(0xFF42DB82),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF151923),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: const Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Edit Profile screen can be connected here.',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                SizedBox(width: 9),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
