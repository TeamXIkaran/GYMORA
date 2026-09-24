import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:gymora_fitness_management/feature/owner/screens/member_ship_screen.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';

import 'package:gymora_fitness_management/feature/owner/screens/owner_members_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_trainers_screen.dart';
import 'package:gymora_fitness_management/feature/owner/screens/owner_profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DashboardProvider>().fetchDashboard();
      context.read<MemberProvider>().ensureLoaded();
      context.read<TrainerProvider>().ensureLoaded();
    });
  }

  void _goHome() => setState(() => _currentIndex = 0);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const _HomeTab(),
      OwnerMembersScreen(onBack: _goHome),
      OwnerTrainersScreen(onBack: _goHome),
      MembershipScreen(onBack: _goHome),
      OwnerProfileScreen(onBack: _goHome),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF03060B),
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ============================================================
  // PREMIUM BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070A10),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.people_alt_rounded, 'Members', 1),
              _navItem(Icons.fitness_center_rounded, 'Trainers', 2),
              _navItem(Icons.card_membership_rounded, 'Plans', 3),
              _navItem(Icons.person_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.20),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.18))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 22,
                height: 2.5,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

            Icon(
              icon,
              color: selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.30),
              size: 21,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.30),
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: Stack(
          children: [
            // Background glow 1
            Positioned(
              top: -90,
              right: -80,
              child: _backgroundGlow(const Color(0xFFE62B52), 230),
            ),

            // Background glow 2
            Positioned(
              top: 380,
              left: -130,
              child: _backgroundGlow(const Color(0xFF154CFF), 250),
            ),

            Consumer<DashboardProvider>(
              builder: (context, dashProvider, _) {
                if (dashProvider.isLoading && dashProvider.dashboard == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (dashProvider.error != null &&
                    dashProvider.dashboard == null) {
                  return _buildErrorState(context, dashProvider);
                }

                final dashboard = dashProvider.dashboard;

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: const Color(0xFF0A0D14),
                  onRefresh: () => dashProvider.fetchDashboard(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(17, 17, 17, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(context, dashboard),

                        const SizedBox(height: 22),

                        _buildStatsRow(dashboard),

                        const SizedBox(height: 22),

                        _buildRevenueCard(dashboard),

                        const SizedBox(height: 25),

                        _buildQuickActions(context),

                        const SizedBox(height: 27),

                        _buildRecentMembers(dashboard),

                        const SizedBox(height: 27),

                        _buildTrainerOverview(dashboard),
                      ],
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

  Widget _backgroundGlow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.055),
              blurRadius: 110,
              spreadRadius: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DashboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.20),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.20),
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => provider.fetchDashboard(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting(BuildContext context, DashboardModel? dashboard) {
    final ownerName = dashboard?.owner.name ?? 'Owner';
    final gymName = dashboard?.owner.gymName ?? 'Your Gym';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 9),

                  Flexible(
                    child: Text(
                      'Hello, $ownerName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF42DB82),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 7),

                  Flexible(
                    child: Text(
                      gymName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 7),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF42DB82).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Color(0xFF42DB82),
                        fontSize: 6.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        GestureDetector(
          onTap: () => context.pushNamed('onwerNotificationScreen'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.025),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),

                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF080B12),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsRow(DashboardModel? dashboard) {
    final summary = dashboard?.summary;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_rounded,
            value: '${summary?.totalMembers ?? 0}',
            label: 'MEMBERS',
            color: const Color(0xFF54B8FF),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _statCard(
            icon: Icons.fitness_center_rounded,
            value: '${summary?.totalTrainers ?? 0}',
            label: 'TRAINERS',
            color: const Color(0xFFFF8A00),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _statCard(
            icon: Icons.currency_rupee_rounded,
            value: summary?.formattedRevenue ?? '₹0',
            label: 'REVENUE',
            color: const Color(0xFF42DB82),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 11, 10, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.055),
            Colors.white.withValues(alpha: 0.018),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.035),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: color.withValues(alpha: 0.12)),
                ),
                child: Icon(icon, color: color, size: 16),
              ),

              const Spacer(),

              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVENUE
  // ============================================================

  Widget _buildRevenueCard(DashboardModel? dashboard) {
    final revenue = dashboard?.revenueOverview;

    final previous = revenue?.previousMonthRevenue ?? 0;
    final current = revenue?.currentMonthRevenue ?? 0;

    final hasComparison = revenue?.hasComparison ?? false;

    final change = revenue?.percentageChange ?? 0;

    final isPositive = change >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            const Color(0xFF0C111A),
            const Color(0xFF080C13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.20),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Monthly performance',
                      style: TextStyle(color: Colors.white30, fontSize: 9),
                    ),
                  ],
                ),
              ),

              if (!hasComparison)
                _revenueBadge(
                  text: 'First month',
                  color: const Color(0xFF54B8FF),
                  icon: Icons.insights_rounded,
                )
              else
                _revenueBadge(
                  text: '${change.abs().toStringAsFixed(1)}%',
                  color: isPositive
                      ? const Color(0xFF42DB82)
                      : const Color(0xFFFF536F),
                  icon: isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Current revenue highlight
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT MONTH',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRevenue(current),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ],
                ),
              ),

              if (hasComparison)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF42DB82).withValues(alpha: 0.08)
                        : const Color(0xFFFF536F).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 11,
                        color: isPositive
                            ? const Color(0xFF42DB82)
                            : const Color(0xFFFF536F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPositive
                              ? const Color(0xFF42DB82)
                              : const Color(0xFFFF536F),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 145,
            width: double.infinity,
            child: CustomPaint(
              painter: _RevenueChartPainter(
                previousValue: previous,
                currentValue: current,
                lineColor: AppColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _graphLabel(
                title: 'Previous',
                value: _formatRevenue(previous),
                active: false,
              ),
              _graphLabel(
                title: 'Current',
                value: _formatRevenue(current),
                active: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRevenue(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    }

    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }

    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _revenueBadge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphLabel({
    required String title,
    required String value,
    required bool active,
  }) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white24,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: TextStyle(
            color: active ? Colors.white54 : Colors.white24,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          value,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Quick Actions',
          subtitle: 'Manage your gym faster',
          icon: Icons.bolt_rounded,
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Add Member',
                subtitle: 'Create new member',
                color: const Color(0xFF54B8FF),
                onTap: () => context.pushNamed('addMember'),
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: _actionCard(
                icon: Icons.fitness_center_rounded,
                title: 'Add Trainer',
                subtitle: 'Create new trainer',
                color: const Color(0xFFFF8A00),
                onTap: () => context.pushNamed('addTrainer'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 15),
          ),
          const SizedBox(width: 10),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white30, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.095), const Color(0xFF0A0F17)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.045),
              blurRadius: 24,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 19),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white30, fontSize: 8),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded, color: color, size: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECENT MEMBERS
  // ============================================================

  Widget _buildRecentMembers(DashboardModel? dashboard) {
    final recentMembers = dashboard?.recentMembers ?? const <RecentMember>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Recent Members',
          subtitle: 'Latest members in your gym',
          icon: Icons.people_alt_rounded,
        ),

        const SizedBox(height: 13),

        if (recentMembers.isEmpty)
          _emptyCard('No recent members')
        else
          ...recentMembers.map((member) => _recentMemberTile(member)),
      ],
    );
  }

  Widget _recentMemberTile(RecentMember member) {
    final statusColor = _memberStatusColor(member.displayStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.045),
            Colors.white.withValues(alpha: 0.012),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE62B52), Color(0xFF701529)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.planDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: statusColor.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  member.displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.035),
            Colors.white.withValues(alpha: 0.012),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: Colors.white24,
              size: 24,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _memberStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF42DB82);

      case 'EXPIRING':
        return const Color(0xFFFFB84D);

      default:
        return const Color(0xFFFF536F);
    }
  }

  // ============================================================
  // TRAINER OVERVIEW
  // ============================================================

  Widget _buildTrainerOverview(DashboardModel? dashboard) {
    final trainers =
        dashboard?.trainerOverview ?? const <TrainerOverviewItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Trainer Overview',
          subtitle: 'Your gym training team',
          icon: Icons.fitness_center_rounded,
        ),

        const SizedBox(height: 13),

        if (trainers.isEmpty)
          _emptyCard('No trainers yet')
        else
          ...trainers.map((trainer) => _trainerOverviewTile(trainer)),
      ],
    );
  }

  Widget _trainerOverviewTile(TrainerOverviewItem trainer) {
    final activeColor = const Color(0xFFFF8A00);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activeColor.withValues(alpha: 0.045),
            Colors.white.withValues(alpha: 0.012),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  activeColor.withValues(alpha: 0.18),
                  activeColor.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: activeColor.withValues(alpha: 0.18)),
            ),
            child: Center(
              child: Text(
                trainer.initials,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white30,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trainer.specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: trainer.isActive
                  ? const Color(0xFF42DB82).withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(9),
              border: trainer.isActive
                  ? Border.all(
                      color: const Color(0xFF42DB82).withValues(alpha: 0.10),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: trainer.isActive
                        ? const Color(0xFF42DB82)
                        : Colors.white30,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  trainer.status,
                  style: TextStyle(
                    color: trainer.isActive
                        ? const Color(0xFF42DB82)
                        : Colors.white38,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
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

// ============================================================
// PREMIUM REVENUE GRAPH
// Uses ONLY existing previous/current revenue values.
// ============================================================

class _RevenueChartPainter extends CustomPainter {
  final double previousValue;
  final double currentValue;
  final Color lineColor;

  _RevenueChartPainter({
    required this.previousValue,
    required this.currentValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartTop = 18.0;
    final chartBottom = size.height - 18;
    final chartHeight = chartBottom - chartTop;

    // ----------------------------------------------------------
    // GRID
    // ----------------------------------------------------------

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.045);

    for (int i = 0; i < 4; i++) {
      final y = chartTop + (chartHeight / 3) * i;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ----------------------------------------------------------
    // VALUES
    // ----------------------------------------------------------

    final maxValue = previousValue > currentValue
        ? previousValue
        : currentValue;

    double normalize(double value) {
      if (maxValue <= 0) {
        return 0.45;
      }

      return value / maxValue;
    }

    final previousX = 18.0;
    final currentX = size.width - 18;

    final previousY =
        chartTop + chartHeight - normalize(previousValue) * chartHeight;

    final currentY =
        chartTop + chartHeight - normalize(currentValue) * chartHeight;

    // ----------------------------------------------------------
    // CURVE
    // ----------------------------------------------------------

    final path = Path();

    path.moveTo(previousX, previousY);

    final controlPoint1 = Offset(size.width * 0.30, previousY);

    final controlPoint2 = Offset(size.width * 0.70, currentY);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      currentX,
      currentY,
    );

    // ----------------------------------------------------------
    // AREA FILL
    // ----------------------------------------------------------

    final fillPath = Path.from(path)
      ..lineTo(currentX, chartBottom)
      ..lineTo(previousX, chartBottom)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.16),
          lineColor.withValues(alpha: 0.00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // ----------------------------------------------------------
    // GLOW
    // ----------------------------------------------------------

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor.withValues(alpha: 0.065)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawPath(path, glowPaint);

    // ----------------------------------------------------------
    // MAIN LINE
    // ----------------------------------------------------------

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas.drawPath(path, linePaint);

    // ----------------------------------------------------------
    // POINTS
    // ----------------------------------------------------------

    _drawPoint(
      canvas,
      Offset(previousX, previousY),
      lineColor.withValues(alpha: 0.45),
      5,
    );

    _drawPoint(canvas, Offset(currentX, currentY), lineColor, 6);
  }

  void _drawPoint(Canvas canvas, Offset point, Color color, double radius) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(point, radius + 5, glowPaint);

    final outerPaint = Paint()..color = const Color(0xFF0B1018);

    canvas.drawCircle(point, radius + 2, outerPaint);

    final pointPaint = Paint()..color = color;

    canvas.drawCircle(point, radius, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.previousValue != previousValue ||
        oldDelegate.currentValue != currentValue ||
        oldDelegate.lineColor != lineColor;
  }
}
