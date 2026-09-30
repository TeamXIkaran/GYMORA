import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/model/trainer_model.dart';
import 'package:gymora_fitness_management/feature/trainer/providers/trainer_dashboard_provider.dart';

// =============================================================================
// Shared bottom sheets used by Dashboard, Schedule and Clients screens.
// Same visual style as the existing schedule screen sheets.
// =============================================================================

const Color _yellow = Color(0xFFFFC107);
const Color _yellowLight = Color(0xFFFFD54F);
const Color _yellowDark = Color(0xFFFFA000);
const Color _green = Color(0xFF22C55E);
const Color _sheetColor = Color(0xFF11151E);

TrainerDashboardProvider get _store => TrainerDashboardProvider.instance;

Widget _handle() => Container(
  width: 42,
  height: 4,
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(10),
  ),
);

BoxDecoration _sheetDecoration() => const BoxDecoration(
  color: _sheetColor,
  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
);

void showTrainerSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

ThemeData _pickerTheme(BuildContext context) => Theme.of(context).copyWith(
  colorScheme: const ColorScheme.dark(
    primary: _yellow,
    onPrimary: Colors.black,
    surface: _sheetColor,
  ),
);

// =============================================================================
// SESSION DETAILS
// =============================================================================

Future<void> showSessionDetailsSheet(
  BuildContext context,
  TrainingSession session,
) {
  final client = _store.clientById(session.clientId);
  final completed = session.isCompleted;
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 28),
        decoration: BoxDecoration(
          color: _sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_yellowLight, _yellowDark],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        client?.initials ?? '?',
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
                          client?.name ?? 'Unknown client',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.type,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  sessionStatusPill(session),
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
                    const Icon(
                      Icons.access_time_rounded,
                      color: _yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatFullDate(session.start),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${formatTime(session.start)} - ${formatTime(session.end)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _detailRow(Icons.flag_outlined, 'Goal', client?.goal ?? '-'),
              _detailRow(
                Icons.timer_outlined,
                'Duration',
                '${session.durationMinutes} min',
              ),
              _detailRow(
                Icons.local_fire_department_outlined,
                'Calories',
                session.calories,
              ),
              _detailRow(
                Icons.location_on_outlined,
                'Location',
                session.location,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: sheetActionButton(
                      icon: Icons.edit_rounded,
                      text: 'Edit',
                      filled: false,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        showSessionFormSheet(context, existing: session);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: sheetActionButton(
                      icon: completed
                          ? Icons.replay_rounded
                          : Icons.close_rounded,
                      text: completed ? 'Reschedule' : 'Cancel',
                      filled: completed,
                      onTap: () {
                        Navigator.pop(sheetContext);

                        if (completed) {
                          showSessionFormSheet(
                            context,
                            initialClientId: session.clientId,
                            initialType: session.type,
                          );
                        } else {
                          final removed = _store.cancelSession(session.id);

                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: const Text('Session cancelled'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: _yellow,
                                  onPressed: () => _store.restoreSession(
                                    removed as TrainingSession,
                                  ),
                                ),
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (!completed) ...[
                const SizedBox(height: 10),
                sheetActionButton(
                  icon: Icons.check_circle_rounded,
                  text: 'Mark as Completed',
                  filled: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _store.completeSession(session.id);

                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Session with ${client?.name ?? 'client'} marked as completed',
                          ),
                        ),
                      );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Widget sessionStatusPill(TrainingSession session) {
  final completed = session.isCompleted;
  final color = completed ? _green : _yellow;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: color.withValues(alpha: 0.12)),
    ),
    child: Text(
      session.statusLabel,
      style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900),
    ),
  );
}

Widget _detailRow(IconData icon, String title, String value) {
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

Widget sheetActionButton({
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

// =============================================================================
// ADD / EDIT SESSION
// =============================================================================

Future<void> showSessionFormSheet(
  BuildContext context, {
  TrainingSession? existing,
  DateTime? initialDate,
  String? initialClientId,
  String? initialType,
}) {
  if (_store.clients.isEmpty) {
    showTrainerSnack(
      context,
      'No clients assigned yet. Your gym owner assigns clients to you.',
    );
    return Future.value();
  }

  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _SessionFormSheet(
      existing: existing,
      initialDate: initialDate,
      initialClientId: initialClientId,
      initialType: initialType,
      onSaved: (message) => messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        ),
    ),
  );
}

class _SessionFormSheet extends StatefulWidget {
  final TrainingSession? existing;
  final DateTime? initialDate;
  final String? initialClientId;
  final String? initialType;
  final ValueChanged<String> onSaved;

  const _SessionFormSheet({
    required this.existing,
    required this.initialDate,
    required this.initialClientId,
    required this.initialType,
    required this.onSaved,
  });

  @override
  State<_SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<_SessionFormSheet> {
  String? _clientId;
  late DateTime _date;
  late TimeOfDay _time;
  late int _duration;
  late String _type;
  late String _location;
  String? _error;

  // FIX: prevents multiple submissions while API request is running.
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    final now = DateTime.now();

    if (e != null) {
      _clientId = e.clientId;
      _date = dateOnly(e.start);
      _time = TimeOfDay(hour: e.start.hour, minute: e.start.minute);
      _duration = e.durationMinutes;
      _type = e.type;
      _location = e.location;
    } else {
      _clientId = widget.initialClientId;

      final base = dateOnly(widget.initialDate ?? now);

      _date = base.isBefore(dateOnly(now)) ? dateOnly(now) : base;

      if (isSameDay(_date, now)) {
        final nextHour = now.hour >= 23 ? 23 : now.hour + 1;

        _time = TimeOfDay(hour: nextHour, minute: 0);
      } else {
        _time = const TimeOfDay(hour: 9, minute: 0);
      }

      _duration = 60;
      _type = widget.initialType ?? TrainerOptions.sessionTypes.first;
      _location = TrainerOptions.locations.first;
    }
  }

  DateTime get _start =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  String _formatTimeOfDay(TimeOfDay t) {
    return formatTime(DateTime(2000, 1, 1, t.hour, t.minute));
  }

  Future<void> _pickClient() async {
    final picked = await showClientPickerSheet(context, selectedId: _clientId);

    if (picked != null && mounted) {
      setState(() => _clientId = picked.id);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _isEdit && _date.isBefore(dateOnly(now))
          ? _date
          : dateOnly(now),
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (context, child) =>
          Theme(data: _pickerTheme(context), child: child!),
    );

    if (picked != null && mounted) {
      setState(() => _date = dateOnly(picked));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) =>
          Theme(data: _pickerTheme(context), child: child!),
    );

    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  Future<void> _pickOption(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onPicked,
  ) async {
    final picked = await showOptionSheet(context, title, options, selected);

    if (picked != null && mounted) {
      setState(() => onPicked(picked));
    }
  }

  // ===========================================================================
  // FIXED SAVE METHOD
  // ===========================================================================
  //
  // OLD:
  // setState(() async => _error = await error);
  //
  // This is invalid because setState() callback cannot return Future.
  //
  // Now we await the API operation first and then update the state normally.
  // ===========================================================================

  Future<void> _save() async {
    if (_saving) return;

    if (_clientId == null) {
      setState(() => _error = 'Please choose a client.');
      return;
    }

    if (!_isEdit && _start.isBefore(DateTime.now())) {
      setState(() => _error = 'Please choose a time in the future.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    String? error;

    try {
      if (_isEdit) {
        error = await _store.updateSession(
          widget.existing!.id,
          clientId: _clientId!,
          start: _start,
          durationMinutes: _duration,
          type: _type,
          location: _location,
        );
      } else {
        error = await _store.addSession(
          clientId: _clientId!,
          start: _start,
          durationMinutes: _duration,
          type: _type,
          location: _location,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.toString();
      });

      return;
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });

      return;
    }

    Navigator.pop(context);

    widget.onSaved(
      _isEdit
          ? 'Training session updated successfully'
          : 'Training session created successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = _clientId == null ? null : _store.clientById(_clientId!);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        15,
        20,
        MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: _sheetDecoration(),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(),
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
                    child: Icon(
                      _isEdit
                          ? Icons.edit_calendar_rounded
                          : Icons.add_task_rounded,
                      color: _yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Edit Session' : 'Add Training Session',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Schedule a session with your client',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _inputTile(
                icon: Icons.person_outline_rounded,
                title: 'Client',
                value: client?.name ?? 'Choose a client',
                onTap: _pickClient,
              ),
              _inputTile(
                icon: Icons.calendar_today_outlined,
                title: 'Date',
                value: formatFullDate(_date),
                onTap: _pickDate,
              ),
              _inputTile(
                icon: Icons.access_time_rounded,
                title: 'Time',
                value: _formatTimeOfDay(_time),
                onTap: _pickTime,
              ),
              _inputTile(
                icon: Icons.timer_outlined,
                title: 'Duration',
                value: '$_duration min',
                onTap: () => _pickOption(
                  'Duration',
                  TrainerOptions.durations.map((d) => '$d min').toList(),
                  '$_duration min',
                  (v) => _duration = int.parse(v.split(' ').first),
                ),
              ),
              _inputTile(
                icon: Icons.fitness_center_outlined,
                title: 'Session Type',
                value: _type,
                onTap: () => _pickOption(
                  'Session Type',
                  TrainerOptions.sessionTypes,
                  _type,
                  (v) => _type = v,
                ),
              ),
              _inputTile(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: _location,
                onTap: () => _pickOption(
                  'Location',
                  TrainerOptions.locations,
                  _location,
                  (v) => _location = v,
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: _yellow.withValues(alpha: 0.55),
                    disabledForegroundColor: Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _saving
                        ? 'Saving...'
                        : (_isEdit ? 'Save Changes' : 'Create Session'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _inputTile({
  required IconData icon,
  required String title,
  required String value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
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
    ),
  );
}

// =============================================================================
// PICKERS
// =============================================================================

Future<String?> showOptionSheet(
  BuildContext context,
  String title,
  List<String> options,
  String selected,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: _sheetColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _handle()),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            ...options.map(
              (o) => _optionRow(
                title: o,
                selected: o == selected,
                onTap: () => Navigator.pop(sheetContext, o),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
// FIXED OPTION ROW
// =============================================================================
//
// The ListTile was inside a Container with a background color.
// ListTile's ripple/background is painted on the nearest Material,
// so the Container could hide it.
//
// Material now sits directly above ListTile and clips the ripple
// correctly.
// =============================================================================

Widget _optionRow({
  required String title,
  required bool selected,
  required VoidCallback onTap,
  Widget? leading,
  String? subtitle,
}) {
  final backgroundColor = selected
      ? _yellow.withValues(alpha: 0.09)
      : Colors.white.withValues(alpha: 0.035);

  final borderColor = selected
      ? _yellow.withValues(alpha: 0.18)
      : Colors.white.withValues(alpha: 0.06);

  return Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: borderColor),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: _yellow, size: 20)
            : null,
        onTap: onTap,
      ),
    ),
  );
}

/// Lets the trainer pick one of the clients ASSIGNED to them by the owner.
Future<TrainerClient?> showClientPickerSheet(
  BuildContext context, {
  String? selectedId,
}) {
  final clients = _store.clients;

  return showModalBottomSheet<TrainerClient>(
    context: context,
    backgroundColor: _sheetColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _handle()),
              const SizedBox(height: 18),
              const Text(
                'Choose Client',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Clients assigned to you by your gym owner',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: clients
                      .map(
                        (c) => _optionRow(
                          title: c.name,
                          subtitle: '${c.goal} • ${c.plan} • ${c.status}',
                          selected: c.id == selectedId,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: _yellow.withValues(alpha: 0.12),
                            child: Text(
                              c.initials,
                              style: const TextStyle(
                                color: _yellow,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(sheetContext, c),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
// ASSIGN WORKOUT
// =============================================================================

Future<void> showAssignWorkoutSheet(
  BuildContext context,
  TrainerClient client,
) {
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AssignWorkoutSheet(
      client: client,
      onSaved: (message) => messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        ),
    ),
  );
}

/// Picks a client first, then opens the workout sheet.
Future<void> pickClientAndAssignWorkout(BuildContext context) async {
  if (_store.clients.isEmpty) {
    showTrainerSnack(
      context,
      'No clients assigned yet. Your gym owner assigns clients to you.',
    );
    return;
  }

  final client = await showClientPickerSheet(context);

  if (client != null && context.mounted) {
    await showAssignWorkoutSheet(context, client);
  }
}

class _AssignWorkoutSheet extends StatefulWidget {
  final TrainerClient client;
  final ValueChanged<String> onSaved;

  const _AssignWorkoutSheet({required this.client, required this.onSaved});

  @override
  State<_AssignWorkoutSheet> createState() => _AssignWorkoutSheetState();
}

class _AssignWorkoutSheetState extends State<_AssignWorkoutSheet> {
  late String _template;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    final existing = widget.client.workoutPlan;

    _template =
        existing != null &&
            TrainerOptions.workoutTemplates.containsKey(existing.title)
        ? existing.title
        : TrainerOptions.workoutTemplates.keys.first;

    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    TrainerDashboardProvider.instance.assignWorkout(
      widget.client.id,
      WorkoutPlan(
        title: _template,
        exercises: TrainerOptions.workoutTemplates[_template]!,
        notes: _notesController.text.trim(),
        assignedOn: DateTime.now(),
      ),
    );

    Navigator.pop(context);

    widget.onSaved('$_template assigned to ${widget.client.name}');
  }

  @override
  Widget build(BuildContext context) {
    final exercises = TrainerOptions.workoutTemplates[_template]!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        15,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: _sheetDecoration(),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _handle()),
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
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: _yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Workout Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'For ${widget.client.name} • Goal: ${widget.client.goal}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TrainerOptions.workoutTemplates.keys.map((t) {
                  final selected = t == _template;

                  return GestureDetector(
                    onTap: () => setState(() => _template = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _yellow
                            : Colors.white.withValues(alpha: 0.035),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? _yellow
                              : Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercises
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: _yellow,
                                size: 15,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  cursorColor: _yellow,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                      color: _yellow,
                      size: 19,
                    ),
                    hintText: 'Notes for the client (optional)',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 17),
                  label: Text(
                    widget.client.workoutPlan == null
                        ? 'Assign Workout'
                        : 'Update Workout',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
