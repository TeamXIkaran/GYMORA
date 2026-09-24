import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  static const Color trainerYellow = Color(0xFFFFC107);

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                child: const Center(
                  child: Text(
                    'AK',
                    style: TextStyle(
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

          const Text(
            'Amit Kumar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Professional Fitness Trainer',
            style: TextStyle(
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: trainerYellow, size: 14),
                SizedBox(width: 6),
                Text(
                  'ACTIVE TRAINER',
                  style: TextStyle(
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
              onPressed: () {
                // Edit profile
              },
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
          value: 'Amit Kumar',
        ),
        _divider(),
        _infoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'amit.kumar@gmail.com',
        ),
        _divider(),
        _infoTile(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: '+91 98765 43210',
        ),
        _divider(),
        _infoTile(
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: 'New Delhi, India',
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
          value: 'Strength & Fitness',
        ),
        _divider(),
        _infoTile(
          icon: Icons.badge_outlined,
          title: 'Experience',
          value: '5+ Years',
        ),
        _divider(),
        _infoTile(
          icon: Icons.school_outlined,
          title: 'Certification',
          value: 'Certified Fitness Trainer',
        ),
        _divider(),
        _infoTile(
          icon: Icons.groups_outlined,
          title: 'Clients',
          value: '24 Active Clients',
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
          icon: Icons.business_rounded,
          title: 'Gym Name',
          value: 'GYMO Fitness',
        ),
        _divider(),
        _infoTile(icon: Icons.tag_rounded, title: 'Gym ID', value: 'GYMO07'),
        _divider(),
        _infoTile(
          icon: Icons.work_outline_rounded,
          title: 'Role',
          value: 'Trainer',
        ),
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
                child: _statItem(value: '24', title: 'Clients'),
              ),
              _verticalDivider(),
              Expanded(
                child: _statItem(value: '156', title: 'Sessions'),
              ),
              _verticalDivider(),
              Expanded(
                child: _statItem(value: '92%', title: 'Success'),
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
          onTap: () {},
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
    showDialog(
      context: context,
      builder: (context) {
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
              onPressed: () {
                Navigator.pop(context);
              },
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
              onPressed: () {
                Navigator.pop(context);

                // Add your actual logout logic here.
                // Example:
                // context.read<AuthProvider>().logout();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
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
