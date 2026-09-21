import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/core/widgets/glassTextField_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/glass_sheet_widget.dart';
import 'package:gymora_fitness_management/core/widgets/gradient_button_widget.dart';

import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GYM DETAILS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class GymDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const GymDetailsScreen({super.key, this.planData});

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  // ═══════════════════════════════════════════════════════════════════════
  // FORM
  // ═══════════════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();

  // ═══════════════════════════════════════════════════════════════════════
  // CONTROLLERS
  // ═══════════════════════════════════════════════════════════════════════

  final TextEditingController gymNameCtrl = TextEditingController();
  final TextEditingController gymIdCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController ownerNameCtrl = TextEditingController();
  final TextEditingController ownerEmailCtrl = TextEditingController();
  final TextEditingController ownerPhoneCtrl = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════
  // FOCUS NODES
  // ═══════════════════════════════════════════════════════════════════════

  final FocusNode _gymNameFocus = FocusNode();
  final FocusNode _gymIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _ownerNameFocus = FocusNode();
  final FocusNode _ownerEmailFocus = FocusNode();
  final FocusNode _ownerPhoneFocus = FocusNode();

  // ═══════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  // ═══════════════════════════════════════════════════════════════════════
  // 409 — GYM ID ALREADY EXISTS DIALOG
  // ═══════════════════════════════════════════════════════════════════════

  void _showGymIdAlreadyExistsDialog(String gymId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.tag_rounded,
                  color: Colors.orangeAccent,
                  size: 30,
                ),
              ),

              const SizedBox(height: 20),

              // ── Title ──
              const Text(
                'Gym ID Already Taken',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // ── Message ──
              Text(
                'The Gym ID "$gymId" is already registered. Please choose a different Gym ID or log in if this is your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Change Gym ID button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    gymIdCtrl.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: gymIdCtrl.text.length,
                    );
                    _gymIdFocus.requestFocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Change Gym ID',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Go to Login button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.goNamed('login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 409 — GMAIL ALREADY REGISTERED DIALOG
  // ═══════════════════════════════════════════════════════════════════════

  void _showAlreadyRegisteredDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Colors.orangeAccent,
                  size: 30,
                ),
              ),

              const SizedBox(height: 20),

              // ── Title ──
              const Text(
                'Gmail Already Registered',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // ── Message ──
              Text(
                'The Gmail address "$email" is already linked to an existing account. Please use a different Gmail or log in with the existing account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Change Email button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Focus the email field so user can change it
                    ownerEmailCtrl.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: ownerEmailCtrl.text.length,
                    );
                    _ownerEmailFocus.requestFocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Change Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Go to Login button ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.goNamed('login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SUBMIT — Calls /api/owner/purchase
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // ── FIX: read 'name' key (sent by PurchaseMembershipScreen) ──
    final planName = widget.planData?['name']?.toString() ?? 'PRO';

    final ownerProvider = context.read<OwnerLoginProvider>();
    final success = await ownerProvider.purchase(
      gymName: gymNameCtrl.text.trim(),
      gymId: gymIdCtrl.text.trim(),
      password: passwordCtrl.text,
      ownerName: ownerNameCtrl.text.trim(),
      ownerEmail: ownerEmailCtrl.text.trim(),
      ownerPhone: ownerPhoneCtrl.text.trim(),
      plan: planName,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      debugPrint('═══════════════════════════════════════════');
      debugPrint('🎉 [GymDetailsScreen] PURCHASE SUCCESS');
      debugPrint('📦 OwnerId: ${ownerProvider.purchaseResponse?.ownerId}');
      debugPrint('📦 GymId: ${ownerProvider.purchaseResponse?.gymId}');
      debugPrint('═══════════════════════════════════════════');

      // ── FIX: build paymentData with consistent keys for QRPaymentScreen ──
      final Map<String, dynamic> paymentData = {
        'plan': planName,
        'amount': widget.planData?['amount']?.toString() ?? '0',
        'duration': widget.planData?['duration']?.toString() ?? '',
        'ownerId': ownerProvider.purchaseResponse?.ownerId ?? '',
        'gymId': ownerProvider.purchaseResponse?.gymId ?? gymIdCtrl.text.trim(),
      };

      context.pushNamed('qrScreen', extra: paymentData);
    } else {
      // ══════════════════════════════════════════════════════════════
      // FIX: Distinguish "Gym ID already exists" from
      //      "Gmail already registered" — they are different errors!
      // ══════════════════════════════════════════════════════════════
      final statusCode = ownerProvider.statusCode;
      final errorMsg = ownerProvider.errorMessage ?? '';
      final lowerMsg = errorMsg.toLowerCase();

      if (statusCode == 409 ||
          lowerMsg.contains('already registered') ||
          lowerMsg.contains('already exists')) {
        // ── Gym ID conflict ──
        if (lowerMsg.contains('gym id') || lowerMsg.contains('gymid')) {
          _showGymIdAlreadyExistsDialog(gymIdCtrl.text.trim());
        }
        // ── Email/Gmail conflict ──
        else if (lowerMsg.contains('email') || lowerMsg.contains('gmail')) {
          _showAlreadyRegisteredDialog(ownerEmailCtrl.text.trim());
        }
        // ── Generic 409 — default to Gym ID dialog since that's most common ──
        else {
          _showGymIdAlreadyExistsDialog(gymIdCtrl.text.trim());
        }
      } else {
        // ── Generic error snackbar ──
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg.isNotEmpty
                  ? errorMsg
                  : 'Purchase failed. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // VALIDATORS
  // ═══════════════════════════════════════════════════════════════════════

  String? _validateGymName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter gym name';
    if (text.length < 3) return 'Gym name must be at least 3 characters';
    return null;
  }

  String? _validateGymId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter gym ID';
    if (!RegExp(r'^\d+$').hasMatch(text))
      return 'Gym ID must contain only numbers';
    if (text.length < 4 || text.length > 12)
      return 'Gym ID must be 4-12 digits';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter password';
    if (text.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(text))
      return 'Password must contain an uppercase letter';
    if (!RegExp(r'\d').hasMatch(text)) return 'Password must contain a number';
    return null;
  }

  String? _validateOwnerName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter owner name';
    if (text.length < 2) return 'Enter a valid owner name';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter Gmail address';
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!gmailRegex.hasMatch(text)) return 'Enter a valid Gmail address';
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter phone number';
    if (!RegExp(r'^\d{10}$').hasMatch(text))
      return 'Enter a valid 10-digit phone number';
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    gymNameCtrl.dispose();
    gymIdCtrl.dispose();
    passwordCtrl.dispose();
    ownerNameCtrl.dispose();
    ownerEmailCtrl.dispose();
    ownerPhoneCtrl.dispose();
    _gymNameFocus.dispose();
    _gymIdFocus.dispose();
    _passwordFocus.dispose();
    _ownerNameFocus.dispose();
    _ownerEmailFocus.dispose();
    _ownerPhoneFocus.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassSheet(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════════════════════════
                  // HEADER
                  // ═══════════════════════════════════════════════════════
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 18,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set Up Your Gym',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Create your gym login credentials',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════════════════
                  // SELECTED PLAN INFO
                  // ═══════════════════════════════════════════════════════
                  if (widget.planData != null)
                    _SelectedPlanBox(planData: widget.planData!),

                  if (widget.planData != null) const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════
                  // GYM ACCOUNT
                  // ═══════════════════════════════════════════════════════
                  const _PremiumSectionTitle(
                    icon: Icons.business_rounded,
                    title: 'Gym Account',
                    subtitle: 'Your gym login information',
                  ),

                  const SizedBox(height: 14),

                  GlassTextField(
                    controller: gymNameCtrl,
                    focusNode: _gymNameFocus,
                    hint: 'Enter gym name',
                    prefixIcon: Icons.fitness_center_rounded,
                    accentColor: AppColors.primary,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _gymIdFocus.requestFocus(),
                    validator: _validateGymName,
                  ),

                  const SizedBox(height: 12),

                  GlassTextField(
                    controller: gymIdCtrl,
                    focusNode: _gymIdFocus,
                    hint: 'Enter gym ID',
                    prefixIcon: Icons.tag_rounded,
                    prefixText: '# ',
                    accentColor: AppColors.primary,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 12,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    validator: _validateGymId,
                  ),

                  const SizedBox(height: 12),

                  GlassTextField(
                    controller: passwordCtrl,
                    focusNode: _passwordFocus,
                    hint: 'Create password',
                    prefixIcon: Icons.lock_outline_rounded,
                    accentColor: AppColors.primary,
                    obscure: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                    ),
                    onSubmitted: (_) => _ownerNameFocus.requestFocus(),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 12),

                  const _InfoBox(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Gym ID and password will be used by the owner to log in to GYMORA.',
                  ),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════════════════
                  // OWNER DETAILS
                  // ═══════════════════════════════════════════════════════
                  const _PremiumSectionTitle(
                    icon: Icons.person_outline_rounded,
                    title: 'Owner Details',
                    subtitle: 'Information for account recovery',
                  ),

                  const SizedBox(height: 14),

                  GlassTextField(
                    controller: ownerNameCtrl,
                    focusNode: _ownerNameFocus,
                    hint: 'Owner full name',
                    prefixIcon: Icons.person_outline_rounded,
                    accentColor: AppColors.primary,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _ownerEmailFocus.requestFocus(),
                    validator: _validateOwnerName,
                  ),

                  const SizedBox(height: 12),

                  GlassTextField(
                    controller: ownerEmailCtrl,
                    focusNode: _ownerEmailFocus,
                    hint: 'Owner Gmail address',
                    prefixIcon: Icons.email_outlined,
                    accentColor: AppColors.primary,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _ownerPhoneFocus.requestFocus(),
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 12),

                  const _InfoBox(
                    icon: Icons.mark_email_read_outlined,
                    text:
                        'OTP will be sent to this Gmail whenever the owner needs to reset the password.',
                  ),

                  const SizedBox(height: 12),

                  GlassTextField(
                    controller: ownerPhoneCtrl,
                    focusNode: _ownerPhoneFocus,
                    hint: '10-digit phone number',
                    prefixIcon: Icons.phone_outlined,
                    prefixText: '+91 ',
                    accentColor: AppColors.primary,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _submit(),
                    validator: _validatePhone,
                  ),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════
                  // SUBMIT
                  // ═══════════════════════════════════════════════════════
                  Consumer<OwnerLoginProvider>(
                    builder: (context, ownerProv, _) {
                      final loading = ownerProv.isLoading || _isSubmitting;

                      return GradientButton(
                        label: loading ? 'Processing...' : 'Proceed to Payment',
                        color: AppColors.primary,
                        onPressed: loading ? null : _submit,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════════
                  // FOOTER
                  // ═══════════════════════════════════════════════════════
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your information is securely processed',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SELECTED PLAN BOX
// ═══════════════════════════════════════════════════════════════════════════

class _SelectedPlanBox extends StatelessWidget {
  final Map<String, dynamic> planData;

  const _SelectedPlanBox({required this.planData});

  @override
  Widget build(BuildContext context) {
    // ── FIX: reads 'name', 'price', 'duration' — matches what
    //    PurchaseMembershipScreen now sends ──
    final name = planData['name']?.toString() ?? 'PRO';
    final price = planData['price']?.toString() ?? '10,000';
    final duration = planData['duration']?.toString() ?? '3 Months';

    Color planColor = AppColors.primary;
    final colorValue = planData['color'];
    if (colorValue is int) planColor = Color(colorValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            planColor.withValues(alpha: 0.14),
            planColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: planColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: planColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: planColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Plan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: TextStyle(
                    color: planColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹$price',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PremiumSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INFO BOX
// ═══════════════════════════════════════════════════════════════════════════

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: 0.8), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
