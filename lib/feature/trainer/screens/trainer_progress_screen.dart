import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';

import 'package:gymora_fitness_management/feature/trainer/screens/trainer_clients_screen.dart';

class TrainerProgressScreen extends StatefulWidget {
  const TrainerProgressScreen({super.key});

  @override
  State<TrainerProgressScreen> createState() => _TrainerProgressScreenState();
}

class _TrainerProgressScreenState extends State<TrainerProgressScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color trainerYellow = Color(0xFFFFC107);
  static const Color trainerYellowLight = Color(0xFFFFD54F);
  static const Color trainerYellowDark = Color(0xFFFFA000);

  static const Color background = Color(0xFF05070C);
  static const Color cardColor = Color(0xFF0C111A);
  static const Color cardColorLight = Color(0xFF121923);
  static const Color borderColor = Color(0xFF202A36);

  // ============================================================
  // STATE
  // ============================================================

  String _selectedPeriod = 'This Week';

  final TrainerDashboardProvider _store = TrainerDashboardProvider.instance;

  // ------------------------------------------------------------
  // PERIOD CALCULATIONS (all live from the shared store)
  // ------------------------------------------------------------

  DateTime get _periodStart {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Month':
        return DateTime(now.year, now.month, 1);
      case 'Last 3 Months':
        return DateTime(now.year, now.month - 2, 1);
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return startOfWeek(now);
    }
  }

  DateTime get _periodEnd {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Month':
      case 'Last 3 Months':
        return DateTime(now.year, now.month + 1, 1);
      case 'This Year':
        return DateTime(now.year + 1, 1, 1);
      default:
        return startOfWeek(now).add(const Duration(days: 7));
    }
  }

  /// Start of the previous period of the same kind.
  DateTime get _previousStart {
    final start = _periodStart;
    switch (_selectedPeriod) {
      case 'This Month':
        return DateTime(start.year, start.month - 1, 1);
      case 'Last 3 Months':
        return DateTime(start.year, start.month - 3, 1);
      case 'This Year':
        return DateTime(start.year - 1, 1, 1);
      default:
        return start.subtract(const Duration(days: 7));
    }
  }

  String get _periodPhrase {
    switch (_selectedPeriod) {
      case 'This Month':
        return 'this month';
      case 'Last 3 Months':
        return 'in the last 3 months';
      case 'This Year':
        return 'this year';
      default:
        return 'this week';
    }
  }

  int get _completedInPeriod =>
      _store.completedBetween(_periodStart, _periodEnd);

  /// Previous period, compared over the same elapsed time so a half-finished
  /// week is compared with the first half of last week.
  int get _completedInPreviousPeriod {
    final elapsed = DateTime.now().difference(_periodStart);
    final prevStart = _previousStart;
    return _store.completedBetween(prevStart, prevStart.add(elapsed));
  }

  double get _growth {
    final previous = _completedInPreviousPeriod;
    if (previous == 0) return _completedInPeriod > 0 ? 100 : 0;
    return (_completedInPeriod - previous) / previous * 100;
  }

  String get _growthText =>
      '${_growth >= 0 ? '+' : ''}${_growth.toStringAsFixed(1)}%';

  List<_ChartData> get _chartData {
    final start = _periodStart;
    final buckets = <_ChartData>[];

    void add(String label, DateTime from, DateTime to) {
      buckets.add(
        _ChartData(
          day: label,
          value: 0,
          sessions: _store.completedBetween(from, to),
        ),
      );
    }

    switch (_selectedPeriod) {
      case 'This Month':
        final end = _periodEnd;
        var from = start;
        var week = 1;
        while (from.isBefore(end)) {
          var to = from.add(const Duration(days: 7));
          if (to.isAfter(end)) to = end;
          add('W$week', from, to);
          from = to;
          week++;
        }
        break;
      case 'Last 3 Months':
      case 'This Year':
        final months = _selectedPeriod == 'This Year' ? 12 : 3;
        for (int i = 0; i < months; i++) {
          final from = DateTime(start.year, start.month + i, 1);
          final to = DateTime(start.year, start.month + i + 1, 1);
          add(
            kMonthNames[from.month - 1].substring(0, 3).toUpperCase(),
            from,
            to,
          );
        }
        break;
      default:
        for (int i = 0; i < 7; i++) {
          final from = start.add(Duration(days: i));
          add(
            kWeekdayNames[from.weekday - 1].substring(0, 3).toUpperCase(),
            from,
            from.add(const Duration(days: 1)),
          );
        }
    }

    final maxSessions = buckets.fold<int>(
      0,
      (m, b) => b.sessions > m ? b.sessions : m,
    );
    return buckets
        .map(
          (b) => _ChartData(
            day: b.day,
            value: maxSessions == 0 ? 0 : b.sessions / maxSessions,
            sessions: b.sessions,
          ),
        )
        .toList();
  }

  bool get _streakUnlocked => _store.bestStreak >= 7;
  bool get _sessionsUnlocked => _store.totalCompleted >= 100;
  bool get _ratingUnlocked => _store.profile.rating >= 4.5;
  int get _championClients =>
      _store.clients.where((c) => c.progress >= 75).length;
  bool get _championUnlocked => _championClients >= 3;

  int get _unlockedAchievements => [
    _streakUnlocked,
    _sessionsUnlocked,
    _ratingUnlocked,
    _championUnlocked,
  ].where((u) => u).length;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // TOP GLOW
          Positioned(
            top: -120,
            right: -100,
            child: _buildGlow(size: 280, color: trainerYellow),
          ),

          Positioned(
            top: 280,
            left: -160,
            child: _buildGlow(size: 300, color: trainerYellowDark),
          ),

          SafeArea(
            child: ListenableBuilder(
              listenable: _store,
              builder: (context, _) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 24),

                    _buildPerformanceHero(),

                    const SizedBox(height: 18),

                    _buildOverviewStats(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      title: 'Weekly Performance',
                      actionText: _selectedPeriod,
                      onTap: _showPeriodSelector,
                    ),

                    const SizedBox(height: 14),

                    _buildWeeklyChart(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      title: 'Training Insights',
                      actionText: '',
                    ),

                    const SizedBox(height: 14),

                    _buildInsights(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      title: 'Client Progress',
                      actionText: 'View All',
                      onTap: _openClients,
                    ),

                    const SizedBox(height: 14),

                    ..._store.clientsByProgress.take(3).map((client) {
                      final weekStart = startOfWeek(DateTime.now());
                      final thisWeek = _store.completedForClientBetween(
                        client.id,
                        weekStart,
                        weekStart.add(const Duration(days: 7)),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildClientProgressCard(
                          name: client.name,
                          initials: client.initials,
                          goal: client.goal,
                          progress: client.progress / 100,
                          sessions: '${client.sessions} sessions',
                          change: '+$thisWeek this wk',
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    _buildSectionHeader(
                      title: 'Achievements',
                      actionText: 'View All',
                      onTap: _showAchievements,
                    ),

                    const SizedBox(height: 14),

                    _buildAchievements(),

                    const SizedBox(height: 28),

                    _buildMonthlyGoal(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GLOW
  // ============================================================

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.02),
              Colors.transparent,
            ],
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
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track your training performance',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: _showPeriodSelector,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: trainerYellow,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PERFORMANCE HERO
  // ============================================================

  Widget _buildPerformanceHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: LinearGradient(
          colors: [
            trainerYellow.withValues(alpha: 0.18),
            trainerYellow.withValues(alpha: 0.06),
            cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: trainerYellow.withValues(alpha: 0.07),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      _scoreLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      _growth >= 0
                          ? 'You are performing above your previous period.'
                          : 'Slightly below your previous period — keep pushing.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              _buildCircularProgress(
                value: _store.averageClientProgress,
                label: '${(_store.averageClientProgress * 100).round()}%',
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _heroStat(
                  icon: Icons.trending_up_rounded,
                  value: _growthText,
                  label: 'Growth',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _heroStat(
                  icon: Icons.check_circle_outline_rounded,
                  value: '$_completedInPeriod',
                  label: 'Completed',
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _heroStat(
                  icon: Icons.timer_outlined,
                  value:
                      '${(_store.minutesBetween(_periodStart, _periodEnd) / 60).round()}h',
                  label: 'Training',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _scoreLabel {
    final score = _store.averageClientProgress;
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Good';
    return 'Keep Going';
  }

  Widget _buildCircularProgress({
    required double value,
    required String label,
  }) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 7,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),

          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: trainerYellow,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SCORE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: trainerYellow, size: 18),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  // ============================================================
  // OVERVIEW STATS
  // ============================================================

  Widget _buildOverviewStats() {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.people_alt_rounded,
            value: '${_store.totalClients}',
            label: 'Clients',
            change: '${_store.countByStatus('Active')} active',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _overviewCard(
            icon: Icons.calendar_month_rounded,
            value: '$_completedInPeriod',
            label: 'Sessions',
            change: _sessionDiffText,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _overviewCard(
            icon: Icons.star_rounded,
            value: _store.profile.rating.toStringAsFixed(1),
            label: 'Rating',
            change: 'Average',
          ),
        ),
      ],
    );
  }

  String get _sessionDiffText {
    final diff = _completedInPeriod - _completedInPreviousPeriod;
    return '${diff >= 0 ? '+' : ''}$diff';
  }

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String label,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: trainerYellow.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: trainerYellow, size: 19),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.40),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            change,
            style: const TextStyle(
              color: trainerYellow,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: trainerYellow,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // WEEKLY CHART
  // ============================================================

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Sessions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sessions completed $_periodPhrase',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _growth >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: trainerYellow,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _growthText,
                      style: const TextStyle(
                        color: trainerYellow,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 205,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildChartBars(),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: trainerYellow,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Completed sessions',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    final data = _chartData;
    final hasData = data.any((d) => d.sessions > 0);
    final compact = data.length > 7;
    return List.generate(data.length, (index) {
      return Expanded(
        child: _chartBar(
          data: data[index],
          isHighest: hasData && data[index].value == 1,
          compact: compact,
        ),
      );
    });
  }

  Widget _chartBar({
    required _ChartData data,
    required bool isHighest,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 5),
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: isHighest
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: trainerYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      compact ? '${data.sessions}' : 'TOP',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : null,
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 1,
                      height: constraints.maxHeight,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: data.value,
                        child: Container(
                          width: compact ? 10 : 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: const LinearGradient(
                              colors: [trainerYellowLight, trainerYellowDark],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: trainerYellow.withValues(alpha: 0.18),
                                blurRadius: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            data.day,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRAINING INSIGHTS
  // ============================================================

  Widget _buildInsights() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _insightCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Best Streak',
                value: '${_store.bestStreak} Days',
                subtitle: 'Consistency',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _insightCard(
                icon: Icons.timer_rounded,
                title: 'Avg. Session',
                value: '${_store.averageSessionMinutes.round()} Min',
                subtitle: 'Per session',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _insightCard(
                icon: Icons.fitness_center_rounded,
                title: 'Workouts',
                value: '${_store.totalCompleted}',
                subtitle: 'Completed',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _insightCard(
                icon: Icons.emoji_events_rounded,
                title: 'Achievements',
                value: '$_unlockedAchievements / 4',
                subtitle: 'Unlocked',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          const SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              color: trainerYellow.withValues(alpha: 0.75),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLIENT PROGRESS
  // ============================================================

  Widget _buildClientProgressCard({
    required String name,
    required String initials,
    required String goal,
    required double progress,
    required String sessions,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      trainerYellow.withValues(alpha: 0.20),
                      trainerYellow.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: trainerYellow.withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: trainerYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: trainerYellow,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      trainerYellow,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: trainerYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white.withValues(alpha: 0.28),
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                sessions,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Training Progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Widget _buildAchievements() {
    return Row(
      children: [
        Expanded(
          child: _achievementCard(
            icon: Icons.local_fire_department_rounded,
            title: '${_store.bestStreak} Day',
            subtitle: 'Streak',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _achievementCard(
            icon: Icons.fitness_center_rounded,
            title: _store.totalCompleted >= 100
                ? '100+'
                : '${_store.totalCompleted}',
            subtitle: 'Sessions',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _achievementCard(
            icon: Icons.star_rounded,
            title: _store.profile.rating.toStringAsFixed(1),
            subtitle: 'Rating',
          ),
        ),
      ],
    );
  }

  Widget _achievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.10),
              border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: trainerYellow, size: 20),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTHLY GOAL
  // ============================================================

  Widget _buildMonthlyGoal() {
    const goal = TrainerDashboardProvider.monthlySessionGoal;
    final done = _store.completedThisMonth;
    final double progress = done >= goal ? 1.0 : done / goal;
    final remaining = done >= goal ? 0 : goal - done;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [trainerYellow.withValues(alpha: 0.13), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: trainerYellow.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: trainerYellow.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: trainerYellow,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete $goal training sessions',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              ),

              Text(
                '$done / $goal',
                style: TextStyle(
                  color: trainerYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: const AlwaysStoppedAnimation<Color>(trainerYellow),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Text(
                '${(progress * 100).round()}% completed',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                remaining == 0
                    ? 'Goal reached'
                    : '$remaining sessions remaining',
                style: TextStyle(
                  color: trainerYellow.withValues(alpha: 0.75),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
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

              const SizedBox(height: 22),

              const Text(
                'Performance Period',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Select the period you want to analyze.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 18),

              _periodOption(
                sheetContext,
                title: 'This Week',
                subtitle: 'Last 7 days',
                icon: Icons.calendar_view_week_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'This Month',
                subtitle: 'Current month',
                icon: Icons.calendar_month_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'Last 3 Months',
                subtitle: 'Long-term performance',
                icon: Icons.insights_rounded,
              ),

              const SizedBox(height: 10),

              _periodOption(
                sheetContext,
                title: 'This Year',
                subtitle: 'Yearly performance',
                icon: Icons.auto_graph_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _periodOption(
    BuildContext sheetContext, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedPeriod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = title;
        });

        Navigator.pop(sheetContext);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? trainerYellow.withValues(alpha: 0.09) : cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? trainerYellow.withValues(alpha: 0.35)
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: trainerYellow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: trainerYellow, size: 21),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: trainerYellow,
                size: 21,
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLIENTS
  // ============================================================

  void _openClients() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerClientsScreen()),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  void _showAchievements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: cardColorLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

              const SizedBox(height: 22),

              const Text(
                'Your Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              _achievementRow(
                icon: Icons.local_fire_department_rounded,
                title: '7 Day Streak',
                subtitle:
                    'Best streak so far: ${_store.bestStreak} days in a row',
                unlocked: _streakUnlocked,
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.fitness_center_rounded,
                title: '100+ Sessions',
                subtitle: '${_store.totalCompleted} sessions completed so far',
                unlocked: _sessionsUnlocked,
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.star_rounded,
                title: 'Top Rated Trainer',
                subtitle:
                    'Keep a 4.5+ rating (now ${_store.profile.rating.toStringAsFixed(1)})',
                unlocked: _ratingUnlocked,
              ),

              const SizedBox(height: 10),

              _achievementRow(
                icon: Icons.people_alt_rounded,
                title: 'Client Champion',
                subtitle: '$_championClients clients at 75%+ progress (need 3)',
                unlocked: _championUnlocked,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _achievementRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trainerYellow.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: trainerYellow, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? trainerYellow : Colors.white24,
            size: 19,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHART MODEL
// ============================================================

class _ChartData {
  final String day;
  final double value;
  final int sessions;

  const _ChartData({
    required this.day,
    required this.value,
    required this.sessions,
  });
}
