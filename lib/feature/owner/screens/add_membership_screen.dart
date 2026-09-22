import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';

import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';

class AddMembershipScreen extends StatefulWidget {
  const AddMembershipScreen({super.key});

  @override
  State<AddMembershipScreen> createState() => _AddMembershipScreenState();
}

class _AddMembershipScreenState extends State<AddMembershipScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  /// Selected member's id (names can repeat, ids can't).
  String? _selectedMemberId;

  /// Flip to true once the backend has an assign/renew membership endpoint
  /// and _activateMembership() calls it.
  static const bool _membershipApiReady = false;
  String _selectedPlan = 'Premium';
  DateTime _startDate = DateTime.now();

  late final AnimationController _glowController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  /// Real members from the API (was a hardcoded list).
  List<OwnerMemberModel> get _members => context.read<MemberProvider>().members;

  String? get _selectedMemberName {
    if (_selectedMemberId == null) return null;
    for (final m in context.read<MemberProvider>().members) {
      if (m.id == _selectedMemberId) return m.fullName;
    }
    return null;
  }

  final List<_PlanData> _plans = const [
    _PlanData(
      name: 'Basic',
      price: '₹5,000',
      duration: '1 Month',
      months: 1,
      icon: Icons.bolt_rounded,
      color: Color(0xFF0984E3),
    ),
    _PlanData(
      name: 'Standard',
      price: '₹10,000',
      duration: '3 Months',
      months: 3,
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF6C5CE7),
    ),
    _PlanData(
      name: 'Premium',
      price: '₹15,000',
      duration: '6 Months',
      months: 6,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFFF4D6D),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MemberProvider>().ensureLoaded();
    });
  }

  Future<void> _activateMembership() async {
    if (!_membershipApiReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF151923),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFFFB84D),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Assigning a plan isn\'t available yet — the backend endpoint is pending.',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // TODO: when the endpoint exists, call it here, e.g.
    // await MemberService.assignMembership(
    //   memberId: _selectedMemberId!,
    //   membershipPlan: _selectedPlan.toUpperCase(),
    //   startDate: _startDate,
    // );
    // then: context.read<MemberProvider>().fetchMembers();
    //       context.read<DashboardProvider>().fetchDashboard();
    //       context.pop();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  _PlanData get _selectedPlanData =>
      _plans.firstWhere((plan) => plan.name == _selectedPlan);

  DateTime get _expiryDate => DateTime(
    _startDate.year,
    _startDate.month + _selectedPlanData.months,
    _startDate.day,
  );

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xFF10151F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the member list loads/changes
    context.watch<MemberProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF03060A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // Primary glow
          Positioned(
            top: -120,
            right: -100,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 300 + (_glowController.value * 40);
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

          // Purple glow — bottom left
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withValues(alpha: 0.07),
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(),
                          const SizedBox(height: 28),

                          _buildSectionTitle(
                            'SELECT MEMBER',
                            'Assign a plan to your member',
                          ),
                          const SizedBox(height: 12),
                          _buildMemberSelector(),

                          const SizedBox(height: 28),

                          _buildSectionTitle(
                            'CHOOSE PLAN',
                            'Select the membership duration',
                          ),
                          const SizedBox(height: 14),
                          _buildPlanCards(),

                          const SizedBox(height: 28),

                          _buildSectionTitle(
                            'START DATE',
                            'When the membership begins',
                          ),
                          const SizedBox(height: 12),
                          _buildDateCard(),

                          const SizedBox(height: 24),
                          _buildMembershipSummary(),

                          const SizedBox(height: 32),
                          _buildAddButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Activate a plan for your member',
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, _) {
              final glow = 0.12 + (_pulseController.value * 0.10);
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glow),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            const Color(0xFF14101A).withValues(alpha: 0.80),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.20),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power up your member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose a plan, set the start date and activate the membership.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF4D6D), Color(0xFFE62B52)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 9),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _members.any((m) => m.id == _selectedMemberId)
              ? _selectedMemberId
              : null,
          isExpanded: true,
          dropdownColor: const Color(0xFF111620),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white30,
          ),
          hint: Row(
            children: [
              _iconBox(Icons.person_outline_rounded),
              const SizedBox(width: 11),
              Text(
                _members.isEmpty ? 'No members yet' : 'Select member',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return _members.map((member) {
              return Row(
                children: [
                  _iconBox(Icons.person_outline_rounded),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      member.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: _members.map((member) {
            return DropdownMenuItem<String>(
              value: member.id,
              child: Text(
                '${member.fullName} • ${member.planDisplayName}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedMemberId = value),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: _plans.map((plan) {
        final selected = _selectedPlan == plan.name;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = plan.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          plan.color.withValues(alpha: 0.14),
                          plan.color.withValues(alpha: 0.04),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.04),
                          Colors.white.withValues(alpha: 0.015),
                        ],
                      ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? plan.color.withValues(alpha: 0.50)
                      : Colors.white.withValues(alpha: 0.06),
                  width: selected ? 1.2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: plan.color.withValues(alpha: 0.10),
                          blurRadius: 22,
                          spreadRadius: -5,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selected
                            ? [
                                plan.color.withValues(alpha: 0.22),
                                plan.color.withValues(alpha: 0.08),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      plan.icon,
                      color: selected ? plan.color : Colors.white30,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (plan.name == 'Premium') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      plan.color,
                                      plan.color.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 6,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.duration,
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    plan.price,
                    style: TextStyle(
                      color: selected ? plan.color : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? plan.color : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? plan.color
                            : Colors.white.withValues(alpha: 0.15),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateCard() {
    return GestureDetector(
      onTap: _selectStartDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: TextStyle(color: Colors.white30, fontSize: 9),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Membership begins on',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(_startDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.015),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white38,
                  size: 16,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Membership Summary',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3EE07F).withValues(alpha: 0.15),
                      const Color(0xFF3EE07F).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF3EE07F).withValues(alpha: 0.15),
                  ),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF3EE07F),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow('Member', _selectedMemberName ?? 'Not selected'),
          _summaryRow('Plan', _selectedPlan),
          _summaryRow('Amount', _selectedPlanData.price),
          _summaryRow('Start Date', _formatDate(_startDate)),
          _summaryRow('Expiry Date', _formatDate(_expiryDate)),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: value == 'Not selected' ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final enabled = _selectedMemberId != null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? _activateMembership : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFFF3A5E),
                        Color(0xFFE62B52),
                        Color(0xFFB91438),
                      ],
                    )
                  : null,
              color: enabled ? null : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 22,
                        spreadRadius: -4,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                if (enabled)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (_, _) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(
                                  -1 + _shimmerController.value * 3,
                                  0,
                                ),
                                end: Alignment(
                                  -0.5 + _shimmerController.value * 3,
                                  0,
                                ),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.transparent,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership_rounded,
                        color: enabled ? Colors.white : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Activate Membership',
                        style: TextStyle(
                          color: enabled ? Colors.white : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanData {
  final String name;
  final String price;
  final String duration;
  final int months;
  final IconData icon;
  final Color color;

  const _PlanData({
    required this.name,
    required this.price,
    required this.duration,
    required this.months,
    required this.icon,
    required this.color,
  });
}
