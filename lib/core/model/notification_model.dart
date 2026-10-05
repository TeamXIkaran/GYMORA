class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.senderRole = '',
  });

  final String id;
  final String title;
  final String message;
  final bool read;
  final DateTime? createdAt;
  final String senderRole;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];
    return NotificationItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      read: json['read'] == true,
      createdAt: rawDate == null ? null : DateTime.tryParse(rawDate.toString()),
      senderRole: (json['senderRole'] ?? '').toString(),
    );
  }
}

class SentNotificationItem {
  const SentNotificationItem({
    required this.id,
    required this.audience,
    required this.sendType,
    required this.title,
    required this.message,
    required this.recipientCount,
    required this.createdAt,
  });

  final String id;
  final String audience;
  final String sendType;
  final String title;
  final String message;
  final int recipientCount;
  final DateTime? createdAt;

  factory SentNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];
    return SentNotificationItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      audience: (json['audience'] ?? '').toString(),
      sendType: (json['sendType'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      recipientCount: int.tryParse('${json['recipientCount'] ?? 0}') ?? 0,
      createdAt: rawDate == null ? null : DateTime.tryParse(rawDate.toString()),
    );
  }
}
