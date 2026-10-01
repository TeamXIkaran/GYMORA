import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/extension/secure_storage_extension.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/feature/auth/providers/trainer_login_provider.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_state_views.dart';
import 'package:provider/provider.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  static const Color trainerYellow = Color(0xFFFFC107);

  final TrainerDashboardProvider _store = TrainerDashboardProvider.instance;

  /// Only read after build() has checked the profile is loaded.
  TrainerProfile get _profile => _store.profile!;

  @override
  void initState() {
    super.initState();
    // GET /trainers/profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_store.hasLoaded) {
        _store.refreshProfile();
      } else {
        _store.loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081019), Color(0xFF05070C)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: _store,
            builder: (context, _) {
              if (_store.profile == null) {
                if (_store.error != null && !_store.isLoading) {
                  return TrainerErrorView(
                    message: _store.error!,
                    onRetry: _store.refreshProfile,
                  );
                }
                return const TrainerLoadingView(
                  message: 'Loading your profile...',
                );
              }
              return RefreshIndicator(
                color: trainerYellow,
                backgroundColor: const Color(0xFF121923),
                onRefresh: _store.refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 22),
                      _buildPersonalInformation(),
                      const SizedBox(height: 16),
                      _buildProfessionalInformation(),
                      const SizedBox(height: 16),
                      _buildGymInformation(),
                      const SizedBox(height: 16),
                      _buildStatistics(),
                      const SizedBox(height: 16),
                      _buildAccountOptions(),
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

  // ---------------------------------------------------------------------------
  // PROFILE HEADER
  // ---------------------------------------------------------------------------

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            trainerYellow.withValues(alpha: 0.18),
            const Color(0xFFFF9800).withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: trainerYellow.withValues(alpha: 0.25),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _profile.initials,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1118),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: trainerYellow.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: trainerYellow,
                  size: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            _profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _profile.specialization,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: trainerYellow.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: trainerYellow,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_profile.status.toUpperCase()} TRAINER',
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showEditProfileSheet,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: trainerYellow,
                side: BorderSide(color: trainerYellow.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PERSONAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInformation() {
    return _profileSection(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      children: [
        _infoTile(
          icon: Icons.person_outline_rounded,
          title: 'Full Name',
          value: _profile.name,
        ),
        _divider(),
        _infoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: _profile.email,
        ),
        _divider(),
        _infoTile(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: _profile.phone,
        ),
        _divider(),
        _infoTile(
          icon: Icons.badge_outlined,
          title: 'Trainer ID',
          value: _profile.trainerId,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFESSIONAL INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildProfessionalInformation() {
    return _profileSection(
      title: 'Professional Information',
      icon: Icons.workspace_premium_outlined,
      children: [
        _infoTile(
          icon: Icons.fitness_center_rounded,
          title: 'Specialization',
          value: _profile.specialization,
        ),
        _divider(),
        _infoTile(
          icon: Icons.badge_outlined,
          title: 'Experience',
          value: _profile.experienceLabel,
        ),
        _divider(),
        _infoTile(
          icon: Icons.groups_outlined,
          title: 'Clients',
          value:
              '${_store.totalClients} Assigned • ${_store.countByStatus('Active')} Active',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // GYM INFORMATION
  // ---------------------------------------------------------------------------

  Widget _buildGymInformation() {
    return _profileSection(
      title: 'Gym Information',
      icon: Icons.business_outlined,
      children: [
        _infoTile(
          icon: Icons.tag_rounded,
          title: 'Gym ID',
          value: _profile.gymId,
        ),
        _divider(),
        _infoTile(
          icon: Icons.work_outline_rounded,
          title: 'Role',
          value: 'Trainer',
        ),
        if (_profile.createdAt != null) ...[
          _divider(),
          _infoTile(
            icon: Icons.event_available_outlined,
            title: 'Member Since',
            value: formatLongDate(_profile.createdAt!),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STATISTICS
  // ---------------------------------------------------------------------------

  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: trainerYellow, size: 19),
              SizedBox(width: 9),
              Text(
                'Trainer Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _statItem(
                  value: '${_profile.totalClients}',
                  title: 'Clients',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _statItem(
                  value: '${_profile.completedSessions}',
                  title: 'Sessions',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _statItem(
                  value: _profile.trainingHours.toStringAsFixed(1),
                  title: 'Hours',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACCOUNT OPTIONS
  // ---------------------------------------------------------------------------

  Widget _buildAccountOptions() {
    return _profileSection(
      title: 'More Details ',
      icon: Icons.manage_accounts_outlined,
      children: [
        _divider(),

        _optionTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          onTap: _showHelpSheet,
          iconColor: Colors.amberAccent,
        ),

        _divider(),

        _optionTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          iconColor: Colors.redAccent,
          onTap: () {
            _showLogoutDialog();
          },
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121923),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _logout();
      }
    });
  }

  Future<void> _logout() async {
    try {
      await SecureStorageExtension().deleteToken();
      if (!mounted) return;

      context.read<TrainerLoginProvider>().clearState();
      _store.clear();
      context.goNamed('role-selection');
    } catch (error) {
      debugPrint('TRAINER_LOGOUT_ERROR: ${error.runtimeType}');
      if (!mounted) return;
      showTrainerErrorSnack(context, 'Unable to log out. Please try again.');
    }
  }
  // ---------------------------------------------------------------------------
  // EDIT PROFILE
  // ---------------------------------------------------------------------------

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _EditProfileSheet(),
    );
  }

  // ---------------------------------------------------------------------------
  // HELP & SUPPORT
  // ---------------------------------------------------------------------------

  void _showHelpSheet() {
    const faqs = [
      [
        'How do I get new clients?',
        'Clients are assigned to you by your gym owner. Once assigned, they appear in My Clients automatically.',
      ],
      [
        'How do I schedule a session?',
        'Open Schedule and tap Add Session, or use Add Session on your dashboard. Pick one of your clients, the date and the time.',
      ],
      [
        'How do I mark a session as done?',
        'Tap the session card and choose Mark as Completed. It is counted in your progress and in the client\'s sessions.',
      ],
      [
        'How do I give a client a workout?',
        'In My Clients tap Workout on the client card, choose a plan and tap Assign Workout.',
      ],
      [
        'Something is wrong with a client\'s plan or expiry?',
        'Membership plans and expiry dates are managed by your gym owner. Please contact them to make changes.',
      ],
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121923),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  const SizedBox(height: 20),
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...faqs.map(
                    (f) => Theme(
                      data: Theme.of(
                        sheetContext,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.035),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: ExpansionTile(
                          iconColor: trainerYellow,
                          collapsedIconColor: Colors.white38,
                          title: Text(
                            f[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            14,
                          ),
                          children: [
                            Text(
                              f[1],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                height: 1.45,
                              ),
                            ),
                          ],
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
  }

  // ---------------------------------------------------------------------------
  // SECTION
  // ---------------------------------------------------------------------------

  Widget _profileSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: trainerYellow, size: 18),
              ),
              const SizedBox(width: 10),
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

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFO TILE
  // ---------------------------------------------------------------------------

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white54, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required MaterialAccentColor iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: trainerYellow, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 12, color: Colors.white.withValues(alpha: 0.05));
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  Widget _statItem({required String value, required String title}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: trainerYellow,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// EDIT PROFILE SHEET
// Email, gym and role are managed by the owner/account and are read-only here.
// =============================================================================

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  static const Color trainerYellow = Color(0xFFFFC107);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _specialization;
  late final TextEditingController _experience;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = TrainerDashboardProvider.instance.profile;
    _name = TextEditingController(text: p?.name ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _specialization = TextEditingController(text: p?.specialization ?? '');
    _experience = TextEditingController(
      text: p == null || p.experience == 0 ? '' : '${p.experience}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _specialization.dispose();
    _experience.dispose();
    super.dispose();
  }

  /// PUT /trainers/profile
  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final error = await TrainerDashboardProvider.instance.updateProfile(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      specialization: _specialization.text.trim(),
      experience: int.tryParse(_experience.text.trim()) ?? 0,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      showTrainerErrorSnack(context, error);
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Profile updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _experienceValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 0 || n > 60) return 'Enter years as a number';
    return null;
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _phoneValidator(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator ?? _required,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        cursorColor: trainerYellow,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
          prefixIcon: Icon(icon, color: trainerYellow, size: 19),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.035),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: trainerYellow.withValues(alpha: 0.5)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121923),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 20),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Email and gym details are managed by your gym owner.',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 18),
                _field(_name, 'Full Name', Icons.person_outline_rounded),
                _field(
                  _phone,
                  'Phone',
                  Icons.phone_outlined,
                  validator: _phoneValidator,
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  _specialization,
                  'Specialization',
                  Icons.fitness_center_rounded,
                ),
                _field(
                  _experience,
                  'Experience (years)',
                  Icons.badge_outlined,
                  validator: _experienceValidator,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: trainerYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
