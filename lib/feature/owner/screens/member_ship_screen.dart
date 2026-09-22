import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/membership_plan_model.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class MembershipScreen extends StatefulWidget {
  /// Called by the back arrow. The dashboard passes a callback that
  /// switches to the Home tab. When null, the arrow pops (if possible).
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

    // No-op if the dashboard already loaded members (avoids double fetch)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MemberProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<OwnerMemberModel> _getFilteredMembers(MemberProvider provider) {
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

  Map<String, int> _getMembershipSummary(MemberProvider provider) {
    final members = provider.members;
    return {
      'total': members.length,
      'active': provider.activeMembers.length,
      'expiring': provider.expiringMembers.length,
      'expired': provider.expiredMembers.length,
    };
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
            left: -40,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 260 + (_glowController.value * 30);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.14),
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
                Expanded(child: _buildMembershipList()),
              ],
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
                  'Memberships',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage all membership plans',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed('addMembership'),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 5),
                  Text(
                    'Add Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<MemberProvider>(
      builder: (context, provider, _) {
        final summary = _getMembershipSummary(provider);

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Row(
            children: [
              _buildSummaryCard(
                'Total',
                '${summary['total']}',
                const Color(0xFF6C8EFF),
                Icons.people_alt_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                'Active',
                '${summary['active']}',
                const Color(0xFF42DB82),
                Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                'Expiring',
                '${summary['expiring']}',
                const Color(0xFFFFB84D),
                Icons.schedule_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                'Expired',
                '${summary['expired']}',
                const Color(0xFFFF536F),
                Icons.cancel_rounded,
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
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search by name, email, or plan...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () => setState(() => _searchQuery = ''),
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

  Widget _buildFilters() {
    final filters = ['All', 'Active', 'Expiring', 'Expired'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 10),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;

          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.07),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMembershipList() {
    return Consumer<MemberProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.members.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.error != null && provider.members.isEmpty) {
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
                  provider.error!,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => provider.fetchMembers(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: AppColors.primary),
                  ),
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
                child: _buildMembershipCard(member),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMembershipCard(OwnerMemberModel member) {
    final statusColor = _getStatusColor(member.displayStatus);

    return GestureDetector(
      onTap: () => _showMembershipDetails(member),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFE62B52), Color(0xFF761326)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.email,
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.20),
                    ),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildMiniInfo(
                    Icons.card_membership_rounded,
                    member.planDisplayName,
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildMiniInfo(
                    Icons.calendar_today_outlined,
                    '${member.startDate} - ${member.endDate}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white30, size: 12),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.card_membership_rounded,
                color: AppColors.primary.withValues(alpha: 0.7),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Memberships Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try changing your search or filter.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showMembershipDetails(OwnerMemberModel member) {
    final statusColor = _getStatusColor(member.displayStatus);
    final daysLeft = member.daysLeft;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E16),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
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
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE62B52), Color(0xFF761326)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
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
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    member.displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Membership details
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

                const SizedBox(height: 18),

                // Renew button (only for expired/expiring)
                if (member.isExpired || member.isExpiring)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showRenewSheet(member);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.autorenew_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Renew Membership',
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenewSheet(OwnerMemberModel member) {
    // Pre-select the member's current plan if it's a known key
    String selectedPlan =
        MembershipPlan.byKey(member.membershipPlan)?.key ??
        MembershipPlan.basic.key;

    final plans = [
      for (final p in MembershipPlan.all)
        {
          'key': p.key,
          'name': p.shortName,
          'price': formatRupees(p.price),
          'duration': p.durationLabel,
        },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E16),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Renew Membership',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Renewing for ${member.fullName}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Plan selection
                    ...plans.map((plan) {
                      final isSelected = selectedPlan == plan['key'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(() => selectedPlan = plan['key']!);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.10)
                                  : Colors.white.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.40)
                                    : Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white24,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${plan['name']} Plan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        plan['duration']!,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  plan['price']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          // TODO: call the renew endpoint once the backend
                          // adds it (e.g. PUT /api/members/:id/renew).
                          onTap: () {
                            final messenger = ScaffoldMessenger.of(
                              this.context,
                            );
                            Navigator.pop(context);
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF151923),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Renewal isn\'t available yet — the backend endpoint is pending.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Confirm Renewal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
