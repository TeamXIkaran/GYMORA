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
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080B12),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.18))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 38 : 30,
              height: selected ? 3 : 0,
              margin: EdgeInsets.only(bottom: selected ? 6 : 0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            Icon(
              icon,
              color: selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.32),
              size: 21,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.32),
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
// HOME TAB
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
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      dashProvider.error!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => dashProvider.fetchDashboard(),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context, dashboard),
                    const SizedBox(height: 25),

                    _buildStatsRow(dashboard),
                    const SizedBox(height: 25),

                    _buildRevenueCard(dashboard),
                    const SizedBox(height: 25),

                    _buildQuickActions(context),
                    const SizedBox(height: 25),

                    _buildRecentMembers(dashboard),
                    const SizedBox(height: 25),

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
              Text(
                'Hello, $ownerName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
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
                  Text(
                    gymName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () => context.pushNamed('onwerNotificationScreen'),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
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
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 6,
                    height: 6,
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
      padding: const EdgeInsets.fromLTRB(13, 13, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.36),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVENUE OVERVIEW — UI ONLY
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.13),
            const Color(0xFF0B1018),
            const Color(0xFF080C13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.055),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
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
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              ),

              // Existing percentage data
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

          const SizedBox(height: 22),

          // Graph
          SizedBox(
            height: 155,
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

          const SizedBox(height: 10),

          // Graph labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _graphLabel(title: 'Previous Month', active: false),
              _graphLabel(title: 'Current Month', active: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueBadge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphLabel({required String title, required bool active}) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white24,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: active ? Colors.white70 : Colors.white30,
            fontSize: 9,
            fontWeight: FontWeight.w600,
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
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Add Member',
                subtitle: 'New member',
                color: const Color(0xFF54B8FF),
                onTap: () => context.pushNamed('addMember'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.fitness_center_rounded,
                title: 'Add Trainer',
                subtitle: 'New trainer',
                color: const Color(0xFFFF8A00),
                onTap: () => context.pushNamed('addTrainer'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.30),
            fontSize: 9,
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1018),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.035),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withValues(alpha: 0.12)),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.65),
              size: 11,
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
        ),
        const SizedBox(height: 12),

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE62B52), Color(0xFF75142A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.planDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(8),
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
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: Colors.white.withValues(alpha: 0.18),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
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
        ),
        const SizedBox(height: 12),

        if (trainers.isEmpty)
          _emptyCard('No trainers yet')
        else
          ...trainers.map((trainer) => _trainerOverviewTile(trainer)),
      ],
    );
  }

  Widget _trainerOverviewTile(TrainerOverviewItem trainer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8A00).withValues(alpha: 0.10),
              border: Border.all(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.18),
              ),
            ),
            child: Center(
              child: Text(
                trainer.initials,
                style: const TextStyle(
                  color: Color(0xFFFF8A00),
                  fontSize: 12,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trainer.specialization,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: trainer.isActive
                  ? const Color(0xFF42DB82).withValues(alpha: 0.09)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
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
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
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
// REVENUE GRAPH PAINTER
// UI ONLY — uses existing dashboard revenue values
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
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.055);

    // Horizontal grid lines.
    for (int i = 0; i < 4; i++) {
      final y = 15 + (i * (size.height - 30) / 3);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final maxValue = previousValue > currentValue
        ? previousValue
        : currentValue;

    double normalize(double value) {
      if (maxValue <= 0) return 0.5;
      return value / maxValue;
    }

    final previousX = 18.0;
    final currentX = size.width - 18;

    final chartHeight = size.height - 38;

    final previousY =
        18 + chartHeight - (normalize(previousValue) * chartHeight);

    final currentY = 18 + chartHeight - (normalize(currentValue) * chartHeight);

    final path = Path();

    path.moveTo(previousX, previousY);

    final controlPoint1 = Offset(size.width * 0.32, previousY);

    final controlPoint2 = Offset(size.width * 0.68, currentY);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      currentX,
      currentY,
    );

    // Glow.
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = lineColor.withValues(alpha: 0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawPath(path, glowPaint);

    // Main line.
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas.drawPath(path, linePaint);

    // Bottom soft area.
    final fillPath = Path.from(path)
      ..lineTo(currentX, size.height)
      ..lineTo(previousX, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.13),
          lineColor.withValues(alpha: 0.00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Previous point.
    _drawPoint(
      canvas,
      Offset(previousX, previousY),
      lineColor.withValues(alpha: 0.45),
      5,
    );

    // Current point.
    _drawPoint(canvas, Offset(currentX, currentY), lineColor, 6);
  }

  void _drawPoint(Canvas canvas, Offset point, Color color, double radius) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawCircle(point, radius + 4, glowPaint);

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
