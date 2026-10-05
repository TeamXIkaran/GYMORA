import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class OwnerMembersScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const OwnerMembersScreen({super.key, this.onBack});

  @override
  State<OwnerMembersScreen> createState() => _OwnerMembersScreenState();
}

class _OwnerMembersScreenState extends State<OwnerMembersScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _buttonShimmerController;

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
      if (mounted) {
        context.read<OwnerMemberProvider>().ensureLoaded();
        context.read<OwnerTrainerProvider>().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    _buttonShimmerController.dispose();
    super.dispose();
  }

  List<OwnerMemberModel> _getFilteredMembers(OwnerMemberProvider provider) {
    List<OwnerMemberModel> result;

    switch (_selectedFilter) {
      case 1:
        result = provider.activeMembers;
        break;
      case 2:
        result = provider.expiringMembers;
        break;
      case 3:
        result = provider.expiredMembers;
        break;
      default:
        result = provider.members;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();

      result = result.where((m) {
        return m.fullName.toLowerCase().contains(q) ||
            m.email.toLowerCase().contains(q) ||
            m.phone.contains(q) ||
            m.planDisplayName.toLowerCase().contains(q);
      }).toList();
    }

    return result;
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

          // Top glow
          Positioned(
            top: -100,
            right: -70,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 260 + (_glowController.value * 35);

                return Container(
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
                );
              },
            ),
          ),

          // Bottom glow
          Positioned(
            bottom: -130,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ownerBright.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildOverview(),
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildMemberList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.ownerPrimary.withValues(alpha: .18),
                  const Color(0xFF0D1726),
                  const Color(0xFF080D17),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF632338)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ownerBright.withValues(alpha: .08),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  top: -25,
                  child: Transform.rotate(
                    angle: -.35,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 118,
                      color: AppColors.ownerBright.withValues(alpha: .08),
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (widget.onBack != null || context.canPop()) ...[
                      CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: widget.onBack ?? () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GYM MANAGEMENT',
                            style: TextStyle(
                              color: AppColors.ownerBright,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Members',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.members.length} members · Manage profiles and plans',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShimmerButton(
                      shimmerCtrl: _buttonShimmerController,
                      gradientColors: const [
                        Color(0xFFFF3158),
                        Color(0xFFB91438),
                      ],
                      accentColor: AppColors.ownerBright,
                      width: 82,
                      height: 46,
                      borderRadius: 16,
                      onPressed: () => context.pushNamed('addMember'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverview() {
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 13),
          child: Row(
            children: [
              Expanded(
                child: _overviewCard(
                  icon: Icons.groups_rounded,
                  value: '${provider.members.length}',
                  label: 'TOTAL',
                  color: const Color(0xFFFF3158),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewCard(
                  icon: Icons.verified_rounded,
                  value: '${provider.activeMembers.length}',
                  label: 'ACTIVE',
                  color: const Color(0xFFE62B52),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewCard(
                  icon: Icons.event_busy_rounded,
                  value: '${provider.expiringMembers.length}',
                  label: 'EXPIRING SOON',
                  color: const Color(0xFFB91438),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              color.withValues(alpha: .13),
              const Color(0xFF21121B),
            ),
            const Color(0xFF160D14),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color.withValues(alpha: .045), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: .24),
                      color.withValues(alpha: .08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: .18)),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9.5,
              height: 1.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.55,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.055),
              Colors.white.withValues(alpha: 0.025),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF632338)),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search name, phone, email or plan...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : const Icon(
                    Icons.tune_rounded,
                    color: Colors.white30,
                    size: 18,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    final filters = ['All', 'Active', 'Expiring', 'Expired'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 10),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 7,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.20),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // MEMBER LIST
  // ============================================================

  Widget _buildMemberList() {
    return Consumer2<OwnerMemberProvider, OwnerTrainerProvider>(
      builder: (context, provider, trainerProvider, _) {
        if (provider.isLoading && provider.members.isEmpty) {
          return const DashboardShimmer(message: 'Loading members...');
        }

        if (provider.error != null && provider.members.isEmpty) {
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
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => provider.fetchMembers(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.roleSelectionRoute),
                  icon: const Icon(Icons.switch_account_rounded),
                  label: const Text('Back to role selection'),
                ),
              ],
            ),
          );
        }

        final members = _getFilteredMembers(provider);

        if (members.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: const Color(0xFF0A0D14),
          onRefresh: () => provider.fetchMembers(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildMemberCard(member, trainerProvider.trainers),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // MEMBER CARD
  // ============================================================

  Widget _buildMemberCard(
    OwnerMemberModel member,
    List<OwnerTrainerModel> trainers,
  ) {
    final status = member.displayStatus;
    final statusColor = _statusColor(status);
    final trainerName = _assignedTrainerName(member, trainers);

    return GestureDetector(
      onTap: () => _showMemberDetails(member, trainerName),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor.withValues(alpha: 0.045),
                  Colors.white.withValues(alpha: 0.018),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: statusColor.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.045),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF54B8FF), Color(0xFF145A91)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF54B8FF).withValues(alpha: 0.24),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Main info
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.card_membership_rounded,
                            color: AppColors.ownerBright,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              member.planDisplayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.ownerBright,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trainerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: Colors.white24,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              member.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white30,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white24,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Joined ${member.startDate}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white30,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status + arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.20),
                        ),
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
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white24,
                      size: 12,
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF42DB82);

      case 'expired':
        return const Color(0xFFFF536F);

      case 'expiring':
        return const Color(0xFFFFB84D);

      default:
        return Colors.white54;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_search_rounded,
                color: AppColors.primary.withValues(alpha: 0.75),
                size: 36,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Members Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBER DETAILS
  // ============================================================

  void _showMemberDetails(OwnerMemberModel member, String trainerName) {
    final statusColor = _statusColor(member.displayStatus);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Avatar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF54B8FF), Color(0xFF145A91)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF54B8FF,
                          ).withValues(alpha: 0.30),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  Text(
                    member.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    member.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),

                  const SizedBox(height: 12),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          member.displayStatus.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Membership information
                  _detailSectionTitle('MEMBERSHIP'),

                  const SizedBox(height: 8),

                  DetailRow(
                    icon: Icons.card_membership_rounded,
                    title: 'Plan',
                    value: member.planDisplayName,
                  ),

                  DetailRow(
                    icon: Icons.fitness_center_rounded,
                    title: 'Assigned Trainer',
                    value: trainerName,
                  ),

                  DetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Start Date',
                    value: member.startDate,
                  ),

                  DetailRow(
                    icon: Icons.event_outlined,
                    title: 'End Date',
                    value: member.endDate,
                  ),

                  DetailRow(
                    icon: Icons.circle,
                    title: 'Status',
                    value: member.displayStatus,
                    isStatus: member.isActive,
                  ),

                  const SizedBox(height: 12),

                  _detailSectionTitle('CONTACT'),

                  const SizedBox(height: 8),

                  DetailRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: member.email,
                  ),

                  DetailRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    value: member.phone,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmDeleteMember(sheetContext, member),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete member'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF647C),
                        side: BorderSide(
                          color: const Color(0xFFFF647C).withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteMember(
    BuildContext sheetContext,
    OwnerMemberModel member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111722),
        title: const Text(
          'Delete member?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This permanently removes ${member.fullName} and their membership.',
          style: const TextStyle(color: Colors.white70),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<OwnerMemberProvider>();
    final deleted = await provider.deleteMember(
      member.clientId.isNotEmpty ? member.clientId : member.id,
    );
    if (!mounted) return;

    if (deleted) {
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      context.read<OwnerDashboardProvider>().fetchDashboard();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.fullName} was deleted.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not delete member.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    }
  }

  String _assignedTrainerName(
    OwnerMemberModel member,
    List<OwnerTrainerModel> trainers,
  ) {
    if (member.trainerName.trim().isNotEmpty) return member.trainerName.trim();
    if (member.trainerId.trim().isEmpty) return 'Self-guided workouts';

    for (final trainer in trainers) {
      if (trainer.id == member.trainerId ||
          trainer.trainerId == member.trainerId) {
        return trainer.fullName;
      }
    }

    return 'Trainer ID ${member.trainerId}';
  }

  Widget _detailSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.ownerBright,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
