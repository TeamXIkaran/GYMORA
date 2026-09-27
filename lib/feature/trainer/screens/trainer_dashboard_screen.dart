import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';

import 'package:gymora_fitness_management/feature/trainer/screens/trainer_clients_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_profile_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_progress_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/screens/trainer_schedule_screen.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_state_views.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_widget.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 0;

  late AnimationController _particleController;

  final TrainerDashboardProvider _store = TrainerDashboardProvider.instance;

  static const Color trainerYellow = Color(0xFFFFC107);
  static const Color trainerYellowLight = Color(0xFFFFD54F);
  static const Color trainerYellowDark = Color(0xFFFFA000);

  static const Color background = Color(0xFF05070C);
  static const Color cardColor = Color(0xFF0C111A);
  static const Color borderColor = Color(0xFF202A36);

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Load profile, clients, sessions, dashboard and progress from the API.
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.loadAll());
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: ListenableBuilder(
              listenable: _store,
              builder: (context, _) {
                if (_store.isLoading && !_store.hasLoaded) {
                  return const TrainerLoadingView(
                    message: 'Loading your dashboard...',
                  );
                }
                if (!_store.hasLoaded && _store.error != null) {
                  return TrainerErrorView(
                    message: _store.error!,
                    onRetry: _store.refreshAll,
                  );
                }
                return RefreshIndicator(
                  color: trainerYellow,
                  backgroundColor: cardColor,
                  onRefresh: _store.refreshAll,
                  child: _buildDashboard(),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

  void _openSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerScheduleScreen()),
    );
  }

  void _openClients() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerClientsScreen()),
    );
  }

  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerProgressScreen()),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    final upcomingToday = _store.todaysUpcoming;
    final topClients = _store.clientsByProgress.take(3).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_store.error != null)
            TrainerErrorBanner(
              message: _store.error!,
              onRetry: _store.refreshAll,
            ),

          _buildHeader(),

          const SizedBox(height: 26),

          _buildWelcomeSection(),

          const SizedBox(height: 22),

          _buildStatsSection(),

          const SizedBox(height: 26),

          _buildSectionHeader(
            title: 'Today\'s Schedule',
            actionText: 'View All',
            onTap: _openSchedule,
          ),

          const SizedBox(height: 14),

          if (upcomingToday.isEmpty)
            _buildEmptyScheduleCard()
          else
            ...upcomingToday
                .take(3)
                .map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildScheduleCard(session),
                  ),
                ),

          const SizedBox(height: 16),

          _buildSectionHeader(
            title: 'My Clients',
            actionText: 'View All',
            onTap: _openClients,
          ),

          const SizedBox(height: 14),

          if (topClients.isEmpty)
            _buildNoClientsCard()
          else
            ...topClients.map(
              (client) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildClientCard(client),
              ),
            ),

          const SizedBox(height: 16),

          _buildSectionHeader(title: 'Quick Actions', actionText: ''),

          const SizedBox(height: 14),

          _buildQuickActions(),

          const SizedBox(height: 28),

          _buildSectionHeader(
            title: 'Weekly Performance',
            actionText: 'Details',
            onTap: _openProgress,
          ),

          const SizedBox(height: 14),

          _buildPerformanceCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  Widget _buildHeader() {
    final profile = _store.profile;
    final name = profile?.name ?? 'Trainer';

    return Row(
      children: [
        // PROFILE PHOTO
        GestureDetector(
          onTap: _openTrainerProfile,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [trainerYellowLight, trainerYellowDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: trainerYellow.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initialsOf(name),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                (profile?.specialization.isNotEmpty ?? false)
                    ? '${profile!.specialization} • GYMORA'
                    : 'Trainer • GYMORA',
                style: TextStyle(
                  color: trainerYellow.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        _headerIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/trainerNotifications');
          },
        ),

        const SizedBox(width: 8),

        _headerIconButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(context, '/trainerSettings');
          },
        ),
      ],
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 21),
      ),
    );
  }

  void _openTrainerProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerProfileScreen()),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [trainerYellow.withValues(alpha: 0.14), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Strong.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Keep your clients moving forward.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.12),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: trainerYellow,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.people_alt_rounded,
            value:
                (_store.dashboard.totalClients > 0
                        ? _store.dashboard.totalClients
                        : _store.totalClients)
                    .toString()
                    .padLeft(2, '0'),
            label: 'Clients',
            onTap: _openClients,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.calendar_today_rounded,
            value: _store.todaysSessions.length.toString().padLeft(2, '0'),
            label: 'Today',
            onTap: _openSchedule,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.task_alt_rounded,
            value: _store.dashboard.totalCompletedSessions.toString().padLeft(
              2,
              '0',
            ),
            label: 'Completed',
            onTap: _openProgress,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: trainerYellow, size: 21),
            const SizedBox(height: 13),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                color: trainerYellow,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  Widget _buildScheduleCard(TrainingSession session) {
    final clientName = session.clientName.isNotEmpty
        ? session.clientName
        : _store.clientById(session.clientId)?.name ?? 'Unknown client';

    return GestureDetector(
      onTap: () => showSessionDetailsSheet(context, session),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                TrainerOptions.iconForType(session.type),
                color: trainerYellow,
                size: 23,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatTime(session.start)} - ${formatTime(session.end)}',
                    style: const TextStyle(
                      color: trainerYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$clientName • ${session.location.isEmpty ? '${session.durationMinutes} min' : session.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScheduleCard() {
    final hadSessions = _store.todaysSessions.isNotEmpty;

    return GestureDetector(
      onTap: () => showSessionFormSheet(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                hadSessions
                    ? Icons.task_alt_rounded
                    : Icons.event_available_rounded,
                color: trainerYellow,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hadSessions
                        ? 'All sessions completed today'
                        : 'No sessions scheduled today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to add a session',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_rounded, color: trainerYellow),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLIENTS
  // ============================================================

  Widget _buildClientCard(TrainerClient client) {
    final progress = client.progress / 100;

    return GestureDetector(
      onTap: _openClients,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: trainerYellow.withValues(alpha: 0.12),
                border: Border.all(
                  color: trainerYellow.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: Text(
                  client.initials,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.planName} • ${client.completedSessions} sessions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        trainerYellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '${client.progress}%',
              style: const TextStyle(
                color: trainerYellow,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoClientsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        'No clients assigned yet. Your gym owner will assign clients to you.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 12,
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    // "Add Client" removed — clients are assigned to trainers by the owner.
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.people_alt_rounded,
            label: 'My Clients',
            onTap: _openClients,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.add_task_rounded,
            label: 'Add Session',
            onTap: () => showSessionFormSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.assignment_rounded,
            label: 'Workout',
            onTap: () => pickClientAndAssignWorkout(context),
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: trainerYellow, size: 21),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PERFORMANCE (live — sessions per day this week)
  // ============================================================

  Widget _buildPerformanceCard() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekStart = startOfWeek(DateTime.now());
    // Weekly numbers from GET /trainers/dashboard; falls back to the loaded
    // session list if the API returns no weekly data.
    final fromApi = {
      for (final d in _store.dashboard.weeklySessions) d.day: d.sessions,
    };
    final counts = List.generate(
      7,
      (i) =>
          fromApi[labels[i]] ??
          _store.sessionsOn(weekStart.add(Duration(days: i))).length,
    );
    final maxCount = math.max(1, counts.reduce(math.max));

    final int thisWeek = counts.fold<int>(0, (a, b) => a + b);
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    int lastWeek = 0;
    for (int i = 0; i < 7; i++) {
      lastWeek += _store
          .sessionsOn(lastWeekStart.add(Duration(days: i)))
          .length;
    }
    final growth = lastWeek == 0 ? 0.0 : (thisWeek - lastWeek) / lastWeek * 100;
    final growthText = '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%';

    return GestureDetector(
      onTap: _openProgress,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Training Sessions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  growthText,
                  style: TextStyle(
                    color: growth >= 0 ? trainerYellow : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  7,
                  (i) => _chartBar(labels[i], counts[i] / maxCount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartBar(String day, double value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: value,
                child: Container(
                  width: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [trainerYellowLight, trainerYellowDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: trainerYellow.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            day,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'Clients',
      ),
      _NavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'Schedule',
      ),
      _NavItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights_rounded,
        label: 'Progress',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080C12),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    switch (index) {
                      case 1:
                        _openClients();
                        break;
                      case 2:
                        _openSchedule();
                        break;
                      case 3:
                        _openProgress();
                        break;
                      case 4:
                        _openTrainerProfile();
                        break;
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: isSelected ? 44 : 38,
                          height: isSelected ? 32 : 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? trainerYellow.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? trainerYellow
                                : Colors.white.withValues(alpha: 0.40),
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? trainerYellow
                                : Colors.white.withValues(alpha: 0.40),
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NAV ITEM MODEL
// ============================================================

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ============================================================
// PARTICLE PAINTER
// ============================================================

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;

      final baseY = random.nextDouble() * size.height;

      final movement = math.sin((progress * math.pi * 2) + i) * 10;

      final y = baseY + movement;

      final radius = 0.5 + random.nextDouble() * 1.2;

      paint.color = const Color(
        0xFFFFC107,
      ).withValues(alpha: 0.025 + random.nextDouble() * 0.05);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
