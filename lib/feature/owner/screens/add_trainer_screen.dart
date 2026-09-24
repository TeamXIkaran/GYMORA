import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class AddTrainerScreen extends StatefulWidget {
  const AddTrainerScreen({super.key});

  @override
  State<AddTrainerScreen> createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gymIdController = TextEditingController();
  final _experienceController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _gymIdFocus = FocusNode();
  final _experienceFocus = FocusNode();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  String _selectedSpecialization = 'Weight Training';
  final List<_SpecData> _specializations = const [
    _SpecData('Weight Training', Icons.fitness_center_rounded),
    _SpecData('Cardio & HIIT', Icons.directions_run_rounded),
    _SpecData('CrossFit', Icons.sports_gymnastics_rounded),
    _SpecData('Yoga & Flexibility', Icons.self_improvement_rounded),
    _SpecData('Strength & Conditioning', Icons.sports_mma_rounded),
    _SpecData('Personal Training', Icons.person_rounded),
  ];

  // Trainer-specific accent color — warm orange
  static const _accent = Color(0xFFFF6B35);

  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _shimmerController;

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

    for (final node in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,

      _passwordFocus,
      _gymIdFocus,
      _experienceFocus,
    ]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _experienceController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _experienceFocus.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _gymIdFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final trainerProvider = context.read<TrainerProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final name = _nameController.text.trim();

    final success = await trainerProvider.addTrainer(
      fullName: name,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      gymId: _gymIdController.text.trim(),
      specialization: _selectedSpecialization,
      experience: int.parse(_experienceController.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      // Keep Home stats + Trainer Overview in sync
      dashboardProvider.fetchDashboard();
      _showSnack('$name added successfully!', isError: false);
      context.pop();
    } else {
      _showSnack(
        trainerProvider.error ?? 'Failed to add trainer',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF151923),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: isError
                  ? const Color(0xFFFF536F)
                  : const Color(0xFF3EE07F),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
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
                  painter: TrainersParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // Warm orange glow — top left
          Positioned(
            top: -120,
            left: -100,
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
                        _accent.withValues(alpha: 0.15),
                        _accent.withValues(alpha: 0.04),
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
                            'Fill in the trainer\'s information',
                          ),
                          const SizedBox(height: 14),

                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: 'Full Name',
                            hint: 'Enter trainer\'s full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter trainer name'
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
                            controller: _gymIdController,
                            focusNode: _gymIdFocus,
                            label: 'Gym ID',
                            hint: 'Enter gym ID e.g. Astha07',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.text,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) {
                                return 'Please enter gym ID';
                              }
                              if (t.length < 3) {
                                return 'Please enter a valid gym ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: 'Password',
                            hint: 'Create a login password for trainer',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 18,
                              ),
                            ),
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return 'Please enter password';
                              if (t.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _experienceController,
                            focusNode: _experienceFocus,
                            label: 'Experience (years)',
                            hint: 'e.g. 3',
                            icon: Icons.timeline_rounded,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (v) {
                              final years = int.tryParse(v?.trim() ?? '');
                              if (years == null) {
                                return 'Enter experience in years (numbers only)';
                              }
                              if (years > 60)
                                return 'Please enter a valid value';
                              return null;
                            },
                          ),

                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            'Specialization',
                            'Choose the trainer\'s expertise',
                          ),
                          const SizedBox(height: 14),

                          _buildSpecializationSelector(),

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
                  'Add Trainer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Register a new gym trainer',
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
                  _accent.withValues(alpha: 0.15),
                  _accent.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: _accent,
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
            _accent.withValues(alpha: 0.12),
            const Color(0xFF14101A).withValues(alpha: 0.80),
          ],
        ),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
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
                  _accent.withValues(alpha: 0.20),
                  _accent.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: _accent.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: _accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Trainer Onboarding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add a qualified trainer to your team and assign their area of expertise.',
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
                  colors: [Color(0xFFFF8C5A), _accent],
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
    Widget? suffix,
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
              ? _accent.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.07),
          width: focused ? 1.2 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.08),
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
                              _accent.withValues(alpha: 0.18),
                              _accent.withValues(alpha: 0.08),
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
                    color: focused ? _accent : Colors.white38,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: focused
                        ? _accent.withValues(alpha: 0.8)
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
            cursorColor: _accent,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.18),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              suffixIcon: suffix,
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

  Widget _buildSpecializationSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _specializations.map((spec) {
        final selected = _selectedSpecialization == spec.name;

        return GestureDetector(
          onTap: () => setState(() => _selectedSpecialization = spec.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        _accent.withValues(alpha: 0.16),
                        _accent.withValues(alpha: 0.06),
                      ],
                    )
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? _accent.withValues(alpha: 0.40)
                    : Colors.white.withValues(alpha: 0.07),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.10),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? spec.icon : spec.icon,
                  color: selected ? _accent : Colors.white30,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  spec.name,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
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
                        : const [Color(0xFFFF8C5A), _accent, Color(0xFFE65100)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isSubmitting
                      ? null
                      : [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.30),
                            blurRadius: 22,
                            spreadRadius: -4,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    if (!_isSubmitting)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ShaderMask(
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
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(color: Colors.white),
                          ),
                        ),
                      ),
                    Center(
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
                                  Icons.fitness_center_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Add Trainer',
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SpecData {
  final String name;
  final IconData icon;
  const _SpecData(this.name, this.icon);
}
