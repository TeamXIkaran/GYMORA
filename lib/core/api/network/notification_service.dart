import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/notification_model.dart';

class NotificationService {
  const NotificationService();

  /// Inbox for the logged-in member or trainer.
  ///
  /// `GET api/notifications` →
  /// `{success, message, data: {unreadCount, notifications: [...]}}`
  Future<List<NotificationItem>> getInbox() async {
    final response = await ApiService.get('api/notifications');
    _ensureSuccess(response);

    final items = _extractList(response)
        .map(NotificationItem.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();

    items.sort((a, b) {
      final ad = a.createdAt;
      final bd = b.createdAt;

      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;

      return bd.compareTo(ad); // newest first
    });

    return items;
  }

  /// Unread count for the bell badge on the member / trainer home.
  /// Uses the server's `data.unreadCount`, falling back to counting the list.
  Future<int> getUnreadCount() async {
    final response = await ApiService.get('api/notifications');
    _ensureSuccess(response);

    final data = _map(_map(response)['data']);

    final serverCount = int.tryParse('${data['unreadCount'] ?? ''}');

    if (serverCount != null) return serverCount;

    return _extractList(
      response,
    ).map(NotificationItem.fromJson).where((item) => !item.read).length;
  }

  Future<int> send({
    required String audience,
    required bool everyone,
    required List<String> recipientIds,
    required String title,
    required String message,
  }) async {
    final response = await ApiService.post('api/notifications', {
      'audience': audience,
      'sendType': everyone ? 'EVERYONE' : 'SELECTED',
      if (!everyone) 'recipientIds': recipientIds,
      'title': title,
      'message': message,
    });

    _ensureSuccess(response);

    final data = _map(_map(response)['data']);
    final notification = _map(data['notification']);

    return int.tryParse(
          '${notification['recipientCount'] ?? data['recipientCount'] ?? 0}',
        ) ??
        0;
  }

  Future<List<SentNotificationItem>> getSent() async {
    final response = await ApiService.get('api/notifications/sent');

    _ensureSuccess(response);

    return _extractList(response).map(SentNotificationItem.fromJson).toList();
  }

  /// Marks a notification as read.
  ///
  /// `PATCH api/notifications/:id/read`
  Future<void> markRead(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Notification id is empty');
    }

    final response = await ApiService.patch(
      'api/notifications/${Uri.encodeComponent(id)}/read',
      const {},
    );

    _ensureSuccess(response);
  }

  /// Marks every given notification read using the per-notification
  /// endpoint.
  ///
  /// Returns the ids that could NOT be marked read, so the caller can revert
  /// only those. An empty set means everything succeeded.
  Future<Set<String>> markAllRead(List<String> ids) async {
    final failed = <String>{};

    if (ids.isEmpty) return failed;

    await Future.wait(
      ids.map((id) async {
        try {
          await markRead(id);
        } catch (_) {
          failed.add(id);
        }
      }),
    );

    return failed;
  }
}

/// Throws when the backend answers with `success: false`, so callers don't
/// treat a failed request as a success.
void _ensureSuccess(dynamic response) {
  if (response is Map && response['success'] == false) {
    final message = response['message']?.toString();

    throw Exception(
      message == null || message.isEmpty ? 'Request failed' : message,
    );
  }
}

/// Accepts `{data: {notifications: [...]}}`, `{data: [...]}`,
/// `{data: {items: [...]}}` or a bare list.
List<Map<String, dynamic>> _extractList(dynamic response) {
  final data = response is Map ? response['data'] : response;

  if (data is List) return _list(data);

  final map = _map(data);

  return _list(map['notifications'] ?? map['items'] ?? map['inbox']);
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const [];

  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}
