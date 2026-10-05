import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/notification_model.dart';

class NotificationService {
  const NotificationService();

  /// Inbox for the logged-in member or trainer.
  Future<List<NotificationItem>> getInbox() async {
    final response = await ApiService.get('api/notifications');
    final items = _extractList(response)
        .map(NotificationItem.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
    items.sort((a, b) {
      final ad = a.createdAt, bd = b.createdAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad); // newest first
    });
    return items;
  }

  /// Unread count, e.g. for a bell badge on the member / trainer home.
  Future<int> getUnreadCount() async {
    final items = await getInbox();
    return items.where((item) => !item.read).length;
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
    final data = _map(_map(response)['data']);
    final notification = _map(data['notification']);
    return int.tryParse(
          '${notification['recipientCount'] ?? data['recipientCount'] ?? 0}',
        ) ??
        0;
  }

  Future<List<SentNotificationItem>> getSent() async {
    final response = await ApiService.get('api/notifications/sent');
    return _extractList(response).map(SentNotificationItem.fromJson).toList();
  }

  Future<void> markRead(String id) async {
    if (id.isEmpty) throw ArgumentError('Notification id is empty');
    await ApiService.post(
      'api/notifications/${Uri.encodeComponent(id)}/read',
      const {},
    );
  }

  /// Marks every given notification read. Tries a bulk endpoint first and
  /// falls back to one call per notification if the backend doesn't have it.
  Future<void> markAllRead(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await ApiService.post('api/notifications/read-all', const {});
    } catch (_) {
      await Future.wait(ids.map(markRead));
    }
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
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}
