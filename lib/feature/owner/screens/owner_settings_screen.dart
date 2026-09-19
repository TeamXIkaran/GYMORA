import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';


class OwnerSettingsScreen extends StatelessWidget {
  const OwnerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                _buildProfileCard(),
                const SizedBox(height: 24),

                _buildSectionTitle('Gym Management'),
                const SizedBox(height: 10),

                _buildSettingsCard(
                  children: [
                    _SettingTile(
                      icon: Icons.storefront_outlined,
                      title: 'Gym Profile',
                      subtitle: 'Manage gym name, logo and details',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.location_on_outlined,
                      title: 'Gym Location',
                      subtitle: 'Address and location details',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.access_time_rounded,
                      title: 'Working Hours',
                      subtitle: 'Set opening and closing hours',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.phone_outlined,
                      title: 'Contact Information',
                      subtitle: 'Phone, email and support details',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Account & Security'),
                const SizedBox(height: 10),

                _buildSettingsCard(
                  children: [
                    _SettingTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Owner Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.security_outlined,
                      title: 'Security',
                      subtitle: 'Manage account security',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Preferences'),
                const SizedBox(height: 10),

                _buildSettingsCard(
                  children: [
                    _buildNotificationTile(),
                    _divider(),
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme throughout the app',
                      value: true,
                      onChanged: (_) {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Gym Controls'),
                const SizedBox(height: 10),

                _buildSettingsCard(
                  children: [
                    _SettingTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage gym notifications',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.payment_outlined,
                      title: 'Payment Settings',
                      subtitle: 'Manage payment methods',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Reports & Billing',
                      subtitle: 'Revenue reports and billing',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Support'),
                const SizedBox(height: 10),

                _buildSettingsCard(
                  children: [
                    _SettingTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Get help with GYMO',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About GYMO',
                      subtitle: 'App version and information',
                      trailing: const Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildLogoutButton(),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'GYMO • STRONGER TOGETHER',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Manage your gym and account',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 25,
            spreadRadius: -8,
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
              gradient: const LinearGradient(
                colors: [Color(0xFFE62B52), Color(0xFF761326)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'RM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rohan Mehta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Owner • karan Fitness',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF42DB82),
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Verified Owner',
                      style: TextStyle(
                        color: Color(0xFF42DB82),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 58,
      color: Colors.white.withValues(alpha: 0.055),
    );
  }

  // ============================================================
  // NOTIFICATION TILE
  // ============================================================

  Widget _buildNotificationTile() {
    return _SettingTile(
      icon: Icons.notifications_none_rounded,
      title: 'Push Notifications',
      subtitle: 'Receive important gym updates',
      trailing: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF42DB82),
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {},
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          _settingIcon(icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTING TILE
  // ============================================================

  Widget _SettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              _settingIcon(icon),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white30,
                    size: 19,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SETTING ICON
  // ============================================================

  Widget _settingIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE52A50).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE52A50).withValues(alpha: 0.22),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFE84B68), size: 19),
                SizedBox(width: 9),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFE84B68),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
