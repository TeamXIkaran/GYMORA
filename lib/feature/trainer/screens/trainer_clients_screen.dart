import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';

import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/trainer/widgets/trainer_widget.dart';


class TrainerClientsScreen extends StatefulWidget {
  const TrainerClientsScreen({super.key});

  @override
  State<TrainerClientsScreen> createState() => _TrainerClientsScreenState();
}

class _TrainerClientsScreenState extends State<TrainerClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  // Clients come from the shared store — they are ASSIGNED by the gym owner.
  final TrainerDashboardProvider _store = TrainerDashboardProvider.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrainerClient> get _filteredClients {
    final query = _searchController.text.trim().toLowerCase();

    return _store.clients.where((client) {
      final matchesSearch =
          client.name.toLowerCase().contains(query) ||
          client.goal.toLowerCase().contains(query) ||
          client.plan.toLowerCase().contains(query);

      final matchesFilter =
          _selectedFilter == 'All' || client.status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC107).withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            bottom: -180,
            left: -140,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9800).withValues(alpha: 0.035),
              ),
            ),
          ),

          SafeArea(
            child: ListenableBuilder(
              listenable: _store,
              builder: (context, _) => Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverviewCard(),

                          const SizedBox(height: 22),

                          _buildSearchBar(),

                          const SizedBox(height: 14),

                          _buildFilters(),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Your Clients',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                '${_filteredClients.length} Members',
                                style: const TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 13),

                          if (_filteredClients.isEmpty)
                            _buildEmptyState()
                          else
                            ..._filteredClients.map(
                              (client) => _buildClientCard(client),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // "Add Client" removed — clients are assigned to trainers by the owner.
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Clients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Clients assigned by your gym owner',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          _headerButton(Icons.filter_list_rounded, onTap: _showFilterSheet),
        ],
      ),
    );
  }

  Widget _headerButton(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: const Color(0xFFFFC107), size: 20),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OVERVIEW
  // ---------------------------------------------------------------------------

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFC107).withValues(alpha: 0.18),
            const Color(0xFFFF9800).withValues(alpha: 0.055),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFFFFC107),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep your clients on track',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3DDC84).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF3DDC84), size: 7),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Color(0xFF3DDC84),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _overviewStat(
                value: _two(_store.totalClients),
                title: 'Total',
                icon: Icons.people_alt_outlined,
              ),
              _overviewDivider(),
              _overviewStat(
                value: _two(_store.countByStatus('Active')),
                title: 'Active',
                icon: Icons.check_circle_outline_rounded,
              ),
              _overviewDivider(),
              _overviewStat(
                value: _two(_store.countByStatus('Expiring')),
                title: 'Expiring',
                icon: Icons.schedule_rounded,
              ),
              _overviewDivider(),
              _overviewStat(
                value: _two(_store.countByStatus('Expired')),
                title: 'Expired',
                icon: Icons.error_outline_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat({
    required String value,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 17),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewDivider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFFFFC107),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFFFC107),
            size: 21,
          ),
          hintText: 'Search clients, goals or plans...',
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTERS
  // ---------------------------------------------------------------------------

  Widget _buildFilters() {
    final filters = ['All', 'Active', 'Expiring', 'Expired'];

    return SizedBox(
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFC107)
                    : Colors.white.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFC107)
                      : Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENT CARD
  // ---------------------------------------------------------------------------

  Widget _buildClientCard(TrainerClient client) {
    final statusColor = _getStatusColor(client.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    client.initials,
                    style: const TextStyle(
                      color: Colors.black,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            client.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.flag_outlined,
                          color: Color(0xFFFFC107),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.goal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  client.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _miniInfo(Icons.workspace_premium_outlined, client.plan),
                _miniDivider(),
                _miniInfo(Icons.event_available_outlined, client.expiryLabel),
                _miniDivider(),
                _miniInfo(
                  Icons.fitness_center_outlined,
                  '${client.sessions} sessions',
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Text(
                'Training Progress',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                '${client.progress}%',
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: client.progress / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.visibility_outlined,
                  title: 'View Profile',
                  filled: false,
                  onTap: () {
                    _showClientDetails(client);
                  },
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _actionButton(
                  icon: Icons.add_task_rounded,
                  title: client.workoutPlan == null
                      ? 'Workout'
                      : 'Update Workout',
                  filled: true,
                  onTap: () => showAssignWorkoutSheet(context, client),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 13),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDivider() {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION BUTTON
  // ---------------------------------------------------------------------------

  Widget _actionButton({
    required IconData icon,
    required String title,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFFFFC107)
                : Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled
                  ? const Color(0xFFFFC107)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? Colors.black : const Color(0xFFFFC107),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: filled ? Colors.black : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    final noneAssigned = _store.clients.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_rounded,
            color: Color(0xFFFFC107),
            size: 45,
          ),
          const SizedBox(height: 15),
          Text(
            noneAssigned ? 'No clients assigned yet' : 'No clients found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            noneAssigned
                ? 'Your gym owner assigns clients to you. They will appear here.'
                : 'Try another search or filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER SHEET (header button)
  // ---------------------------------------------------------------------------

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0D13),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        const options = {
          'All': Icons.people_alt_outlined,
          'Active': Icons.check_circle_outline_rounded,
          'Expiring': Icons.schedule_rounded,
          'Expired': Icons.error_outline_rounded,
        };

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
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
                  'Filter Clients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ...options.entries.map((entry) {
                  final selected = _selectedFilter == entry.key;
                  final count = entry.key == 'All'
                      ? _store.totalClients
                      : _store.countByStatus(entry.key);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFC107).withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFFC107).withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        entry.value,
                        color: selected
                            ? const Color(0xFFFFC107)
                            : Colors.white38,
                      ),
                      title: Text(
                        '${entry.key} ($count)',
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFFFC107),
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedFilter = entry.key);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CLIENT DETAILS
  // ---------------------------------------------------------------------------

  void _showClientDetails(TrainerClient client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0D13),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final plan = client.workoutPlan;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      client.initials,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  client.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${client.goal} • ${client.plan} Plan • ${client.status}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    _detailBox('Age', client.age),
                    const SizedBox(width: 8),
                    _detailBox('Height', client.height),
                    const SizedBox(width: 8),
                    _detailBox('Weight', client.weight),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _detailBox('Attendance', '${client.attendance}%'),
                    const SizedBox(width: 8),
                    _detailBox('Sessions', '${client.sessions}'),
                    const SizedBox(width: 8),
                    _detailBox('Remaining', '${client.remainingSessions}'),
                  ],
                ),

                if (plan != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Workout • ${plan.title}',
                          style: const TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...plan.exercises.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '• $e',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        if (plan.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Notes: ${plan.notes}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            showSessionFormSheet(
                              context,
                              initialClientId: client.id,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFC107),
                            side: BorderSide(
                              color: const Color(
                                0xFFFFC107,
                              ).withValues(alpha: 0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.event_rounded, size: 17),
                          label: const Text(
                            'Book Session',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            showAssignWorkoutSheet(context, client);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(
                            Icons.fitness_center_rounded,
                            size: 18,
                          ),
                          label: Text(
                            plan == null ? 'Workout Plan' : 'Update Plan',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
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

  Widget _detailBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF3DDC84);
      case 'Expiring':
        return const Color(0xFFFFC107);
      case 'Expired':
        return const Color(0xFFFF5252);
      default:
        return Colors.white38;
    }
  }
}
