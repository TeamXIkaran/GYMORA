import 'package:flutter/material.dart';

class TrainerScheduleScreen extends StatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  final Color _yellow = const Color(0xFFFFC107);
  final Color _background = const Color(0xFF05070C);
  final Color _cardColor = const Color(0xFF10141D);

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
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
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
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _yellow.withValues(alpha: 0.055),
                  ),
                ),
              ),

              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryStats(),
                          const SizedBox(height: 22),
                          _buildDateSelector(),
                          const SizedBox(height: 24),
                          _buildScheduleHeader(),
                          const SizedBox(height: 14),
                          _buildScheduleList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(right: 20, bottom: 22, child: _buildAddButton()),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage your training sessions',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _buildIconButton(
            icon: Icons.calendar_month_rounded,
            onTap: () {
              _showCalendarDialog();
            },
          ),

          const SizedBox(width: 8),

          _buildIconButton(
            icon: Icons.more_vert_rounded,
            onTap: () {
              _showMoreOptions();
            },
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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

  // ─────────────────────────────────────────────
  // SUMMARY
  // ─────────────────────────────────────────────

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '05',
            label: 'Sessions',
            icon: Icons.event_available_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: '04',
            label: 'Upcoming',
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            value: '01',
            label: 'Completed',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: _cardColor.withValues(alpha: 0.82),
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
              Icon(icon, size: 17, color: _yellow),
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _yellow,
                  boxShadow: [
                    BoxShadow(
                      color: _yellow.withValues(alpha: 0.5),
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
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DATE SELECTOR
  // ─────────────────────────────────────────────

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
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'Today',
              style: TextStyle(
                color: _yellow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 76,
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
                  width: 58,
                  decoration: BoxDecoration(
                    color: selected
                        ? _yellow
                        : Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: selected
                          ? _yellow
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _yellow.withValues(alpha: 0.18),
                              blurRadius: 16,
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
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        day['date'],
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  // ─────────────────────────────────────────────
  // SCHEDULE HEADER
  // ─────────────────────────────────────────────

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
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _days[_selectedDay]['fullDate'],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: _yellow.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _yellow.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: _yellow, size: 14),
              const SizedBox(width: 5),
              Text(
                '5 Sessions',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SCHEDULE LIST
  // ─────────────────────────────────────────────

  Widget _buildScheduleList() {
    return Column(
      children: List.generate(_sessions.length, (index) {
        return _buildSessionCard(session: _sessions[index], index: index);
      }),
    );
  }

  Widget _buildSessionCard({
    required Map<String, dynamic> session,
    required int index,
  }) {
    final bool completed = session['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: _cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: completed
              ? Colors.green.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.065),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            _showSessionDetails(session);
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIME
                    SizedBox(
                      width: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['time'],
                            style: TextStyle(
                              color: completed
                                  ? Colors.white.withValues(alpha: 0.55)
                                  : _yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session['endTime'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.32),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Container(
                            width: 3,
                            height: 30,
                            decoration: BoxDecoration(
                              color: completed ? Colors.green : _yellow,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 105,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),

                    const SizedBox(width: 13),

                    // CLIENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 43,
                                height: 43,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _yellow.withValues(alpha: 0.95),
                                      const Color(0xFFFF8F00),
                                    ],
                                  ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.43,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _buildStatusPill(session['status'], completed),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              _buildInfoItem(
                                Icons.fitness_center_rounded,
                                session['type'],
                              ),
                              const SizedBox(width: 14),
                              _buildInfoItem(
                                Icons.timer_outlined,
                                session['duration'],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  session['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.32),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

                Row(
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.notifications_none_rounded,
                      size: 15,
                      color: completed ? Colors.green : _yellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      completed
                          ? 'Session completed successfully'
                          : 'Reminder set for 15 min before',
                      style: TextStyle(
                        color: completed
                            ? Colors.green.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withValues(alpha: 0.1)
            : _yellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: completed ? Colors.green : _yellow,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _yellow.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ADD SESSION BUTTON
  // ─────────────────────────────────────────────

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        _showAddSessionDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _yellow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _yellow.withValues(alpha: 0.28),
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
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SESSION DETAILS
  // ─────────────────────────────────────────────

  void _showSessionDetails(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xFF11151E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _yellow,
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session['type'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(
                      session['status'],
                      session['status'] == 'Completed',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildDetailRow(
                  Icons.access_time_rounded,
                  'Time',
                  '${session['time']} - ${session['endTime']}',
                ),

                _buildDetailRow(Icons.flag_outlined, 'Goal', session['goal']),

                _buildDetailRow(
                  Icons.timer_outlined,
                  'Duration',
                  session['duration'],
                ),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Location',
                  session['location'],
                ),

                const SizedBox(height: 18),

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
                        icon: Icons.close_rounded,
                        text: 'Cancel',
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
      padding: const EdgeInsets.only(bottom: 15),
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
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

  // ─────────────────────────────────────────────
  // ADD SESSION DIALOG
  // ─────────────────────────────────────────────

  void _showAddSessionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          decoration: const BoxDecoration(
            color: Color(0xFF11151E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Training Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Schedule a new session with your client',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                _buildInputTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Select Client',
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
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
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
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  // ─────────────────────────────────────────────
  // CALENDAR
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // MORE OPTIONS
  // ─────────────────────────────────────────────

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11151E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.filter_list_rounded, color: _yellow),
                title: const Text(
                  'Filter Sessions',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.view_week_rounded, color: _yellow),
                title: const Text(
                  'Week View',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.download_rounded, color: _yellow),
                title: const Text(
                  'Export Schedule',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
