import 'package:intl/intl.dart';

// ── Currency ────────────────────────────────────────────────────

final NumberFormat _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Full rupee amount with Indian grouping, e.g. ₹1,50,000.
String formatRupees(num value) => _inr.format(value);

/// Compact rupee amount for stat cards, e.g. ₹30K, ₹1.5L, ₹2.3Cr.
String formatRupeesCompact(num value) {
  final v = value.toDouble();

  String short(double x) {
    final s = x >= 10 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (v >= 10000000) return '₹${short(v / 10000000)}Cr';
  if (v >= 100000) return '₹${short(v / 100000)}L';
  if (v >= 1000) return '₹${short(v / 1000)}K';
  return '₹${v.toStringAsFixed(0)}';
}

// ── Text ────────────────────────────────────────────────────────

/// "ACTIVE" → "Active", "weight_training" → "Weight Training".
String titleCase(String s) {
  if (s.trim().isEmpty) return s;
  return s
      .split(RegExp(r'[\s_]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

/// Two-letter initials from a full name.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
}

/// Plan key from the API ("PREMIUM") → display name ("Premium Membership").
String planLabelFromKey(String key) {
  switch (key.trim().toUpperCase()) {
    case 'BASIC':
      return 'Basic Membership';
    case 'STANDARD':
      return 'Standard Membership';
    case 'PREMIUM':
      return 'Premium Membership';
    case '':
      return 'N/A';
    default:
      return titleCase(key);
  }
}

// ── Membership status ───────────────────────────────────────────

/// Members whose plan ends within this many days are shown as EXPIRING.
const int kExpiringWithinDays = 7;

/// The backend currently only sends ACTIVE, so EXPIRING / EXPIRED are
/// derived from the end date. Any non-ACTIVE status from the backend
/// (e.g. EXPIRED, CANCELLED) is respected as-is.
String computeMembershipStatus(String rawStatus, DateTime? endDate) {
  final raw = rawStatus.trim().toUpperCase();
  if (raw.isNotEmpty && raw != 'ACTIVE') return raw;
  if (endDate == null) return 'ACTIVE';

  final now = DateTime.now();
  if (endDate.isBefore(now)) return 'EXPIRED';
  if (endDate.difference(now).inDays < kExpiringWithinDays) return 'EXPIRING';
  return 'ACTIVE';
}

// ── JSON parsing ────────────────────────────────────────────────

int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String parseString(dynamic value) => value?.toString() ?? '';

Map<String, dynamic> asJsonMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> asJsonList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

/// Strips the "Exception: " prefix so users see a clean message.
String cleanError(Object error) =>
    error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
