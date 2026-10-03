import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_login_model.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/feature/auth/providers/owner_login_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditOwnerProfileScreen extends StatefulWidget {
  const EditOwnerProfileScreen({super.key});

  @override
  State<EditOwnerProfileScreen> createState() => _EditOwnerProfileScreenState();
}

class _EditOwnerProfileScreenState extends State<EditOwnerProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gymController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  late final AnimationController _buttonShimmerController;

  OwnerLoginModel? _owner;
  String? _savedPhotoPath;
  XFile? _pendingPhoto;
  bool _loading = true;

  static const _bg = Color(0xFF070609);
  static const _surface = Color(0xFF141016);
  static const _red = Color(0xFFFF526F);
  static const _muted = Color(0xFF99929B);

  @override
  void initState() {
    super.initState();
    _buttonShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final provider = context.read<OwnerLoginProvider>();

    try {
      if (provider.owner == null) {
        await provider.fetchProfile();
      }

      if (!mounted) return;

      final owner = provider.owner;
      if (owner != null) {
        _owner = owner;
        _nameController.text = owner.ownerName;
        _gymController.text = owner.gymName;
        _emailController.text = owner.email;
        _phoneController.text = owner.phone ?? '';

        final prefs = await SharedPreferences.getInstance();
        _savedPhotoPath = prefs.getString(_photoKey(owner));
      }
    } catch (error) {
      debugPrint('OWNER_PROFILE_LOAD_ERROR: $error');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  String _photoKey(OwnerLoginModel owner) =>
      'owner_profile_photo_${owner.gymId}';

  @override
  void dispose() {
    _nameController.dispose();
    _gymController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _buttonShimmerController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF151016),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
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
              const SizedBox(height: 20),
              const Text(
                'Update profile photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to add your photo',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              _photoSourceTile(
                icon: Icons.photo_library_rounded,
                title: 'Choose from gallery',
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              _photoSourceTile(
                icon: Icons.camera_alt_rounded,
                title: 'Take a photo',
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() => _pendingPhoto = image);
      }
    } catch (error) {
      debugPrint('OWNER_PHOTO_PICK_ERROR: $error');
      if (mounted) {
        _showMessage('Could not open the selected photo source.');
      }
    }
  }

  Widget _photoSourceTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF21151D),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _red, size: 20),
              ),
              const SizedBox(width: 13),
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
                color: Colors.white38,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _owner == null) {
      return;
    }

    final provider = context.read<OwnerLoginProvider>();
    final dashboardProvider = context.read<OwnerDashboardProvider>();

    final saved = await provider.updateProfile({
      'ownerName': _nameController.text.trim(),
      'gymName': _gymController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    if (!mounted) return;

    if (!saved) {
      _showMessage(provider.profileError ?? 'Could not save profile changes.');
      return;
    }

    try {
      if (_pendingPhoto != null) {
        final owner = provider.owner ?? _owner!;
        final directory = await getApplicationDocumentsDirectory();

        final safeGymId = owner.gymId.replaceAll(
          RegExp(r'[^a-zA-Z0-9_-]'),
          '_',
        );

        final extension = _pendingPhoto!.path.split('.').last.toLowerCase();
        final file = await File(_pendingPhoto!.path).copy(
          '${directory.path}${Platform.pathSeparator}'
          'owner-profile-$safeGymId.$extension',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_photoKey(owner), file.path);
        _savedPhotoPath = file.path;
        _pendingPhoto = null;
      }
    } catch (error) {
      debugPrint('OWNER_PHOTO_SAVE_ERROR: $error');
      if (mounted) {
        _showMessage('Profile saved, but the photo could not be stored.');
      }
      return;
    }

    await dashboardProvider.fetchDashboard();

    if (!mounted) return;

    _showMessage('Profile updated successfully.');
    context.pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF24151D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _red.withValues(alpha: .2)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-.8, -.9),
                  radius: 1.3,
                  colors: [Color(0x44FF3158), _bg],
                ),
              ),
            ),
          ),
          Positioned(
            top: 210,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_red.withValues(alpha: .07), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _red))
                : _owner == null
                ? _loadError()
                : Column(
                    children: [
                      _header(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _photoCard(_owner!),
                                const SizedBox(height: 28),
                                _sectionHeading(
                                  'PERSONAL DETAILS',
                                  'Manage your account information',
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  _nameController,
                                  'Owner name',
                                  Icons.person_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Owner name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                _field(
                                  _gymController,
                                  'Gym name',
                                  Icons.fitness_center_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Gym name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                _field(
                                  _emailController,
                                  'Email address',
                                  Icons.mail_rounded,
                                  type: TextInputType.emailAddress,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    final valid = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(email);
                                    return valid
                                        ? null
                                        : 'Enter a valid email address';
                                  },
                                ),
                                const SizedBox(height: 13),
                                _field(
                                  _phoneController,
                                  'Phone number',
                                  Icons.phone_rounded,
                                  type: TextInputType.phone,
                                  validator: (value) {
                                    final phone = value?.trim() ?? '';
                                    if (phone.isEmpty) return null;
                                    if (!RegExp(
                                      r'^[0-9+\-\s()]{7,16}$',
                                    ).hasMatch(phone)) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 27),
                                _saveButton(),
                                const SizedBox(height: 15),
                                const Center(
                                  child: Text(
                                    'Your profile information is kept secure',
                                    style: TextStyle(
                                      color: Colors.white30,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
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
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1118),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .07)),
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT SETTINGS',
                  style: TextStyle(
                    color: Color(0xFFFF7187),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Edit profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF21131A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _red.withValues(alpha: .22)),
            ),
            child: const Icon(
              Icons.manage_accounts_rounded,
              color: Color(0xFFFF7187),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(OwnerLoginModel owner) {
    final path = _pendingPhoto?.path ?? _savedPhotoPath;

    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7187), Color(0xFF7F142D), Color(0xFF251019)],
        ),
        boxShadow: [
          BoxShadow(
            color: _red.withValues(alpha: .12),
            blurRadius: 27,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF241018), Color(0xFF171016), Color(0xFF0D0B10)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -65,
              right: -65,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_red.withValues(alpha: .16), Colors.transparent],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFA0AE),
                            Color(0xFFFF3158),
                            Color(0xFF7F142D),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF100D13),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: path != null && File(path).existsSync()
                              ? Image.file(File(path), fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFF32121E),
                                  alignment: Alignment.center,
                                  child: Text(
                                    owner.ownerName.isEmpty
                                        ? '?'
                                        : owner.ownerName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -1,
                      child: Material(
                        color: _red,
                        shape: const CircleBorder(),
                        elevation: 5,
                        child: InkWell(
                          onTap: _choosePhoto,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Make your profile yours',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _choosePhoto,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF8A9D),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.add_a_photo_rounded, size: 15),
                        label: const Text(
                          'Change photo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 31,
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(color: _red.withValues(alpha: .4), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
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

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _red,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFFF7187), size: 19),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _red, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF647C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF647C), width: 1.4),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Consumer<OwnerLoginProvider>(
      builder: (context, provider, _) {
        final isSaving = provider.isProfileUpdating;

        return ShimmerButton(
          shimmerCtrl: _buttonShimmerController,
          gradientColors: const [Color(0xFFFF526F), Color(0xFFB91438)],
          accentColor: _red,
          height: 56,
          borderRadius: 17,
          enabled: !isSaving,
          onPressed: _save,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.check_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 9),
              Text(
                isSaving ? 'Saving changes...' : 'Save changes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: .10),
                shape: BoxShape.circle,
                border: Border.all(color: _red.withValues(alpha: .22)),
              ),
              child: const Icon(Icons.cloud_off_rounded, color: _red, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load owner profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _loadProfile();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF7187),
                side: BorderSide(color: _red.withValues(alpha: .4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
