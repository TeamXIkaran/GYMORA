import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/membership_plan_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.initialTrainerId});

  final String? initialTrainerId;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ────────────────────────────────────────────

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  /// Backend expects clientId, not gymId.
  final _clientIdController = TextEditingController();

  /// Backend expects trainerId.
  final _trainerIdController = TextEditingController();

  final _passwordController = TextEditingController();

  // ── Focus Nodes ────────────────────────────────────────────

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _clientIdFocus = FocusNode();
  final _trainerIdFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ── State ──────────────────────────────────────────────────

  String _selectedPlan = 'BASIC';
  int _currentStep = 0;
  bool _isSubmitting = false;

  // ── Animations ─────────────────────────────────────────────

  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _shimmerController;

  // ── Membership Plans ───────────────────────────────────────

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
    _trainerIdController.text = widget.initialTrainerId ?? '';

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

    for (final node in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,
      _clientIdFocus,
      _trainerIdFocus,
      _passwordFocus,
    ]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    // Controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _clientIdController.dispose();
    _trainerIdController.dispose();
    _passwordController.dispose();

    // Focus nodes
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _clientIdFocus.dispose();
    _trainerIdFocus.dispose();
    _passwordFocus.dispose();

    // Animations
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();

    super.dispose();
  }

  // ── Submit Form ────────────────────────────────────────────

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();

    // Backend expects yyyy-MM-dd.
    final startDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final provider = context.read<OwnerMemberProvider>();
    final dashboardProvider = context.read<OwnerDashboardProvider>();

    final name = _nameController.text.trim();

    final success = await provider.addMember(
      clientId: _clientIdController.text.trim(),
      fullName: name,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      trainerId: _trainerIdController.text.trim(),
      membershipPlan: _selectedPlan,
      startDate: startDate,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Refresh dashboard stats and recent members.
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
                          _buildStepIndicator(),
                          const SizedBox(height: 22),
                          if (_currentStep == 0) ...[
                            _buildSectionTitle(
                              'Personal Details',
                              'Fill in the member\'s information',
                            ),

                            const SizedBox(height: 14),

                            // ── Full Name ───────────────────────
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              label: 'Full Name',
                              hint: 'Enter member\'s full name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter name';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // ── Email ──────────────────────────
                            _buildTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'Email Address',
                              hint: 'Enter email address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter email';
                                }

                                if (!v.contains('@')) {
                                  return 'Please enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // ── Phone ──────────────────────────
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

                                if (t.isEmpty) {
                                  return 'Please enter phone number';
                                }

                                if (t.length != 10) {
                                  return 'Enter a valid 10-digit number';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // ── Client ID ───────────────────────
                            _buildTextField(
                              controller: _clientIdController,
                              focusNode: _clientIdFocus,
                              label: 'Client ID',
                              hint: 'Enter client ID e.g. 0001',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.text,
                              validator: (v) {
                                final t = v?.trim() ?? '';

                                if (t.isEmpty) {
                                  return 'Please enter client ID';
                                }

                                if (t.length < 3) {
                                  return 'Please enter a valid client ID';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // ── Trainer ID ──────────────────────
                            _buildTextField(
                              controller: _trainerIdController,
                              focusNode: _trainerIdFocus,
                              label: 'Trainer ID',
                              hint: 'Enter trainer ID e.g. 0003',
                              icon: Icons.fitness_center_rounded,
                              keyboardType: TextInputType.text,
                              validator: (v) {
                                final t = v?.trim() ?? '';

                                if (t.isEmpty) {
                                  return 'Please enter trainer ID';
                                }

                                if (t.length < 3) {
                                  return 'Please enter a valid trainer ID';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // ── Password ────────────────────────
                            _buildTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              hint: 'Create a password for member',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter password';
                                }

                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },
                            ),
                          ],
                          if (_currentStep == 1) ...[
                            _buildSectionTitle(
                              'Membership Plan',
                              'Choose the appropriate plan',
                            ),

                            const SizedBox(height: 14),

                            _buildPlanSelector(),
                          ],
                          if (_currentStep == 2) _buildReviewCard(),
                          const SizedBox(height: 24),
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

  // ── Header ─────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    const labels = ['Personal', 'Plan', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF29456B)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= _currentStep
                          ? AppColors.primary
                          : AppColors.surfaceHigh,
                      border: Border.all(
                        color: i <= _currentStep
                            ? AppColors.primary
                            : const Color(0xFF29456B),
                      ),
                      boxShadow: i == _currentStep
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: .3),
                                blurRadius: 14,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: i <= _currentStep
                            ? Colors.white
                            : Colors.white54,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: i == _currentStep ? Colors.white : Colors.white54,
                      fontSize: 11,
                      fontWeight: i == _currentStep
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (i < labels.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: Container(
                    height: 1,
                    color: i < _currentStep
                        ? AppColors.primary
                        : const Color(0xFF29456B),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    final plan = _plans[_selectedPlan]!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: .12),
            AppColors.card,
            AppColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Member',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check the details before creating the account.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 18),
          _reviewRow(
            Icons.person_outline_rounded,
            'Name',
            _nameController.text,
          ),
          _reviewRow(Icons.email_outlined, 'Email', _emailController.text),
          _reviewRow(Icons.phone_outlined, 'Phone', _phoneController.text),
          _reviewRow(
            Icons.badge_outlined,
            'Client ID',
            _clientIdController.text,
          ),
          _reviewRow(
            Icons.fitness_center_rounded,
            'Trainer ID',
            _trainerIdController.text,
          ),
          const Divider(color: Color(0xFF29456B), height: 22),
          _reviewRow(
            plan.icon,
            'Plan',
            '${plan.name} · ${plan.durationMonths} months · ${formatRupees(plan.price)}',
          ),
          _reviewRow(Icons.lock_outline_rounded, 'Password', 'Set and ready'),
        ],
      ),
    );
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 17),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStepAction() async {
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }
    await _submitForm();
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
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

  // ── Hero Card ──────────────────────────────────────────────

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

  // ── Text Field ─────────────────────────────────────────────

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
            ? const Color(0xFF142236)
            : const Color(0xFF0D1726).withValues(alpha: .82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focused
              ? AppColors.primary.withValues(alpha: 0.35)
              : const Color(0xFF29456B),
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
                    color: focused
                        ? AppColors.primary
                        : const Color(0xFF75A9E8),
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
                    fontSize: 11,
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
                fontSize: 13,
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

  // ── Plan Selector ──────────────────────────────────────────

  Widget _buildPlanSelector() {
    return Column(
      children: _plans.entries.map((entry) {
        final key = entry.key;
        final plan = entry.value;
        final selected = _selectedPlan == key;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : const Color(0xFF0D1726),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : const Color(0xFF29456B),
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
                          : const Color(0xFF142236),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      plan.icon,
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF75A9E8),
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

  // ── Add Button ─────────────────────────────────────────────

  Widget _buildAddButton() {
    final label = switch (_currentStep) {
      0 => 'Next',
      1 => 'Review details',
      _ => 'Create member',
    };
    final icon = _currentStep < 2
        ? Icons.arrow_forward_rounded
        : Icons.person_add_alt_1_rounded;

    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF29456B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: _currentStep == 0 ? 1 : 2,
          child: ShimmerButton(
            shimmerCtrl: _shimmerController,
            gradientColors: _isSubmitting
                ? const [Colors.white12, Colors.white10]
                : const [
                    Color(0xFFFF3158),
                    AppColors.primary,
                    Color(0xFFB91438),
                  ],
            accentColor: AppColors.primary,
            enabled: !_isSubmitting,
            onPressed: _handleStepAction,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Icon(icon, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ],
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
