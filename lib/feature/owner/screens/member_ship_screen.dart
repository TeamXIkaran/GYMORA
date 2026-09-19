import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';


class MemberShipScreen extends StatefulWidget {
  const MemberShipScreen({super.key});

  @override
  State<MemberShipScreen> createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends State<MemberShipScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

  late final AnimationController _glowController;
  late final AnimationController _particleController;

  final List<_MembershipData> _memberships = [
    _MembershipData(
      memberName: 'Aarav Sharma',
      initials: 'AS',
      plan: 'Premium',
      price: '₹15,000',
      startDate: '10 Jun 2026',
      expiryDate: '10 Dec 2026',
      daysLeft: 85,
      status: 'Active',
    ),
    _MembershipData(
      memberName: 'Neha Singh',
      initials: 'NS',
      plan: 'Standard',
      price: '₹10,000',
      startDate: '05 Jul 2026',
      expiryDate: '05 Oct 2026',
      daysLeft: 19,
      status: 'Expiring Soon',
    ),
    _MembershipData(
      memberName: 'Priya Patel',
      initials: 'PP',
      plan: 'Basic',
      price: '₹5,000',
      startDate: '01 Aug 2026',
      expiryDate: '01 Sep 2026',
      daysLeft: -15,
      status: 'Expired',
    ),
    _MembershipData(
      memberName: 'Rohit Kumar',
      initials: 'RK',
      plan: 'Premium',
      price: '₹15,000',
      startDate: '15 May 2026',
      expiryDate: '15 Nov 2026',
      daysLeft: 59,
      status: 'Active',
    ),
    _MembershipData(
      memberName: 'Sneha Joshi',
      initials: 'SJ',
      plan: 'Standard',
      price: '₹10,000',
      startDate: '20 Jul 2026',
      expiryDate: '20 Oct 2026',
      daysLeft: 34,
      status: 'Active',
    ),
    _MembershipData(
      memberName: 'Sahil Khan',
      initials: 'SK',
      plan: 'Basic',
      price: '₹5,000',
      startDate: '25 Jun 2026',
      expiryDate: '25 Jul 2026',
      daysLeft: -53,
      status: 'Expired',
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

  List<_MembershipData> get _filteredMemberships {
    List<_MembershipData> result = List.from(_memberships);

    // Status filter
    if (_selectedFilter == 1) {
      result = result.where((item) => item.status == 'Active').toList();
    } else if (_selectedFilter == 2) {
      result = result.where((item) => item.status == 'Expiring Soon').toList();
    } else if (_selectedFilter == 3) {
      result = result.where((item) => item.status == 'Expired').toList();
    }

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((item) {
        return item.memberName.toLowerCase().contains(query) ||
            item.plan.toLowerCase().contains(query);
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
                  painter: _MembershipParticlePainter(
                    _particleController.value,
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // GLOW
          // =====================================================
          Positioned(
            top: -100,
            right: -90,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 280 + (_glowController.value * 35);

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
                _buildSummary(),
                _buildSearch(),
                _buildFilters(),
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              context.pushNamed('ownerDashboard');
            },
          ),

          const SizedBox(width: 12),

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
                  'Manage member plans & expiry',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // ADD MEMBERSHIP
          GestureDetector(
            onTap: _showAddMembership,
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
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 5),
                  Text(
                    'Add',
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

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final active = _memberships.where((item) => item.status == 'Active').length;

    final expiring = _memberships
        .where((item) => item.status == 'Expiring Soon')
        .length;

    final expired = _memberships
        .where((item) => item.status == 'Expired')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 13),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'Active',
              value: '$active',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF42D982),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              title: 'Expiring',
              value: '$expiring',
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFFFFB020),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              title: 'Expired',
              value: '$expired',
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFFF4D67),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 11),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 19,
            ),
            hintText: 'Search member or plan...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 10),
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
                      size: 17,
                    ),
                  )
                : const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white30,
                    size: 18,
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilters() {
    final filters = ['All', 'Active', 'Expiring', 'Expired'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 9),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 6,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Text(
                    filters[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white,
                      fontSize: 9,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
  // LIST
  // ============================================================

  Widget _buildMembershipList() {
    final memberships = _filteredMemberships;

    if (memberships.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        final membership = memberships[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _MembershipCard(
            membership: membership,
            index: index,
            onTap: () {
              _showMembershipDetails(membership);
            },
            onRenew: () {
              _showRenewMembership(membership);
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
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
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              Icons.card_membership_rounded,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 32,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'No Memberships Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
  // ADD MEMBERSHIP BOTTOM SHEET
  // ============================================================

  void _showAddMembership() {
    String? selectedMember;
    String selectedPlan = 'Premium';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E16),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
                child: SingleChildScrollView(
                  child: Column(
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
                        'Add Membership',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Assign a membership plan to a member',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),

                      const SizedBox(height: 22),

                      _sheetLabel('Select Member'),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMember,
                            hint: const Text(
                              'Choose member',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                            dropdownColor: const Color(0xFF151923),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white38,
                            ),
                            isExpanded: true,
                            items: _memberships.map((member) {
                              return DropdownMenuItem<String>(
                                value: member.memberName,
                                child: Text(
                                  member.memberName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setSheetState(() {
                                selectedMember = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      _sheetLabel('Choose Plan'),

                      const SizedBox(height: 9),

                      Row(
                        children: [
                          Expanded(
                            child: _planOption(
                              title: 'Basic',
                              price: '₹5,000',
                              duration: '1 Month',
                              selected: selectedPlan == 'Basic',
                              onTap: () {
                                setSheetState(() {
                                  selectedPlan = 'Basic';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _planOption(
                              title: 'Standard',
                              price: '₹10,000',
                              duration: '3 Months',
                              selected: selectedPlan == 'Standard',
                              onTap: () {
                                setSheetState(() {
                                  selectedPlan = 'Standard';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _planOption(
                              title: 'Premium',
                              price: '₹15,000',
                              duration: '6 Months',
                              selected: selectedPlan == 'Premium',
                              onTap: () {
                                setSheetState(() {
                                  selectedPlan = 'Premium';
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Start date
                      _sheetLabel('Start Date'),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primary,
                              size: 17,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white30,
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 23),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedMember == null
                              ? null
                              : () {
                                  Navigator.pop(sheetContext);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF151923),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      content: Text(
                                        '$selectedPlan membership added successfully.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Add Membership',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
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
      },
    );
  }

  Widget _sheetLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // PLAN OPTION
  // ============================================================

  Widget _planOption({
    required String title,
    required String price,
    required String duration,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : Colors.white30,
              size: 17,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              duration,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white30, fontSize: 7),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBERSHIP DETAILS
  // ============================================================

  void _showMembershipDetails(_MembershipData membership) {
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
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

                _MemberAvatar(
                  initials: membership.initials,
                  index: _memberships.indexOf(membership),
                  size: 62,
                ),

                const SizedBox(height: 11),

                Text(
                  membership.memberName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${membership.plan} Membership',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),

                const SizedBox(height: 20),

                _infoRow(
                  Icons.card_membership_rounded,
                  'Plan',
                  membership.plan,
                ),

                _infoRow(
                  Icons.currency_rupee_rounded,
                  'Amount',
                  membership.price,
                ),

                _infoRow(
                  Icons.calendar_today_outlined,
                  'Start Date',
                  membership.startDate,
                ),

                _infoRow(
                  Icons.event_outlined,
                  'Expiry Date',
                  membership.expiryDate,
                ),

                _infoRow(
                  Icons.timer_outlined,
                  'Days Remaining',
                  membership.daysLeft > 0
                      ? '${membership.daysLeft} days'
                      : 'Expired',
                ),

                _infoRow(
                  Icons.circle,
                  'Status',
                  membership.status,
                  status: true,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRenewMembership(membership);
                    },
                    icon: const Icon(Icons.autorenew_rounded, size: 18),
                    label: const Text(
                      'Renew Membership',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _infoRow(
    IconData icon,
    String title,
    String value, {
    bool status = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: status ? const Color(0xFF42D982) : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 9),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: status ? const Color(0xFF42D982) : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RENEW
  // ============================================================

  void _showRenewMembership(_MembershipData membership) {
    String selectedPlan = membership.plan;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
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

                    Text(
                      'Renew ${membership.memberName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Select a membership plan',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _planOption(
                            title: 'Basic',
                            price: '₹5,000',
                            duration: '1 Month',
                            selected: selectedPlan == 'Basic',
                            onTap: () {
                              setSheetState(() {
                                selectedPlan = 'Basic';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _planOption(
                            title: 'Standard',
                            price: '₹10,000',
                            duration: '3 Months',
                            selected: selectedPlan == 'Standard',
                            onTap: () {
                              setSheetState(() {
                                selectedPlan = 'Standard';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _planOption(
                            title: 'Premium',
                            price: '₹15,000',
                            duration: '6 Months',
                            selected: selectedPlan == 'Premium',
                            onTap: () {
                              setSheetState(() {
                                selectedPlan = 'Premium';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 47,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF151923),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Text(
                                '$selectedPlan membership renewed successfully.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm Renewal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: Colors.white30, fontSize: 7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MEMBERSHIP CARD
// ============================================================

class _MembershipCard extends StatelessWidget {
  final _MembershipData membership;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRenew;

  const _MembershipCard({
    required this.membership,
    required this.index,
    required this.onTap,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = membership.status == 'Active';
    final isExpiring = membership.status == 'Expiring Soon';
    final isExpired = membership.status == 'Expired';

    final Color statusColor = isActive
        ? const Color(0xFF42D982)
        : isExpiring
        ? const Color(0xFFFFB020)
        : const Color(0xFFFF4D67);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _MemberAvatar(initials: membership.initials, index: index),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membership.memberName,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              membership.plan,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            membership.price,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    membership.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Expanded(
                  child: _dateItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Started',
                    value: membership.startDate,
                  ),
                ),

                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.07),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _dateItem(
                      icon: Icons.event_outlined,
                      label: 'Expires',
                      value: membership.expiryDate,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Bottom expiry progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpired
                        ? Icons.warning_amber_rounded
                        : Icons.access_time_rounded,
                    color: statusColor,
                    size: 15,
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      isExpired
                          ? 'Membership has expired'
                          : '${membership.daysLeft} days remaining',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (isExpired || isExpiring)
                    GestureDetector(
                      onTap: onRenew,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Renew',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white24, fontSize: 7),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// AVATAR
// ============================================================

class _MemberAvatar extends StatelessWidget {
  final String initials;
  final int index;
  final double size;

  const _MemberAvatar({
    required this.initials,
    required this.index,
    this.size = 43,
  });

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

class _MembershipData {
  final String memberName;
  final String initials;
  final String plan;
  final String price;
  final String startDate;
  final String expiryDate;
  final int daysLeft;
  final String status;

  const _MembershipData({
    required this.memberName,
    required this.initials,
    required this.plan,
    required this.price,
    required this.startDate,
    required this.expiryDate,
    required this.daysLeft,
    required this.status,
  });
}

// ============================================================
// PARTICLES
// ============================================================

class _MembershipParticlePainter extends CustomPainter {
  final double time;
  final List<_MembershipParticle> particles;

  _MembershipParticlePainter(this.time)
    : particles = List.generate(24, (index) => _MembershipParticle(index));

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
  bool shouldRepaint(covariant _MembershipParticlePainter oldDelegate) {
    return true;
  }
}

class _MembershipParticle {
  late final double x;
  late final double y;
  late final double speed;
  late final double radius;
  late final double opacity;
  late final double phase;
  late final bool isRed;

  _MembershipParticle(int seed) {
    final random = Random(seed * 27 + 300);

    x = random.nextDouble();
    y = random.nextDouble();
    speed = random.nextDouble() * 0.30 + 0.08;
    radius = random.nextDouble() * 1.4 + 0.4;
    opacity = random.nextDouble() * 0.30 + 0.06;
    phase = random.nextDouble() * 2 * pi;
    isRed = random.nextDouble() > 0.55;
  }
}
