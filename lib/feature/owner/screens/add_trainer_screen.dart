import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
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
  final _trainerIdController = TextEditingController();
  final _experienceController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _trainerIdFocus = FocusNode();
  final _experienceFocus = FocusNode();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  static const Color _accent = Color(0xFFE62B52);
  static const Color _accentLight = Color(0xFFFF5475);
  static const Color _surface = Color(0xFF10151F);

  String _selectedSpecialization = 'Weight Training';

  final List<_SpecData> _specializations = const [
    _SpecData('Weight Training', Icons.fitness_center_rounded),
    _SpecData('Cardio & HIIT', Icons.directions_run_rounded),
    _SpecData('CrossFit', Icons.sports_gymnastics_rounded),
    _SpecData('Yoga & Flexibility', Icons.self_improvement_rounded),
    _SpecData('Strength & Conditioning', Icons.sports_mma_rounded),
    _SpecData('Personal Training', Icons.person_rounded),
  ];

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
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    for (final node in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,
      _passwordFocus,
      _trainerIdFocus,
      _experienceFocus,
    ]) {
      node.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _trainerIdController.dispose();
    _experienceController.dispose();

    _nameFocus.removeListener(_onFocusChanged);
    _emailFocus.removeListener(_onFocusChanged);
    _phoneFocus.removeListener(_onFocusChanged);
    _passwordFocus.removeListener(_onFocusChanged);
    _trainerIdFocus.removeListener(_onFocusChanged);
    _experienceFocus.removeListener(_onFocusChanged);

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _trainerIdFocus.dispose();
    _experienceFocus.dispose();

    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------------

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final trainerProvider = context.read<OwnerTrainerProvider>();
    final dashboardProvider = context.read<OwnerDashboardProvider>();

    final name = _nameController.text.trim();

    try {
      final success = await trainerProvider.addTrainer(
        trainerId: _trainerIdController.text.trim(),
        fullName: name,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        specialization: _selectedSpecialization,
        experience: int.parse(_experienceController.text.trim()),
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (success) {
        dashboardProvider.fetchDashboard();

        _showSnack('$name added successfully!', isError: false);

        context.pop();
      } else {
        _showSnack(
          trainerProvider.error ?? 'Failed to add trainer',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      _showSnack('Something went wrong. Please try again.', isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF191D27),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: isError
                  ? const Color(0xFFFF536F)
                  : const Color(0xFF3EE07F),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      resizeToAvoidBottomInset: true,
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

          Positioned(
            top: -140,
            left: -120,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 300 + (_glowController.value * 45);

                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(alpha: 0.15),
                        _accent.withValues(alpha: 0.05),
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(),
                          const SizedBox(height: 28),

                          _buildSectionTitle(
                            'Personal Information',
                            'Enter the trainer account details',
                            Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 18),

                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: 'FULL NAME',
                            hint: 'Enter trainer full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter trainer name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: 'EMAIL ADDRESS',
                            hint: 'trainer@example.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = v?.trim() ?? '';

                              if (value.isEmpty) {
                                return 'Please enter email';
                              }

                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            label: 'PHONE NUMBER',
                            hint: 'Enter 10-digit mobile number',
                            icon: Icons.phone_iphone_rounded,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (v) {
                              final value = v?.trim() ?? '';

                              if (value.isEmpty) {
                                return 'Please enter phone number';
                              }

                              if (value.length != 10) {
                                return 'Enter a valid 10-digit number';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            controller: _trainerIdController,
                            focusNode: _trainerIdFocus,
                            label: 'TRAINER ID',
                            hint: 'Example: TRN003',
                            icon: Icons.badge_outlined,
                            validator: (v) {
                              final value = v?.trim() ?? '';

                              if (value.isEmpty) {
                                return 'Please enter trainer ID';
                              }

                              if (value.length < 3) {
                                return 'Please enter a valid trainer ID';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: 'LOGIN PASSWORD',
                            hint: 'Create trainer login password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white38,
                                size: 19,
                              ),
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';

                              if (value.isEmpty) {
                                return 'Please enter password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            controller: _experienceController,
                            focusNode: _experienceFocus,
                            label: 'EXPERIENCE',
                            hint: 'Enter experience in years',
                            icon: Icons.workspace_premium_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            suffix: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                'YEARS',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            validator: (v) {
                              final years = int.tryParse(v?.trim() ?? '');

                              if (years == null) {
                                return 'Enter experience in years';
                              }

                              if (years > 60) {
                                return 'Please enter a valid value';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          _buildSectionTitle(
                            'Area of Expertise',
                            'Select the trainer specialization',
                            Icons.bolt_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildSpecializationSelector(),

                          const SizedBox(height: 24),

                          _buildInfoStrip(),
                          const SizedBox(height: 12),
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

      // Fixed bottom shimmer button
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 4 : 0,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF080B12),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
            child: _buildAddButton(),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 14),
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
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'BUILD YOUR DREAM TEAM',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _accent.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: _accentLight,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO CARD
  // ------------------------------------------------------------

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29121E), Color(0xFF15131C), Color(0xFF10131B)],
        ),
        border: Border.all(color: _accent.withValues(alpha: 0.23)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.fitness_center_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.035),
            ),
          ),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF5475),
                      Color(0xFFE62B52),
                      Color(0xFFAD1638),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_gymnastics_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trainer Onboarding',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Bring new expertise to your gym. Create a trainer profile and set up their account.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: _accentLight, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // INPUT FIELD
  // ------------------------------------------------------------

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
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFF171B26) : const Color(0xFF10141D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused
              ? _accent.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.075),
          width: focused ? 1.3 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.09),
                  blurRadius: 18,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 10, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: focused
                        ? _accent.withValues(alpha: 0.14)
                        : Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    color: focused ? _accentLight : Colors.white38,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: focused ? _accentLight : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
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
              cursorColor: _accentLight,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 12,
                ),
                suffixIcon: suffix,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(0, 12, 8, 13),
                errorStyle: const TextStyle(
                  color: Color(0xFFFF647E),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SPECIALIZATION CARDS
  // ------------------------------------------------------------

  Widget _buildSpecializationSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _specializations.map((spec) {
            final selected = _selectedSpecialization == spec.name;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpecialization = spec.name;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                curve: Curves.easeOutCubic,
                width: itemWidth,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF351522), Color(0xFF20131C)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF141821), Color(0xFF10141D)],
                        ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? _accent.withValues(alpha: 0.70)
                        : Colors.white.withValues(alpha: 0.065),
                    width: selected ? 1.3 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.11),
                            blurRadius: 17,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 39,
                          height: 39,
                          decoration: BoxDecoration(
                            color: selected
                                ? _accent.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.045),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            spec.icon,
                            color: selected ? _accentLight : Colors.white54,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 19,
                          height: 19,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? _accent : Colors.transparent,
                            border: Border.all(
                              color: selected ? _accent : Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      spec.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 3,
                      width: selected ? 35 : 20,
                      decoration: BoxDecoration(
                        color: selected ? _accent : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // INFO STRIP
  // ------------------------------------------------------------

  Widget _buildInfoStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF111720),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF53C9A5), size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trainer details will be used to create their gym account.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SHIMMER BUTTON
  // ------------------------------------------------------------

  Widget _buildAddButton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: _isSubmitting
                  ? []
                  : [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.30),
                        blurRadius: 25,
                        offset: const Offset(0, 7),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSubmitting ? null : _submitForm,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isSubmitting
                            ? const [Color(0xFF44444B), Color(0xFF303038)]
                            : const [
                                Color(0xFFFF5475),
                                Color(0xFFE62B52),
                                Color(0xFFB9133C),
                              ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isSubmitting)
                          Positioned.fill(
                            child: ClipRect(
                              child: Transform.translate(
                                offset: Offset(
                                  -220 + _shimmerController.value * 440,
                                  0,
                                ),
                                child: Transform.rotate(
                                  angle: -0.25,
                                  child: Container(
                                    width: 75,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.23),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_isSubmitting)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Adding Trainer...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        else
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 11),
                              Text(
                                'Add Trainer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpecData {
  final String name;
  final IconData icon;

  const _SpecData(this.name, this.icon);
}
