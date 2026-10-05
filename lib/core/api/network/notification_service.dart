import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/notification_model.dart';

class NotificationService {
  const NotificationService();

  Future<List<NotificationItem>> getInbox() async {
    final response = await ApiService.get('api/notifications');
    final data = _map(response['data']);
    return _list(
      data['notifications'],
    ).map((item) => NotificationItem.fromJson(item)).toList();
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
    final data = _map(response['data']);
    final notification = _map(data['notification']);
    return int.tryParse('${notification['recipientCount'] ?? 0}') ?? 0;
  }

  Future<List<SentNotificationItem>> getSent() async {
    final response = await ApiService.get('api/notifications/sent');
    final data = _map(response['data']);
    return _list(
      data['notifications'],
    ).map((item) => SentNotificationItem.fromJson(item)).toList();
  }

  Future<void> markRead(String id) async {
    await ApiService.post(
      'api/notifications/${Uri.encodeComponent(id)}/read',
      const {},
    );
  }
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
