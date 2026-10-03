import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
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
    debugPrint('OWNER_DASHBOARD: screen initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      debugPrint('OWNER_DASHBOARD: loading dashboard data');
      context.read<OwnerDashboardProvider>().fetchDashboard();
      context.read<OwnerMemberProvider>().ensureLoaded();
      context.read<OwnerTrainerProvider>().ensureLoaded();
    });
  }

  void _goHome() => setState(() => _currentIndex = 0);

  void _selectTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _HomeTab(onSelectTab: _selectTab),
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
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ============================================================
  // PREMIUM BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    final radius = BorderRadius.circular(28);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .42),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF101722).withValues(alpha: .92),
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: Row(
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
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _currentIndex == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: selected ? 48 : 40,
                height: 31,
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: .24),
                            AppColors.primary.withValues(alpha: .10),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(15),
                  border: selected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: .30),
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.primary : Colors.white54,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

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

            Consumer<OwnerDashboardProvider>(
              builder: (context, dashProvider, _) {
                if (dashProvider.isLoading && dashProvider.dashboard == null) {
                  return const DashboardShimmer(
                    message: 'Loading owner dashboard...',
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

                        _buildStatsRow(
                          dashboard,
                          context
                              .watch<OwnerMemberProvider>()
                              .activeMembers
                              .map((member) => member.membershipPlan)
                              .where((plan) => plan.trim().isNotEmpty)
                              .toSet()
                              .length,
                        ),

                        const SizedBox(height: 22),

                        _buildRevenueCard(dashboard),

                        const SizedBox(height: 25),

                        _buildQuickActions(context, onSelectTab),

                        const SizedBox(height: 27),

                        _buildCommunityOverview(dashboard, onSelectTab),
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

  Widget _buildErrorState(
    BuildContext context,
    OwnerDashboardProvider provider,
  ) {
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
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.roleSelectionRoute),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              icon: const Icon(Icons.switch_account_rounded),
              label: const Text('Back to role selection'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting(BuildContext context, OwnerDashboardModel? dashboard) {
    final ownerName = dashboard?.owner.name ?? 'Owner';
    final gymName = dashboard?.owner.gymName ?? 'Your Gym';

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: .22),
            const Color(0xFF11131D),
            const Color(0xFF090D15),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: .32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .10),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -16,
            child: Transform.rotate(
              angle: -.32,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 132,
                color: AppColors.primary.withValues(alpha: .08),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GYM OWNER',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Hello, ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.8,
                        ),
                        children: [
                          TextSpan(
                            text: ownerName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Manage your gym. Grow your business.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _headerPill(
                          icon: Icons.location_on_rounded,
                          text: gymName,
                        ),
                        _headerPill(
                          icon: Icons.circle,
                          text: 'Owner',
                          accent: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.white.withValues(alpha: .07),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.pushNamed('onwerNotificationScreen'),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                        Positioned(
                          top: 7,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerPill({
    required IconData icon,
    required String text,
    Color accent = Colors.white70,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsRow(OwnerDashboardModel? dashboard, int activePlanTypes) {
    final summary = dashboard?.summary;
    final cards = [
      _statCard(
        icon: Icons.people_alt_rounded,
        value: '${summary?.totalMembers ?? 0}',
        label: 'MEMBERS',
        graphValue: (summary?.totalMembers ?? 0).toDouble(),
        color: const Color(0xFF54B8FF),
      ),
      _statCard(
        icon: Icons.fitness_center_rounded,
        value: '${summary?.totalTrainers ?? 0}',
        label: 'TRAINERS',
        graphValue: (summary?.totalTrainers ?? 0).toDouble(),
        color: const Color(0xFFFF8A3D),
      ),
      _statCard(
        icon: Icons.currency_rupee_rounded,
        value: summary?.formattedRevenue ?? '₹0',
        label: 'REVENUE',
        graphValue: (summary?.totalRevenue ?? 0) / 10000,
        color: AppColors.primary,
      ),
      _statCard(
        icon: Icons.card_membership_rounded,
        value: '$activePlanTypes',
        label: 'ACTIVE PLAN TYPES',
        graphValue: activePlanTypes.toDouble(),
        color: const Color(0xFFC14CFF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required double graphValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.055),
            Colors.white.withValues(alpha: 0.018),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.30)),
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
                width: 40,
                height: 40,
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
              fontSize: 20,
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          _MetricBars(value: graphValue, color: color),
        ],
      ),
    );
  }

  // ============================================================
  // REVENUE
  // ============================================================

  Widget _buildRevenueCard(OwnerDashboardModel? dashboard) {
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
                      style: TextStyle(color: Colors.white54, fontSize: 12),
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
                        fontSize: 9,
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
                          fontSize: 11,
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
              fontSize: 11,
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
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          value,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
    BuildContext context,
    ValueChanged<int> onSelectTab,
  ) {
    final actions = [
      _actionCard(
        icon: Icons.person_add_alt_1_rounded,
        title: 'Add Member',
        subtitle: 'Register a member',
        color: const Color(0xFF54B8FF),
        onTap: () => context.pushNamed('addMember'),
      ),
      _actionCard(
        icon: Icons.fitness_center_rounded,
        title: 'Add Trainer',
        subtitle: 'Grow your team',
        color: const Color(0xFFFF8A3D),
        onTap: () => context.pushNamed('addTrainer'),
      ),
      _actionCard(
        icon: Icons.card_membership_rounded,
        title: 'Memberships',
        subtitle: 'Manage plans',
        color: const Color(0xFFC14CFF),
        onTap: () => onSelectTab(3),
      ),
      _actionCard(
        icon: Icons.storefront_rounded,
        title: 'Gym Profile',
        subtitle: 'View gym details',
        color: const Color(0xFFFF3F70),
        onTap: () => onSelectTab(4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Quick Actions',
          subtitle: 'Manage your gym faster',
          icon: Icons.bolt_rounded,
          actionLabel: 'View all',
          onAction: () => onSelectTab(1),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final action in actions)
                  SizedBox(width: width, child: action),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    IconData? icon,
    Color accent = AppColors.primary,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: accent, size: 15),
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
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          height: 148,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: .17),
                const Color(0xFF0B1019),
                const Color(0xFF090D14),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: .35)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: .28)),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ============================================================
  // RECENT MEMBERS
  // ============================================================

  Widget _buildCommunityOverview(
    OwnerDashboardModel? dashboard,
    ValueChanged<int> onSelectTab,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final members = _buildRecentMembers(dashboard, onSelectTab);
        final trainers = _buildTrainerOverview(dashboard, onSelectTab);
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: members),
              const SizedBox(width: 16),
              Expanded(child: trainers),
            ],
          );
        }
        return Column(
          children: [members, const SizedBox(height: 24), trainers],
        );
      },
    );
  }

  Widget _buildRecentMembers(
    OwnerDashboardModel? dashboard,
    ValueChanged<int> onSelectTab,
  ) {
    final recentMembers = dashboard?.recentMembers ?? const <RecentMember>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Recent Members',
          subtitle: 'Latest members in your gym',
          icon: Icons.people_alt_rounded,
          accent: const Color(0xFF54B8FF),
          actionLabel: 'View all',
          onAction: () => onSelectTab(1),
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
                colors: [Color(0xFF54B8FF), Color(0xFF145A91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF54B8FF).withValues(alpha: 0.22),
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
                          fontSize: 10,
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
                    fontSize: 9,
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

  Widget _buildTrainerOverview(
    OwnerDashboardModel? dashboard,
    ValueChanged<int> onSelectTab,
  ) {
    final trainers =
        dashboard?.trainerOverview ?? const <TrainerOverviewItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Top Trainers',
          subtitle: 'Your gym training team',
          icon: Icons.fitness_center_rounded,
          actionLabel: 'View all',
          onAction: () => onSelectTab(2),
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

class _MetricBars extends StatelessWidget {
  const _MetricBars({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final magnitude = (value / (value + 100)).clamp(0.0, 1.0);
    final filled = value <= 0 ? 0 : (2 + magnitude * 6).round();
    const heights = [7.0, 11.0, 8.0, 15.0, 10.0, 18.0, 12.0, 22.0];

    return SizedBox(
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 220 + i * 35),
                height: heights[i],
                decoration: BoxDecoration(
                  color: i < filled
                      ? color.withValues(alpha: .88)
                      : color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: i < filled
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: .28),
                            blurRadius: 7,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
