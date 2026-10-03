import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_state_views.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_widget.dart';

class TrainerScheduleScreen extends StatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color _yellow = const Color(0xFFFFC107);
  final Color _yellowLight = const Color(0xFFFFD54F);
  final Color _yellowDark = const Color(0xFFFFA000);

  final Color _background = const Color(0xFF05070C);
  final Color _cardColor = const Color(0xFF10141D);

  final Color _green = const Color(0xFF22C55E);
  final Color _blue = const Color(0xFF38BDF8);

  final TrainerDashboardProvider _store = TrainerDashboardProvider.instance;

  DateTime _selectedDate = dateOnly(DateTime.now());

  /// 'All Sessions' | 'Upcoming' | 'Completed'
  String _filter = 'All Sessions';

  List<DateTime> get _weekDays {
    final start = startOfWeek(_selectedDate);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  List<TrainingSession> get _daySessions => _store.sessionsOn(_selectedDate);

  List<TrainingSession> get _visibleSessions {
    final sessions = _daySessions;
    switch (_filter) {
      case 'Upcoming':
        return sessions.where((s) => !s.isCompleted).toList();
      case 'Completed':
        return sessions.where((s) => s.isCompleted).toList();
      default:
        return sessions;
    }
  }

  bool get _isTodaySelected => isSameDay(_selectedDate, DateTime.now());

  @override
  void initState() {
    super.initState();
    // GET /trainers/sessions — always pull the latest list when opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_store.hasLoaded) {
        _store.refreshSessions();
      } else {
        _store.loadAll();
      }
    });
  }

  Future<void> _refresh() => _store.refreshDashboard();

  String _clientNameOf(TrainingSession s) => s.clientName.isNotEmpty
      ? s.clientName
      : _store.clientById(s.clientId)?.name ?? 'Unknown client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF080B12), Color(0xFF05070C), Color(0xFF090D14)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // TOP GLOW
              Positioned(
                top: -130,
                right: -90,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _yellow.withValues(alpha: 0.045),
                  ),
                ),
              ),

              // SECOND GLOW
              Positioned(
                top: 300,
                left: -160,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue.withValues(alpha: 0.025),
                  ),
                ),
              ),

              ListenableBuilder(
                listenable: _store,
                builder: (context, _) {
                  if (_store.isLoading && !_store.hasLoaded) {
                    return const TrainerLoadingView(
                      message: 'Loading your schedule...',
                    );
                  }
                  if (!_store.hasLoaded && _store.error != null) {
                    return TrainerErrorView(
                      message: _store.error!,
                      onRetry: _store.loadAll,
                    );
                  }
                  return Column(
                    children: [
                      _buildHeader(),

                      Expanded(
                        child: RefreshIndicator(
                          color: _yellow,
                          backgroundColor: _cardColor,
                          onRefresh: _refresh,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_store.error != null)
                                  TrainerErrorBanner(
                                    message: _store.error!,
                                    onRetry: _refresh,
                                  ),

                                _buildTodayHero(),

                                const SizedBox(height: 18),

                                _buildSummaryStats(),

                                const SizedBox(height: 25),

                                _buildDateSelector(),

                                const SizedBox(height: 28),

                                _buildScheduleHeader(),

                                const SizedBox(height: 16),

                                if (_store.isLoading && !_store.hasLoaded)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: TrainerLoadingView(
                                      message: 'Loading sessions...',
                                    ),
                                  )
                                else
                                  _buildScheduleTimeline(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 15),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Plan your day. Train better.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _buildIconButton(
            icon: Icons.calendar_month_rounded,
            onTap: _showCalendarDialog,
          ),

          const SizedBox(width: 8),

          _buildIconButton(
            icon: Icons.more_vert_rounded,
            onTap: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.85),
            size: 19,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TODAY HERO
  // ============================================================

  Widget _buildTodayHero() {
    final now = DateTime.now();
    final todayCount = _store.todaysSessions.length;
    final upcoming = _store.todaysUpcoming.length;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = dateOnly(now)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _yellow.withValues(alpha: 0.15),
              _yellow.withValues(alpha: 0.045),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: _yellow.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: _yellow.withValues(alpha: 0.05),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_yellowLight, _yellowDark]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _yellow.withValues(alpha: 0.22),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.today_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kWeekdayNames[now.weekday - 1].toUpperCase(),
                    style: TextStyle(
                      color: _yellow,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatLongDate(now),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todayCount == 0
                        ? 'No training sessions today'
                        : 'You have $todayCount training session${todayCount == 1 ? '' : 's'} today',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.43),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: (upcoming > 0 ? _green : Colors.white).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: (upcoming > 0 ? _green : Colors.white).withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: upcoming > 0 ? _green : Colors.white54,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    upcoming > 0 ? 'Active' : 'Done',
                    style: TextStyle(
                      color: upcoming > 0 ? _green : Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
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
  // SUMMARY (for the selected day)
  // ============================================================

  Widget _buildSummaryStats() {
    final sessions = _daySessions;
    final completed = sessions.where((s) => s.isCompleted).length;
    final upcoming = sessions.length - completed;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: sessions.length.toString().padLeft(2, '0'),
            label: 'Sessions',
            icon: Icons.event_available_rounded,
            color: _yellow,
            onTap: () => setState(() => _filter = 'All Sessions'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: upcoming.toString().padLeft(2, '0'),
            label: 'Upcoming',
            icon: Icons.schedule_rounded,
            color: _blue,
            onTap: () => setState(() => _filter = 'Upcoming'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: completed.toString().padLeft(2, '0'),
            label: 'Completed',
            icon: Icons.check_circle_outline_rounded,
            color: _green,
            onTap: () => setState(() => _filter = 'Completed'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: _cardColor.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: color),
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _buildDateSelector() {
    final days = _weekDays;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${kMonthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = dateOnly(DateTime.now());
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _yellow.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _yellow.withValues(alpha: 0.16)),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: _yellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final day = days[index];
              final selected = isSameDay(day, _selectedDate);
              final isToday = isSameDay(day, today);
              final hasSessions = _store.sessionsOn(day).isNotEmpty;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 60,
                  decoration: BoxDecoration(
                    color: selected
                        ? _yellow
                        : Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? _yellow
                          : isToday
                          ? _yellow.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _yellow.withValues(alpha: 0.18),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kWeekdayNames[day.weekday - 1]
                            .substring(0, 3)
                            .toUpperCase(),
                        style: TextStyle(
                          color: selected
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.38),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (selected || hasSessions)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : _yellow,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCHEDULE HEADER
  // ============================================================

  Widget _buildScheduleHeader() {
    final count = _visibleSessions.length;
    final filterSuffix = _filter == 'All Sessions' ? '' : ' • $_filter';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isTodaySelected ? 'Today\'s Sessions' : 'Sessions',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatFullDate(_selectedDate)}$filterSuffix',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _yellow.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _yellow.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: _yellow, size: 14),
              const SizedBox(width: 5),
              Text(
                '$count Session${count == 1 ? '' : 's'}',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildScheduleTimeline() {
    final sessions = _visibleSessions;

    if (sessions.isEmpty) return _buildEmptyState();

    return Column(
      children: List.generate(sessions.length, (index) {
        return _buildTimelineSession(
          session: sessions[index],
          isLast: index == sessions.length - 1,
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    final canAdd = !_selectedDate.isBefore(dateOnly(DateTime.now()));

    return GestureDetector(
      onTap: canAdd ? _openAddSession : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, color: _yellow, size: 42),
            const SizedBox(height: 14),
            Text(
              _filter == 'All Sessions'
                  ? 'No sessions on this day'
                  : 'No ${_filter.toLowerCase()} sessions',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              canAdd ? 'Tap here to add a session.' : 'Pick another day.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSession({
    required TrainingSession session,
    required bool isLast,
  }) {
    final bool completed = session.isCompleted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TIME + LINE
        SizedBox(
          width: 72,
          child: Column(
            children: [
              Text(
                formatTime(session.start),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: completed ? Colors.white38 : _yellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: completed ? _green : _yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: _background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: (completed ? _green : _yellow).withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              if (!isLast)
                Container(
                  width: 1,
                  height: 235,
                  margin: const EdgeInsets.only(top: 3),
                  color: Colors.white.withValues(alpha: 0.07),
                ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        // CARD
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDetailedSessionCard(session, completed),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAILED SESSION CARD
  // ============================================================

  Widget _buildDetailedSessionCard(TrainingSession session, bool completed) {
    final clientName = _clientNameOf(session);
    final Color sessionColor = TrainerOptions.colorForType(session.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () => showSessionDetailsSheet(context, session),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _cardColor.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: completed
                  ? _green.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.065),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // TOP ROW
              Row(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          sessionColor,
                          sessionColor.withValues(alpha: 0.65),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: sessionColor.withValues(alpha: 0.16),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initialsOf(clientName),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.membershipPlan.isNotEmpty
                              ? '${titleCase(session.membershipPlan)} Plan'
                              : 'ID ${session.clientId}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  sessionStatusPill(session),
                ],
              ),

              const SizedBox(height: 15),

              // SESSION TYPE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _yellow.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        TrainerOptions.iconForType(session.type),
                        color: _yellow,
                        size: 15,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        session.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      _store.sessionNumber(session),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              // INFO
              Row(
                children: [
                  Expanded(
                    child: _buildSmallInfo(
                      icon: Icons.timer_outlined,
                      title: 'Duration',
                      value: '${session.durationMinutes} min',
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),

                  Expanded(
                    child: _buildSmallInfo(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Calories',
                      value: session.calories,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),

                  Expanded(
                    child: _buildSmallInfo(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: session.location.isEmpty
                          ? '-'
                          : session.location
                                .split(RegExp(r'[•-]'))
                                .first
                                .trim(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.055),
              ),

              const SizedBox(height: 11),

              // BOTTOM ACTION ROW
              Row(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.notifications_none_rounded,
                    size: 14,
                    color: completed ? _green : _yellow,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      completed
                          ? 'Session completed successfully'
                          : '${formatTime(session.start)} - ${formatTime(session.end)} • Tap for actions',
                      style: TextStyle(
                        color: completed
                            ? _green.withValues(alpha: 0.72)
                            : Colors.white.withValues(alpha: 0.38),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.30),
                      size: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Icon(icon, color: _yellow.withValues(alpha: 0.75), size: 14),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING ADD BUTTON
  // ============================================================

  void _openAddSession() {
    showSessionFormSheet(context, initialDate: _selectedDate);
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _openAddSession,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_yellowLight, _yellow]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _yellow.withValues(alpha: 0.30),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.black, size: 20),
            SizedBox(width: 7),
            Text(
              'Add Session',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  Future<void> _showCalendarDialog() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _yellow,
              onPrimary: Colors.black,
              surface: const Color(0xFF11151E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = dateOnly(picked));
    }
  }

  // ============================================================
  // MORE OPTIONS
  // ============================================================

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11151E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),

              ListTile(
                leading: Icon(Icons.filter_list_rounded, color: _yellow),
                title: const Text(
                  'Filter Sessions',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Showing: $_filter',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showFilterDialog();
                },
              ),

              ListTile(
                leading: Icon(Icons.view_week_rounded, color: _yellow),
                title: const Text(
                  'Week View',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'View your complete weekly schedule',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showWeekView();
                },
              ),

              ListTile(
                leading: Icon(Icons.download_rounded, color: _yellow),
                title: const Text(
                  'Export Schedule',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Copy this week\'s schedule to share',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _exportWeek();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportWeek() async {
    final buffer = StringBuffer()
      ..writeln('GYMORA — ${_store.profile?.name ?? 'Trainer'}\'s Schedule')
      ..writeln(
        '${formatLongDate(_weekDays.first)} - ${formatLongDate(_weekDays.last)}',
      );

    for (final day in _weekDays) {
      final sessions = _store.sessionsOn(day);
      buffer
        ..writeln()
        ..writeln(formatFullDate(day));
      if (sessions.isEmpty) {
        buffer.writeln('  No sessions');
      }
      for (final s in sessions) {
        buffer.writeln(
          '  ${formatTime(s.start)} - ${formatTime(s.end)}  '
          '${_clientNameOf(s)} • ${s.type} • ${s.location} (${s.statusLabel})',
        );
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    showTrainerSnack(
      context,
      'Week schedule copied — paste it anywhere to share',
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11151E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose which sessions you want to see.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 20),

                _filterOption(
                  sheetContext,
                  icon: Icons.all_inclusive_rounded,
                  title: 'All Sessions',
                ),

                _filterOption(
                  sheetContext,
                  icon: Icons.schedule_rounded,
                  title: 'Upcoming',
                ),

                _filterOption(
                  sheetContext,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Completed',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterOption(
    BuildContext sheetContext, {
    required IconData icon,
    required String title,
  }) {
    final selected = _filter == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: selected
            ? _yellow.withValues(alpha: 0.09)
            : Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected
              ? _yellow.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? _yellow : Colors.white38),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: _yellow, size: 20)
            : null,
        onTap: () {
          setState(() => _filter = title);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  // ============================================================
  // WEEK VIEW
  // ============================================================

  void _showWeekView() {
    final days = _weekDays;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11151E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.65,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weekly Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${formatLongDate(days.first)} - ${formatLongDate(days.last)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: days.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final selected = isSameDay(day, _selectedDate);
                        final sessions = _store.sessionsOn(day);
                        final done = sessions
                            .where((s) => s.isCompleted)
                            .length;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _yellow.withValues(alpha: 0.09)
                                  : Colors.white.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: selected
                                    ? _yellow.withValues(alpha: 0.17)
                                    : Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? _yellow
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        kWeekdayNames[day.weekday - 1]
                                            .substring(0, 3)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.black
                                              : Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatFullDate(day),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        sessions.isEmpty
                                            ? 'No sessions'
                                            : '${sessions.length} training session${sessions.length == 1 ? '' : 's'} • $done completed',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.38,
                                          ),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
}
