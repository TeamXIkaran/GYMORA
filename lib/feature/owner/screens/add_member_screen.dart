import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/membership_plan_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String _selectedPlan = 'BASIC';
  bool _isSubmitting = false;

  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _shimmerController;

  // Plan data — prices/durations come from the shared catalog
  static final Map<String, _PlanInfo> _plans = {
    for (final p in MembershipPlan.all)
      p.key: _PlanInfo(p.name, p.price, p.durationMonths, _planIcons[p.key]!),
  };

  static const _planIcons = {
    'BASIC': Icons.star_border_rounded,
    'STANDARD': Icons.star_half_rounded,
    'PREMIUM': Icons.star_rounded,
  };

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

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    for (final node in [_nameFocus, _emailFocus, _phoneFocus, _passwordFocus]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final plan = _plans[_selectedPlan]!;
    final now = DateTime.now();
    // yyyy-MM-dd in the device's local date (what the API expects)
    final startDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final provider = context.read<MemberProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final name = _nameController.text.trim();

    final success = await provider.addMember(
      fullName: name,
      planName: plan.name,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      membershipPlan: _selectedPlan,
      startDate: startDate,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      // Keep Home stats + Recent Members in sync
      dashboardProvider.fetchDashboard();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF151923),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF3EE07F),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$name added successfully!',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF151923),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_rounded,
                color: Color(0xFFFF536F),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.error ?? 'Failed to add member',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03060A),
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
            top: -120,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 280 + (_glowController.value * 40);
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(),
                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            'Personal Details',
                            'Fill in the member\'s information',
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: 'Full Name',
                            hint: 'Enter member\'s full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter name'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: 'Email Address',
                            hint: 'Enter email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Please enter email';
                              if (!v.contains('@'))
                                return 'Please enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            label: 'Phone Number',
                            hint: 'Enter phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return 'Please enter phone number';
                              if (t.length != 10) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: 'Password',
                            hint: 'Create a password for member',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Please enter password';
                              if (v.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),

                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            'Membership Plan',
                            'Choose the appropriate plan',
                          ),
                          const SizedBox(height: 14),

                          _buildPlanSelector(),

                          const SizedBox(height: 36),

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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
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
                  'Add Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Register a new gym member',
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
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
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            const Color(0xFF14101A).withValues(alpha: 0.80),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Member Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add a new member to your gym and assign a membership plan.',
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
                  colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final focused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: focused
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused
              ? AppColors.primary.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.07),
          width: focused ? 1.2 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: focused
                          ? [
                              AppColors.primary.withValues(alpha: 0.18),
                              AppColors.primary.withValues(alpha: 0.08),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: focused ? AppColors.primary : Colors.white38,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: focused
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.primary,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.18),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(
                color: Color(0xFFFF536F),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      children: _plans.entries.map((entry) {
        final key = entry.key;
        final plan = entry.value;
        final selected = _selectedPlan == key;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.07),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      plan.icon,
                      color: selected ? AppColors.primary : Colors.white30,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${plan.durationMonths} month${plan.durationMonths > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupees(plan.price),
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _submitForm,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (_, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSubmitting
                        ? [Colors.white12, Colors.white10]
                        : const [
                            Color(0xFFFF3158),
                            AppColors.primary,
                            Color(0xFFB91438),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isSubmitting
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.30),
                            blurRadius: 22,
                            spreadRadius: -4,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Add Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlanInfo {
  final String name;
  final int price;
  final int durationMonths;
  final IconData icon;
  const _PlanInfo(this.name, this.price, this.durationMonths, this.icon);
}
