import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class MembershipScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MembershipScreen({super.key, this.onBack});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

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
      if (mounted) {
        context.read<OwnerMemberProvider>().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERING
  // ============================================================

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

      result = result.where((member) {
        return member.fullName.toLowerCase().contains(q) ||
            member.email.toLowerCase().contains(q) ||
            member.phone.contains(q) ||
            member.planDisplayName.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  Map<String, int> _getMembershipSummary(OwnerMemberProvider provider) {
    final members = provider.members;

    return {
      'total': members.length,
      'active': provider.activeMembers.length,
      'expiring': provider.expiringMembers.length,
      'expired': provider.expiredMembers.length,
    };
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03060B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // Background particles
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
            top: -90,
            left: -60,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 270 + (_glowController.value * 35);

                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSummaryCards(),
                _buildSearchBar(),
                _buildFilters(),
                _buildResultsHeader(),
                Expanded(child: _buildMembershipList()),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Row(
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
                  'MEMBERSHIP MANAGEMENT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Memberships',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plans, renewal dates and member coverage',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          // Plan overview icon only.
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCards() {
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        final summary = _getMembershipSummary(provider);

        final total = summary['total'] ?? 0;
        return SizedBox(
          // Leave enough room for the card content at common Android text scales.
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            children: [
              _buildSummaryCard(
                'All plans',
                '$total',
                const Color(0xFF6C8EFF),
                Icons.card_membership_rounded,
                1,
              ),
              const SizedBox(width: 9),
              _buildSummaryCard(
                'Active',
                '${summary['active']}',
                const Color(0xFF42DB82),
                Icons.check_circle_rounded,
                total == 0 ? 0 : (summary['active'] ?? 0) / total,
              ),
              const SizedBox(width: 9),
              _buildSummaryCard(
                'Expiring',
                '${summary['expiring']}',
                const Color(0xFFFFB84D),
                Icons.schedule_rounded,
                total == 0 ? 0 : (summary['expiring'] ?? 0) / total,
              ),
              const SizedBox(width: 9),
              _buildSummaryCard(
                'Expired',
                '${summary['expired']}',
                const Color(0xFFFF536F),
                Icons.history_rounded,
                total == 0 ? 0 : (summary['expired'] ?? 0) / total,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    Color color,
    IconData icon,
    double share,
  ) {
    return SizedBox(
      width: 112,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                color.withValues(alpha: .13),
                const Color(0xFF151A2A),
              ),
              const Color(0xFF0A0F18),
            ],
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: color.withValues(alpha: 0.27)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 17,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share.clamp(0.0, 1.0),
                minHeight: 3,
                color: color,
                backgroundColor: Colors.white.withValues(alpha: .08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        final visible = _getFilteredMembers(provider).length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 1, 20, 5),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Memberships',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$visible shown',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 49,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F17),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search member, email, phone or plan...',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 10.5),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : const Icon(
                    Icons.manage_search_rounded,
                    color: Colors.white24,
                    size: 19,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
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
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        final filters = <(String, int)>[
          ('All', provider.members.length),
          ('Active', provider.activeMembers.length),
          ('Expiring', provider.expiringMembers.length),
          ('Expired', provider.expiredMembers.length),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 11),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(filters.length, (index) {
                final selected = _selectedFilter == index;
                final filter = filters[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == filters.length - 1 ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFE62B52), Color(0xFFB91438)],
                              )
                            : null,
                        color: selected ? null : const Color(0xFF0A0F17),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary.withValues(alpha: .7)
                              : Colors.white.withValues(alpha: .075),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: .20,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.$1,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white60,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white.withValues(alpha: .18)
                                  : Colors.white.withValues(alpha: .07),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${filter.$2}',
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white54,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MEMBER LIST
  // ============================================================

  Widget _buildMembershipList() {
    return Consumer<OwnerMemberProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.members.isEmpty) {
          return const DashboardShimmer(message: 'Loading membership data...');
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
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => provider.fetchMembers(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: AppColors.primary),
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
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 28),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _buildMembershipCard(member),
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

  Widget _buildMembershipCard(OwnerMemberModel member) {
    final statusColor = _getStatusColor(member.displayStatus);

    final daysLeft = member.daysLeft;

    return GestureDetector(
      onTap: () => _showMembershipDetails(member),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                statusColor.withValues(alpha: .045),
                const Color(0xFF131A27),
              ),
              const Color(0xFF090E17),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: statusColor.withValues(alpha: .18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ------------------------------------------------
            // MEMBER HEADER
            // ------------------------------------------------
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE62B52), Color(0xFF761326)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.16),
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
                        member.displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .035),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: .055)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.trainerBright,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TRAINER',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      member.trainerName.isNotEmpty
                          ? member.trainerName
                          : member.trainerId.isNotEmpty
                          ? 'ID ${member.trainerId}'
                          : 'Self training',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (member.trainerId.isEmpty)
                    const Icon(
                      Icons.self_improvement_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // PLAN HIGHLIGHT
            // ------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.025),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT PLAN',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          member.planDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (member.hasPrice)
                    Text(
                      member.formattedPrice,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // PLAN DETAILS
            // ------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _planInfo(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Started',
                    value: _formatDate(member.startDate),
                  ),
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.07),
                ),

                Expanded(
                  child: _planInfo(
                    icon: Icons.event_available_rounded,
                    label: 'Expires',
                    value: _formatDate(member.endDate),
                  ),
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.07),
                ),

                Expanded(
                  child: _planInfo(
                    icon: Icons.timelapse_rounded,
                    label: daysLeft != null && daysLeft < 0
                        ? 'Expired'
                        : 'Days Left',
                    value: daysLeft == null
                        ? '--'
                        : daysLeft < 0
                        ? '${-daysLeft}d'
                        : '${daysLeft}d',
                    valueColor: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to view full membership details',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.22),
                    fontSize: 8,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.22),
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _planInfo({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white24, fontSize: 7.5),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '--';

    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/'
          '${value.year}';
    }

    final text = value.toString();

    if (text.length >= 10) {
      final date = DateTime.tryParse(text.substring(0, 10));

      if (date != null) {
        return '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      }
    }

    return text;
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(String status) {
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
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.13),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_membership_rounded,
                color: AppColors.primary,
                size: 32,
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
            Text(
              'Try changing your search or filter.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.32),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBER DETAILS
  // ============================================================

  void _showMembershipDetails(OwnerMemberModel member) {
    final statusColor = _getStatusColor(member.displayStatus);

    final daysLeft = member.daysLeft;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E16),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          colors: [Color(0xFFE62B52), Color(0xFF761326)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      member.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      member.email,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.18),
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
                            member.displayStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Current Plan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.11),
                            Colors.white.withValues(alpha: 0.025),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CURRENT MEMBERSHIP',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  member.planDisplayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (member.hasPrice)
                            Text(
                              member.formattedPrice,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Membership details
                    if (member.clientId.isNotEmpty)
                      DetailRow(
                        icon: Icons.badge_outlined,
                        title: 'Member ID',
                        value: member.clientId,
                      ),

                    DetailRow(
                      icon: Icons.card_membership_rounded,
                      title: 'Plan',
                      value: member.planDisplayName,
                    ),

                    if (member.hasPrice)
                      DetailRow(
                        icon: Icons.currency_rupee_rounded,
                        title: 'Price',
                        value: member.formattedPrice,
                      ),

                    if (member.hasDuration)
                      DetailRow(
                        icon: Icons.timelapse_rounded,
                        title: 'Duration',
                        value: member.durationLabel,
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

                    if (daysLeft != null)
                      DetailRow(
                        icon: Icons.hourglass_bottom_rounded,
                        title: daysLeft < 0 ? 'Expired' : 'Days Left',
                        value: daysLeft < 0
                            ? '${-daysLeft} day${daysLeft == -1 ? '' : 's'} ago'
                            : '$daysLeft day${daysLeft == 1 ? '' : 's'}',
                      ),

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

                    DetailRow(
                      icon: Icons.fitness_center_rounded,
                      title: 'Trainer',
                      value: member.trainerName.isNotEmpty
                          ? member.trainerName
                          : member.trainerId.isNotEmpty
                          ? 'ID ${member.trainerId}'
                          : 'Self training',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _confirmDeleteMembership(sheetContext, member),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Delete membership'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF647C),
                          side: BorderSide(
                            color: const Color(
                              0xFFFF647C,
                            ).withValues(alpha: .4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteMembership(
    BuildContext sheetContext,
    OwnerMemberModel member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111722),
        title: const Text(
          'Delete membership?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This removes ${member.fullName} and their membership record from your gym.',
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
          content: Text(
            '${member.fullName} and their membership were deleted.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not delete membership.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    }
  }
}
