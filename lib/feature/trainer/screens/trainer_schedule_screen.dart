import 'package:flutter/material.dart';

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
  final Color _cardLight = const Color(0xFF151B25);

  final Color _green = const Color(0xFF22C55E);
  final Color _blue = const Color(0xFF38BDF8);
  final Color _red = const Color(0xFFFF5252);

  int _selectedDay = 0;

  final List<Map<String, dynamic>> _days = [
    {'day': 'MON', 'date': '16', 'fullDate': 'Monday, September 16'},
    {'day': 'TUE', 'date': '17', 'fullDate': 'Tuesday, September 17'},
    {'day': 'WED', 'date': '18', 'fullDate': 'Wednesday, September 18'},
    {'day': 'THU', 'date': '19', 'fullDate': 'Thursday, September 19'},
    {'day': 'FRI', 'date': '20', 'fullDate': 'Friday, September 20'},
    {'day': 'SAT', 'date': '21', 'fullDate': 'Saturday, September 21'},
    {'day': 'SUN', 'date': '22', 'fullDate': 'Sunday, September 22'},
  ];

  final List<Map<String, dynamic>> _sessions = [
    {
      'time': '10:30 AM',
      'endTime': '11:30 AM',
      'name': 'Aarav Sharma',
      'goal': 'Weight Loss',
      'type': 'Personal Training',
      'status': 'Upcoming',
      'avatar': 'AS',
      'duration': '60 min',
      'location': 'Gym Floor • Zone A',
      'calories': '420 kcal',
      'sessionNo': 'Session 08',
      'color': Color(0xFFFFC107),
    },
    {
      'time': '12:00 PM',
      'endTime': '01:00 PM',
      'name': 'Neha Singh',
      'goal': 'Muscle Gain',
      'type': 'Strength Training',
      'status': 'Upcoming',
      'avatar': 'NS',
      'duration': '60 min',
      'location': 'Weight Area • Zone B',
      'calories': '510 kcal',
      'sessionNo': 'Session 12',
      'color': Color(0xFF38BDF8),
    },
    {
      'time': '02:30 PM',
      'endTime': '03:15 PM',
      'name': 'Riya Kapoor',
      'goal': 'Fat Loss',
      'type': 'HIIT Workout',
      'status': 'Completed',
      'avatar': 'RK',
      'duration': '45 min',
      'location': 'Functional Area',
      'calories': '460 kcal',
      'sessionNo': 'Session 06',
      'color': Color(0xFF22C55E),
    },
    {
      'time': '04:30 PM',
      'endTime': '05:30 PM',
      'name': 'Rahul Verma',
      'goal': 'Strength',
      'type': 'Personal Training',
      'status': 'Upcoming',
      'avatar': 'RV',
      'duration': '60 min',
      'location': 'Gym Floor • Zone A',
      'calories': '540 kcal',
      'sessionNo': 'Session 15',
      'color': Color(0xFFFFA000),
    },
    {
      'time': '06:00 PM',
      'endTime': '07:00 PM',
      'name': 'Ananya Gupta',
      'goal': 'Fitness',
      'type': 'Cardio Training',
      'status': 'Upcoming',
      'avatar': 'AG',
      'duration': '60 min',
      'location': 'Cardio Zone',
      'calories': '390 kcal',
      'sessionNo': 'Session 04',
      'color': Color(0xFFFFC107),
    },
  ];

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

              Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTodayHero(),

                          const SizedBox(height: 18),

                          _buildSummaryStats(),

                          const SizedBox(height: 25),

                          _buildDateSelector(),

                          const SizedBox(height: 28),

                          _buildScheduleHeader(),

                          const SizedBox(height: 16),

                          _buildScheduleTimeline(),
                        ],
                      ),
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
    return Container(
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
                  'MONDAY',
                  style: TextStyle(
                    color: _yellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'September 16, 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have 5 training sessions today',
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
              color: _green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _green.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _green,
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
                  'Active',
                  style: TextStyle(
                    color: _green,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '05',
            label: 'Sessions',
            icon: Icons.event_available_rounded,
            color: _yellow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: '04',
            label: 'Upcoming',
            icon: Icons.schedule_rounded,
            color: _blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: '01',
            label: 'Completed',
            icon: Icons.check_circle_outline_rounded,
            color: _green,
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
  }) {
    return Container(
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
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'September 2026',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = 0;
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
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final selected = _selectedDay == index;
              final day = _days[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = index;
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
                        day['day'],
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
                        day['date'],
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (selected)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.black,
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Sessions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _days[_selectedDay]['fullDate'],
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
                '5 Sessions',
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
    return Column(
      children: List.generate(_sessions.length, (index) {
        final session = _sessions[index];

        return _buildTimelineSession(
          session: session,
          index: index,
          isLast: index == _sessions.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineSession({
    required Map<String, dynamic> session,
    required int index,
    required bool isLast,
  }) {
    final bool completed = session['status'] == 'Completed';
    final Color sessionColor = session['color'] as Color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TIME + LINE
        SizedBox(
          width: 72,
          child: Column(
            children: [
              Text(
                session['time'],
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
            child: _buildDetailedSessionCard(session, sessionColor, completed),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAILED SESSION CARD
  // ============================================================

  Widget _buildDetailedSessionCard(
    Map<String, dynamic> session,
    Color sessionColor,
    bool completed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () => _showSessionDetails(session),
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
                        session['avatar'],
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
                          session['name'],
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
                          session['goal'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusPill(session['status'], completed),
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
                        Icons.fitness_center_rounded,
                        color: _yellow,
                        size: 15,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        session['type'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      session['sessionNo'],
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
                      value: session['duration'],
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
                      value: session['calories'],
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
                      value: session['location']
                          .toString()
                          .split('•')
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
                          : 'Reminder set • 15 min before',
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
  // STATUS
  // ============================================================

  Widget _buildStatusPill(String status, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: completed
            ? _green.withValues(alpha: 0.10)
            : _yellow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: completed
              ? _green.withValues(alpha: 0.12)
              : _yellow.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: completed ? _green : _yellow,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING ADD BUTTON
  // ============================================================

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddSessionDialog,
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
  // SESSION DETAILS
  // ============================================================

  void _showSessionDetails(Map<String, dynamic> session) {
    final bool completed = session['status'] == 'Completed';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 28),
          decoration: BoxDecoration(
            color: const Color(0xFF11151E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_yellowLight, _yellowDark],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          session['avatar'],
                          style: const TextStyle(
                            color: Colors.black,
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
                            session['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session['type'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.42),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildStatusPill(session['status'], completed),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _yellow.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: _yellow.withValues(alpha: 0.10)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: _yellow, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Time',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${session['time']} - ${session['endTime']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _buildDetailRow(Icons.flag_outlined, 'Goal', session['goal']),

                _buildDetailRow(
                  Icons.timer_outlined,
                  'Duration',
                  session['duration'],
                ),

                _buildDetailRow(
                  Icons.local_fire_department_outlined,
                  'Calories',
                  session['calories'],
                ),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Location',
                  session['location'],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit_rounded,
                        text: 'Edit',
                        filled: false,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        icon: completed
                            ? Icons.replay_rounded
                            : Icons.close_rounded,
                        text: completed ? 'Reschedule' : 'Cancel',
                        filled: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _yellow.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _yellow, size: 17),
          ),

          const SizedBox(width: 12),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 10,
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? _yellow : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: filled ? _yellow : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? Colors.black : Colors.white),
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                color: filled ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD SESSION
  // ============================================================

  void _showAddSessionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          decoration: const BoxDecoration(
            color: Color(0xFF11151E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _yellow.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.add_task_rounded, color: _yellow),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Training Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Schedule a session with your client',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildInputTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Client',
                  value: 'Choose a client',
                ),

                _buildInputTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value: _days[_selectedDay]['fullDate'],
                ),

                _buildInputTile(
                  icon: Icons.access_time_rounded,
                  title: 'Time',
                  value: 'Select session time',
                ),

                _buildInputTile(
                  icon: Icons.fitness_center_outlined,
                  title: 'Session Type',
                  value: 'Personal Training',
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Session',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _yellow, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  void _showCalendarDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime(2026, 9, 16),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
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
      builder: (context) {
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
                subtitle: const Text(
                  'Filter by status or session type',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
                  'Export your training schedule',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule export coming soon'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
      builder: (context) {
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
                  icon: Icons.all_inclusive_rounded,
                  title: 'All Sessions',
                  selected: true,
                ),

                _filterOption(
                  icon: Icons.schedule_rounded,
                  title: 'Upcoming',
                  selected: false,
                ),

                _filterOption(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Completed',
                  selected: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterOption({
    required IconData icon,
    required String title,
    required bool selected,
  }) {
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
          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // WEEK VIEW
  // ============================================================

  void _showWeekView() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11151E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
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
                      'September 16 - 22, 2026',
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
                      itemCount: _days.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = index;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: index == _selectedDay
                                  ? _yellow.withValues(alpha: 0.09)
                                  : Colors.white.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: index == _selectedDay
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
                                    color: index == _selectedDay
                                        ? _yellow
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _days[index]['day'],
                                        style: TextStyle(
                                          color: index == _selectedDay
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
                                        _days[index]['date'],
                                        style: TextStyle(
                                          color: index == _selectedDay
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
                                        _days[index]['fullDate'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        index == 0
                                            ? '5 training sessions'
                                            : '${2 + (index % 4)} training sessions',
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
