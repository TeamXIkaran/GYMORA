import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';


class OwnerNotificationScreen extends StatelessWidget {
  const OwnerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildNotificationList()),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 17,
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stay updated with your gym',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION LIST
  // ============================================================

  Widget _buildNotificationList() {
    final notifications = [
      _NotificationData(
        icon: Icons.card_membership_rounded,
        title: 'Membership Expiring',
        message: 'Aarav Sharma\'s Premium membership expires in 3 days.',
        time: '10 min ago',
        type: NotificationType.warning,
        unread: true,
      ),
      _NotificationData(
        icon: Icons.person_add_alt_1_rounded,
        title: 'New Member Added',
        message: 'Neha Singh has joined your gym with Standard Plan.',
        time: '32 min ago',
        type: NotificationType.member,
        unread: true,
      ),
      _NotificationData(
        icon: Icons.currency_rupee_rounded,
        title: 'Payment Received',
        message: '₹10,000 payment received from Rahul Verma.',
        time: '1 hour ago',
        type: NotificationType.payment,
        unread: true,
      ),
      _NotificationData(
        icon: Icons.fitness_center_rounded,
        title: 'Trainer Update',
        message: 'Amit Verma completed today\'s training schedule.',
        time: '2 hours ago',
        type: NotificationType.trainer,
        unread: false,
      ),
      _NotificationData(
        icon: Icons.card_membership_rounded,
        title: 'Membership Expired',
        message: 'Priya Patel\'s Basic membership has expired.',
        time: '4 hours ago',
        type: NotificationType.danger,
        unread: false,
      ),
      _NotificationData(
        icon: Icons.people_alt_rounded,
        title: 'Member Attendance',
        message: '42 members checked in at your gym today.',
        time: '5 hours ago',
        type: NotificationType.activity,
        unread: false,
      ),
      _NotificationData(
        icon: Icons.trending_up_rounded,
        title: 'Monthly Revenue',
        message: 'Your monthly revenue has increased by 18%.',
        time: 'Yesterday',
        type: NotificationType.success,
        unread: false,
      ),
      _NotificationData(
        icon: Icons.person_outline_rounded,
        title: 'Trainer Added',
        message: 'Rakesh Yadav has been added to your trainer team.',
        time: 'Yesterday',
        type: NotificationType.trainer,
        unread: false,
      ),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 30),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(notifications[index]);
      },
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(_NotificationData notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.unread
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: notification.unread
              ? AppColors.primary.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: notification.unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),

                      if (notification.unread)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    notification.time,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION ICON
  // ============================================================

  Widget _buildNotificationIcon(_NotificationData notification) {
    Color iconColor;
    Color backgroundColor;

    switch (notification.type) {
      case NotificationType.warning:
        iconColor = const Color(0xFFFFB84D);
        backgroundColor = const Color(0xFFFFB84D).withValues(alpha: 0.10);
        break;

      case NotificationType.member:
        iconColor = const Color(0xFF4DDB88);
        backgroundColor = const Color(0xFF4DDB88).withValues(alpha: 0.10);
        break;

      case NotificationType.payment:
        iconColor = const Color(0xFF54B8FF);
        backgroundColor = const Color(0xFF54B8FF).withValues(alpha: 0.10);
        break;

      case NotificationType.trainer:
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.10);
        break;

      case NotificationType.danger:
        iconColor = const Color(0xFFFF536F);
        backgroundColor = const Color(0xFFFF536F).withValues(alpha: 0.10);
        break;

      case NotificationType.activity:
        iconColor = const Color(0xFFB57CFF);
        backgroundColor = const Color(0xFFB57CFF).withValues(alpha: 0.10);
        break;

      case NotificationType.success:
        iconColor = const Color(0xFF42DB82);
        backgroundColor = const Color(0xFF42DB82).withValues(alpha: 0.10);
        break;
    }

    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: iconColor.withValues(alpha: 0.16)),
      ),
      child: Icon(notification.icon, color: iconColor, size: 20),
    );
  }
}

// ============================================================
// NOTIFICATION MODEL
// ============================================================

enum NotificationType {
  warning,
  member,
  payment,
  trainer,
  danger,
  activity,
  success,
}

class _NotificationData {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool unread;

  const _NotificationData({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.unread,
  });
}
