import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/notification_service.dart';
import 'package:gymora_fitness_management/core/model/notification_model.dart';

/// Inbox shared by members and trainers.
///
/// Use `NotificationInboxScreen(trainer: false)` for members and
/// `NotificationInboxScreen(trainer: true)` for trainers. The screen pops with
/// the remaining unread count so the caller can refresh its bell badge:
///
/// ```dart
/// final unread = await Navigator.push<int>(...);
/// ```
class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key, required this.trainer});

  final bool trainer;

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  static const _bg = Color(0xFF07090E);
  static const _cardRead = Color(0xFF11151D);
  static const _borderRead = Color(0xFF252B36);

  final _service = const NotificationService();
  final _pending = <String>{};

  List<NotificationItem> _items = const [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  Color get _accent =>
      widget.trainer ? const Color(0xFFFFC107) : const Color(0xFF52E6D0);

  int get _unread => _items.where((item) => !item.read).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await _service.getInbox();
      if (!mounted) return;
      setState(() {
        // Keep anything the user just marked read locally, in case the
        // server hasn't reflected it yet.
        _items = [
          for (final item in items)
            _pending.contains(item.id) ? item.copyWith(read: true) : item,
        ];
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = _readable(error);
      });
      if (_items.isNotEmpty) {
        _showSnack('Could not refresh: ${_readable(error)}');
      }
    }
  }

  void _setRead(Set<String> ids, bool read) {
    setState(() {
      _items = [
        for (final item in _items)
          ids.contains(item.id)
              ? item.copyWith(read: read, readAt: read ? DateTime.now() : null)
              : item,
      ];
    });
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read || _pending.contains(item.id)) return;
    _pending.add(item.id);
    _setRead({item.id}, true); // optimistic
    try {
      await _service.markRead(item.id);
    } catch (error) {
      if (!mounted) return;
      _setRead({item.id}, false); // revert
      _showSnack('Could not mark as read: ${_readable(error)}');
    } finally {
      _pending.remove(item.id);
    }
  }

  Future<void> _markAllRead() async {
    final ids = _items
        .where((i) => !i.read && !_pending.contains(i.id))
        .map((i) => i.id)
        .toSet();
    if (ids.isEmpty || _markingAll) return;
    setState(() => _markingAll = true);
    _pending.addAll(ids);
    _setRead(ids, true); // optimistic
    try {
      final failed = await _service.markAllRead(ids.toList());
      if (!mounted) return;
      if (failed.isEmpty) {
        _showSnack('All notifications marked as read');
      } else {
        _setRead(failed, false); // revert only the ones that failed
        _showSnack(
          'Could not mark ${failed.length} of ${ids.length} as read. Try again.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      _setRead(ids, false);
      _showSnack('Could not mark all as read: ${_readable(error)}');
    } finally {
      _pending.removeAll(ids);
      if (mounted) setState(() => _markingAll = false);
    }
  }

  void _open(NotificationItem item) {
    _markRead(item);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11151D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (item.senderRole.isNotEmpty) _senderLabel(item.senderRole),
                  _time(item),
                ].where((s) => s.isNotEmpty).join(' · '),
                style: TextStyle(color: _accent, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    item.message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.45,
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  String _readable(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  String _senderLabel(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return 'From gym owner';
      case 'TRAINER':
        return 'From trainer';
      case 'ADMIN':
        return 'From admin';
      default:
        return 'From $role';
    }
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
    return PopScope<int>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_unread);
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text('Notifications'),
          actions: [
            if (_unread > 0)
              TextButton.icon(
                onPressed: _markingAll ? null : _markAllRead,
                style: TextButton.styleFrom(foregroundColor: _accent),
                icon: _markingAll
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent,
                        ),
                      )
                    : const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Mark all read'),
              ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : () => _load(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: _accent, size: 42),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _load(),
                style: TextButton.styleFrom(foregroundColor: _accent),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => _load(showSpinner: false),
      child: _items.isEmpty ? _emptyView() : _listView(),
    );
  }

  Widget _emptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * .25),
        Icon(Icons.notifications_off_outlined, color: _accent, size: 44),
        const SizedBox(height: 12),
        const Text(
          'No notifications yet',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(
          widget.trainer
              ? 'Schedule and member updates from your gym owner appear here.'
              : 'Updates from your gym owner and trainer appear here.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _listView() {
    final unread = _unread;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            unread == 0 ? 'You are all caught up' : '$unread unread',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
          ),
        ),
        for (final item in _items) ...[
          _NotificationCard(
            item: item,
            accent: _accent,
            time: _time(item),
            sender: item.senderRole.isEmpty
                ? ''
                : _senderLabel(item.senderRole),
            onTap: () => _open(item),
            onMarkRead: () => _markRead(item),
            readColor: _cardRead,
            readBorder: _borderRead,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.accent,
    required this.time,
    required this.sender,
    required this.onTap,
    required this.onMarkRead,
    required this.readColor,
    required this.readBorder,
  });

  final NotificationItem item;
  final Color accent;
  final String time;
  final String sender;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final Color readColor;
  final Color readBorder;

  @override
  Widget build(BuildContext context) {
    final unread = !item.read;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          decoration: BoxDecoration(
            color: unread ? accent.withValues(alpha: .08) : readColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread ? accent.withValues(alpha: .35) : readBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                unread
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                color: unread ? accent : Colors.white38,
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
                            style: TextStyle(
                              color: unread ? Colors.white : Colors.white70,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.circle, color: accent, size: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread ? Colors.white70 : Colors.white54,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (sender.isNotEmpty)
                          Expanded(
                            child: Text(
                              sender,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        if (unread)
                          TextButton.icon(
                            onPressed: onMarkRead,
                            style: TextButton.styleFrom(
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: const Icon(Icons.done_rounded, size: 16),
                            label: const Text('Mark as read'),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 14,
                                  color: Colors.white38,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Read',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
