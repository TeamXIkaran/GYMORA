import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/core/model/owmer_member_model.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/member_card.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_avtar.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class OwnerMembersScreen extends StatefulWidget {
  const OwnerMembersScreen({super.key});

  @override
  State<OwnerMembersScreen> createState() => _OwnerMembersScreenState();
}

class _OwnerMembersScreenState extends State<OwnerMembersScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

  late final AnimationController _glowController;
  late final AnimationController _particleController;

  final List<OwmerMemberModel> _members = const [
    OwmerMemberModel(
      name: 'Aarav Sharma',
      initials: 'AS',
      plan: 'Premium Plan',
      joinDate: '12 Jun 2025',
      status: 'Active',
      phone: '+91 98765 43210',
      email: 'aarav@gmail.com',
    ),
    OwmerMemberModel(
      name: 'Neha Singh',
      initials: 'NS',
      plan: 'Premium Plan',
      joinDate: '05 Jun 2025',
      status: 'Active',
      phone: '+91 98765 12345',
      email: 'neha@gmail.com',
    ),
    OwmerMemberModel(
      name: 'Rohit Kumar',
      initials: 'RK',
      plan: 'Standard Plan',
      joinDate: '02 Jun 2025',
      status: 'Active',
      phone: '+91 98765 56789',
      email: 'rohit@gmail.com',
    ),
    OwmerMemberModel(
      name: 'Priya Patel',
      initials: 'PP',
      plan: 'Basic Plan',
      joinDate: '28 May 2025',
      status: 'Active',
      phone: '+91 98765 67890',
      email: 'priya@gmail.com',
    ),
    OwmerMemberModel(
      name: 'Sahil Khan',
      initials: 'SK',
      plan: 'Premium Plan',
      joinDate: '20 Dec 2024',
      status: 'Inactive',
      phone: '+91 98765 34567',
      email: 'sahil@gmail.com',
    ),
    OwmerMemberModel(
      name: 'Ananya Gupta',
      initials: 'AG',
      plan: 'Standard Plan',
      joinDate: '15 Nov 2024',
      status: 'Inactive',
      phone: '+91 98765 23456',
      email: 'ananya@gmail.com',
    ),
  ];

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
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<OwmerMemberModel> get _filteredMembers {
    List<OwmerMemberModel> result = List.from(_members);

    if (_selectedFilter == 1) {
      result = result.where((member) => member.status == 'Active').toList();
    } else if (_selectedFilter == 2) {
      result = result.where((member) => member.status == 'Inactive').toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((member) {
        return member.name.toLowerCase().contains(query) ||
            member.plan.toLowerCase().contains(query) ||
            member.email.toLowerCase().contains(query);
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
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) {
                return CustomPaint(
                  painter: MembersParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // Red glow
          Positioned(
            top: -100,
            right: -90,
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
                        AppColors.primary.withValues(alpha: 0.18),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildMembersList()),
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              context.pushNamed('ownerDashboard');
            },
          ),

          const SizedBox(width: 12),

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
                  '${_members.length} members in your gym',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // Add member
          GestureDetector(
            onTap: _showAddMemberMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                size: 20,
              ),
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
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
            hintText: 'Search members...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
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
  // FILTER TABS
  // ============================================================

  Widget _buildFilters() {
    final filters = ['All', 'Active', 'Inactive'];

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
              onTap: () {
                setState(() {
                  _selectedFilter = index;
                });
              },
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

  // ============================================================
  // MEMBER LIST
  // ============================================================

  Widget _buildMembersList() {
    final members = _filteredMembers;

    if (members.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MemberCard(
            member: member,
            index: index,
            onTap: () => _showMemberDetails(member),
          ),
        );
      },
    );
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
              width: 70,
              height: 70,
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
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD MEMBER
  // ============================================================

  void _showAddMemberMessage() {
    context.pushNamed('addMember');
  }

  // ============================================================
  // MEMBER DETAILS
  // ============================================================

  void _showMemberDetails(OwmerMemberModel member) {
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

                OwnerAvatar(
                  initials: member.initials,
                  index: _members.indexOf(member),
                  size: 65,
                  showShadow: true,
                ),

                const SizedBox(height: 12),

                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  member.plan,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 22),

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
                  icon: Icons.calendar_today_outlined,
                  title: 'Joined',
                  value: member.joinDate,
                ),
                DetailRow(
                  icon: Icons.card_membership_outlined,
                  title: 'Membership',
                  value: member.plan,
                ),
                DetailRow(
                  icon: Icons.circle,
                  title: 'Status',
                  value: member.status,
                  isStatus: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
