import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class OwnerMembersScreen extends StatefulWidget {
  /// Called by the back arrow. The dashboard passes a callback that
  /// switches to the Home tab. When null, the arrow pops (if possible).
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

    // No-op if the dashboard already loaded members
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
          Positioned(
            top: -80,
            right: -60,
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

  Widget _buildHeader() {
    return Consumer<MemberProvider>(
      builder: (context, provider, _) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${provider.members.length} members in your gym',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed('addMember'),
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
                        'Add Member',
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
      },
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
            hintText: 'Search members...',
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
    final filters = ['All', 'Active', 'Expired'];

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
                  horizontal: 20,
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

  Widget _buildMemberList() {
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
                child: _buildMemberCard(member),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(OwnerMemberModel member) {
    final status = member.displayStatus;
    return GestureDetector(
      onTap: () => _showMemberDetails(member),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
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
                    '${member.planDisplayName} Plan',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _statusColor(status).withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _statusColor(status),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
                Icons.person_search_rounded,
                color: AppColors.primary.withValues(alpha: 0.7),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Members Found',
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

  void _showMemberDetails(OwnerMemberModel member) {
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
                Text(
                  '${member.planDisplayName} Plan',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 20),
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
                  icon: Icons.card_membership_rounded,
                  title: 'Plan',
                  value: member.planDisplayName,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
