import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/notification_service.dart';
import 'package:gymora_fitness_management/core/model/notification_model.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key, required this.trainer});

  final bool trainer;

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final _service = const NotificationService();
  List<NotificationItem> _items = const [];
  bool _loading = true;
  String? _error;

  Color get _accent =>
      widget.trainer ? const Color(0xFFFFC107) : const Color(0xFF52E6D0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getInbox();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read) return;
    try {
      await _service.markRead(item.id);
      if (!mounted) return;
      setState(() {
        _items = [
          for (final current in _items)
            if (current.id == item.id)
              NotificationItem(
                id: current.id,
                title: current.title,
                message: current.message,
                senderRole: current.senderRole,
                createdAt: current.createdAt,
                read: true,
              )
            else
              current,
        ];
      });
    } catch (error) {
      _showError('Could not mark notification as read: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _time(NotificationItem item) {
    final date = item.createdAt?.toLocal();
    if (date == null) return '';
    final elapsed = DateTime.now().difference(date);
    if (elapsed.inMinutes < 1) return 'Now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}m ago';
    if (elapsed.inDays < 1) return '${elapsed.inHours}h ago';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((item) => !item.read).length;
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07090E),
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _accent))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    color: _accent,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Updates sent by your gym owner appear here.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: _accent,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      unread == 0 ? 'You are all caught up' : '$unread unread',
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final item in _items) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _markRead(item),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.read
                              ? const Color(0xFF11151D)
                              : _accent.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.read
                                ? const Color(0xFF252B36)
                                : _accent.withValues(alpha: .35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: _accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _time(item),
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.read) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.circle, color: _accent, size: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }
}
