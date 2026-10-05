/// Notification models shared by the member / trainer inbox and the owner
/// "sent" history.
///
/// Parsing is deliberately tolerant: backends commonly return the read flag as
/// `read`, `isRead`, `is_read`, a `readAt` timestamp or `status: "READ"`, and
/// inbox rows are often per-recipient records with the actual notification
/// nested under `notification`. Reading only `json['read'] == true` is the
/// main reason read state appeared "not to work".
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.senderRole = '',
    this.recipientId = '',
    this.readAt,
  });

  /// Notification id (used for `POST api/notifications/:id/read`).
  final String id;

  /// Per-recipient record id, when the backend returns recipient rows.
  final String recipientId;

  final String title;
  final String message;
  final bool read;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String senderRole;

  NotificationItem copyWith({bool? read, DateTime? readAt}) {
    return NotificationItem(
      id: id,
      recipientId: recipientId,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      senderRole: senderRole,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final nestedRaw = json['notification'];
    final nested = nestedRaw is Map
        ? Map<String, dynamic>.from(nestedRaw)
        : null;

    // Content comes from the nested notification when present; read state
    // lives on the outer (per-recipient) record.
    final content = nested ?? json;

    final outerId = _string(json['id'] ?? json['_id']);
    final notificationId = nested != null
        ? _string(nested['id'] ?? nested['_id'] ?? json['notificationId'])
        : _string(json['notificationId'] ?? json['id'] ?? json['_id']);

    final readAt = _date(json['readAt'] ?? json['read_at']);

    return NotificationItem(
      id: notificationId.isNotEmpty ? notificationId : outerId,
      recipientId: nested != null ? outerId : '',
      title: _string(content['title']),
      message: _string(content['message'] ?? content['body']),
      read: _parseRead(json) || (nested != null && _parseRead(nested)),
      createdAt: _date(content['createdAt'] ?? json['createdAt']),
      readAt: readAt,
      senderRole: _string(content['senderRole'] ?? json['senderRole']),
    );
  }

  static bool _parseRead(Map<String, dynamic> json) {
    for (final key in const ['read', 'isRead', 'is_read', 'seen', 'isSeen']) {
      final value = json[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.toLowerCase();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
    }
    if (json['readAt'] != null || json['read_at'] != null) return true;
    return _string(json['status']).toUpperCase() == 'READ';
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
    this.readCount,
  });

  final String id;
  final String audience;
  final String sendType;
  final String title;
  final String message;
  final int recipientCount;
  final DateTime? createdAt;

  /// How many recipients have read it, if the backend provides it.
  final int? readCount;

  factory SentNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawRead = json['readCount'] ?? json['read_count'];
    return SentNotificationItem(
      id: _string(json['id'] ?? json['_id']),
      audience: _string(json['audience']).toUpperCase(),
      sendType: _string(json['sendType']),
      title: _string(json['title']),
      message: _string(json['message']),
      recipientCount: int.tryParse('${json['recipientCount'] ?? 0}') ?? 0,
      createdAt: _date(json['createdAt']),
      readCount: rawRead == null ? null : int.tryParse('$rawRead'),
    );
  }
}

String _string(dynamic value) => value == null ? '' : value.toString();

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
