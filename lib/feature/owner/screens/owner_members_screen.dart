import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karan_fitness/config/theme/app_colors.dart';

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

  final List<_MemberData> _members = [
    _MemberData(
      name: 'Aarav Sharma',
      initials: 'AS',
      plan: 'Premium Plan',
      joinDate: '12 Jun 2025',
      status: 'Active',
      phone: '+91 98765 43210',
      email: 'aarav@gmail.com',
    ),
    _MemberData(
      name: 'Neha Singh',
      initials: 'NS',
      plan: 'Premium Plan',
      joinDate: '05 Jun 2025',
      status: 'Active',
      phone: '+91 98765 12345',
      email: 'neha@gmail.com',
    ),
    _MemberData(
      name: 'Rohit Kumar',
      initials: 'RK',
      plan: 'Standard Plan',
      joinDate: '02 Jun 2025',
      status: 'Active',
      phone: '+91 98765 56789',
      email: 'rohit@gmail.com',
    ),
    _MemberData(
      name: 'Priya Patel',
      initials: 'PP',
      plan: 'Basic Plan',
      joinDate: '28 May 2025',
      status: 'Active',
      phone: '+91 98765 67890',
      email: 'priya@gmail.com',
    ),
    _MemberData(
      name: 'Sahil Khan',
      initials: 'SK',
      plan: 'Premium Plan',
      joinDate: '20 Dec 2024',
      status: 'Inactive',
      phone: '+91 98765 34567',
      email: 'sahil@gmail.com',
    ),
    _MemberData(
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

  List<_MemberData> get _filteredMembers {
    List<_MemberData> result = List.from(_members);

    // Filter
    if (_selectedFilter == 1) {
      result = result.where((member) => member.status == 'Active').toList();
    } else if (_selectedFilter == 2) {
      result = result.where((member) => member.status == 'Inactive').toList();
    }

    // Search
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
          // =====================================================
          // BACKGROUND
          // =====================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // =====================================================
          // PARTICLES
          // =====================================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) {
                return CustomPaint(
                  painter: _MembersParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // =====================================================
          // RED GLOW
          // =====================================================
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

          // =====================================================
          // CONTENT
          // =====================================================
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
          // Back button
          _circleButton(
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
          child: _MemberCard(
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
  // CIRCLE BUTTON
  // ============================================================

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: Colors.white70, size: 19),
      ),
    );
  }

  // ============================================================
  // ADD MEMBER
  // ============================================================

  void _showAddMemberMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF151923),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Add Member screen can be connected here.',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBER DETAILS
  // ============================================================

  void _showMemberDetails(_MemberData member) {
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

                _Avatar(
                  initials: member.initials,
                  index: _members.indexOf(member),
                  size: 65,
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

                _detailRow(Icons.email_outlined, 'Email', member.email),
                _detailRow(Icons.phone_outlined, 'Phone', member.phone),
                _detailRow(
                  Icons.calendar_today_outlined,
                  'Joined',
                  member.joinDate,
                ),
                _detailRow(
                  Icons.card_membership_outlined,
                  'Membership',
                  member.plan,
                ),
                _detailRow(Icons.circle, 'Status', member.status, status: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    bool status = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: status ? const Color(0xFF42D982) : AppColors.primary,
          ),
          const SizedBox(width: 11),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status ? const Color(0xFF42D982) : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MEMBER CARD
// ============================================================

class _MemberCard extends StatelessWidget {
  final _MemberData member;
  final int index;
  final VoidCallback onTap;

  const _MemberCard({
    required this.member,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = member.status == 'Active';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            // Avatar
            _Avatar(initials: member.initials, index: index),

            const SizedBox(width: 12),

            // Name + plan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.plan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
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
                      const SizedBox(width: 6),
                      Text(
                        member.joinDate,
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF36D57D).withValues(alpha: 0.09)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF36D57D).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF42D982)
                          : Colors.white30,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    member.status,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF48DF8B)
                          : Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AVATAR
// ============================================================

class _Avatar extends StatelessWidget {
  final String initials;
  final int index;
  final double size;

  const _Avatar({required this.initials, required this.index, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFFE52A50), Color(0xFF671022)],
      const [Color(0xFFB91D3D), Color(0xFF49101C)],
      const [Color(0xFFE94C69), Color(0xFF7D1830)],
      const [Color(0xFF8D2941), Color(0xFF3B0D19)],
      const [Color(0xFFD83355), Color(0xFF651125)],
    ];

    final colors = gradients[index % gradients.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.18),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.27,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class _MemberData {
  final String name;
  final String initials;
  final String plan;
  final String joinDate;
  final String status;
  final String phone;
  final String email;

  const _MemberData({
    required this.name,
    required this.initials,
    required this.plan,
    required this.joinDate,
    required this.status,
    required this.phone,
    required this.email,
  });
}

// ============================================================
// PARTICLES
// ============================================================

class _MembersParticlePainter extends CustomPainter {
  final double time;
  final List<_MemberParticle> particles;

  _MembersParticlePainter(this.time)
    : particles = List.generate(24, (index) => _MemberParticle(index));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x =
          particle.x * size.width + sin(time * 2 * pi + particle.phase) * 9;

      final y =
          (particle.y * size.height - time * size.height * particle.speed) %
          size.height;

      final paint = Paint()
        ..color = particle.isRed
            ? AppColors.primary.withValues(alpha: particle.opacity)
            : Colors.white.withValues(alpha: particle.opacity * 0.18);

      if (particle.isRed) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MembersParticlePainter oldDelegate) {
    return true;
  }
}

class _MemberParticle {
  late final double x;
  late final double y;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isRed;

  _MemberParticle(int seed) {
    final random = Random(seed * 21 + 150);

    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.30 + 0.08;
    radius = random.nextDouble() * 1.4 + 0.4;
    opacity = random.nextDouble() * 0.30 + 0.06;
    phase = random.nextDouble() * 2 * pi;
    isRed = random.nextDouble() > 0.55;
  }
}
