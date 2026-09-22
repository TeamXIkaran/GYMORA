import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
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
    // Load everything once here. Tabs call ensureLoaded(), which is a no-op
    // when data is already present, so nothing is fetched twice.
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
    // Tabs get an onBack that switches to Home instead of pushing a
    // new dashboard route on top of this one.
    final screens = <Widget>[
      const _HomeTab(),
      OwnerMembersScreen(onBack: _goHome),
      OwnerTrainersScreen(onBack: _goHome),
      MembershipScreen(onBack: _goHome),
      OwnerProfileScreen(onBack: _goHome),
    ];

    return PopScope(
      // System back on a non-Home tab → go to Home first
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) _goHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF05070C),
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D14),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : Colors.white30,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white30,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME TAB — Uses DashboardProvider
// ============================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, dashProvider, _) {
            if (dashProvider.isLoading && dashProvider.dashboard == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (dashProvider.error != null && dashProvider.dashboard == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dashProvider.error!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => dashProvider.fetchDashboard(),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context, dashboard),
                    const SizedBox(height: 24),

                    _buildStatsRow(dashboard),
                    const SizedBox(height: 24),

                    _buildRevenueCard(dashboard),
                    const SizedBox(height: 24),

                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    _buildRecentMembers(dashboard),
                    const SizedBox(height: 24),

                    _buildTrainerOverview(dashboard),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, DashboardModel? dashboard) {
    final ownerName = dashboard?.owner.name ?? 'Owner';
    final gymName = dashboard?.owner.gymName ?? 'Your Gym';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $ownerName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                gymName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          // ⚠ Must match the `name:` in your GoRouter config exactly
          onTap: () => context.pushNamed('onwerNotificationScreen'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(DashboardModel? dashboard) {
    final summary = dashboard?.summary;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_rounded,
            value: '${summary?.totalMembers ?? 0}',
            label: 'Members',
            color: const Color(0xFF54B8FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.fitness_center_rounded,
            value: '${summary?.totalTrainers ?? 0}',
            label: 'Trainers',
            color: const Color(0xFFFF8A00),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.currency_rupee_rounded,
            value: summary?.formattedRevenue ?? '₹0',
            label: 'Revenue',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(DashboardModel? dashboard) {
    final revenue = dashboard?.revenueOverview;
    final hasComparison = revenue?.hasComparison ?? false;
    final change = revenue?.percentageChange ?? 0;
    final isPositive = change >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Month',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupees(revenue?.currentMonthRevenue ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // No previous-month revenue → a % change is meaningless
              if (!hasComparison)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF54B8FF).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'First month',
                    style: TextStyle(
                      color: Color(0xFF54B8FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF42DB82).withValues(alpha: 0.10)
                        : const Color(0xFFFF536F).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: isPositive
                            ? const Color(0xFF42DB82)
                            : const Color(0xFFFF536F),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPositive
                              ? const Color(0xFF42DB82)
                              : const Color(0xFFFF536F),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Add Member',
                color: const Color(0xFF54B8FF),
                onTap: () => context.pushNamed('addMember'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.fitness_center_rounded,
                title: 'Add Trainer',
                color: const Color(0xFFFF8A00),
                onTap: () => context.pushNamed('addTrainer'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMembers(DashboardModel? dashboard) {
    final recentMembers = dashboard?.recentMembers ?? const <RecentMember>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Members',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (recentMembers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: const Center(
              child: Text(
                'No recent members',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          )
        else
          ...recentMembers.map((member) => _recentMemberTile(member)),
      ],
    );
  }

  Widget _recentMemberTile(RecentMember member) {
    final statusColor = _memberStatusColor(member.displayStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE62B52), Color(0xFF761326)],
              ),
            ),
            child: Center(
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  member.planDisplayName,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.displayStatus,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
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

  Widget _buildTrainerOverview(DashboardModel? dashboard) {
    final trainers =
        dashboard?.trainerOverview ?? const <TrainerOverviewItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trainer Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (trainers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: const Center(
              child: Text(
                'No trainers yet',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          )
        else
          ...trainers.map((trainer) => _trainerOverviewTile(trainer)),
      ],
    );
  }

  Widget _trainerOverviewTile(TrainerOverviewItem trainer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8A00).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.20),
              ),
            ),
            child: Center(
              child: Text(
                trainer.initials,
                style: const TextStyle(
                  color: Color(0xFFFF8A00),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  trainer.specialization,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trainer.isActive
                  ? const Color(0xFF42DB82).withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trainer.status,
              style: TextStyle(
                color: trainer.isActive
                    ? const Color(0xFF42DB82)
                    : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
