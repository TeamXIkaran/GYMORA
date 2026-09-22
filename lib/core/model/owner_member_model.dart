import 'package:gymora_fitness_management/core/model/membership_plan_model.dart';
import 'package:intl/intl.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class OwnerMemberModel {
  final String id;
  final String fullName;
  final String planName;
  final String phone;
  final String email;
  final String gymId;
  final String membershipPlan;
  final double price;
  final int durationMonths;
  final DateTime? startDateRaw;
  final DateTime? endDateRaw;

  /// Raw status exactly as sent by the backend (currently always "ACTIVE").
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OwnerMemberModel({
    required this.id,
    required this.fullName,
    this.planName = '',
    required this.phone,
    required this.email,
    this.gymId = '',
    required this.membershipPlan,
    this.price = 0,
    this.durationMonths = 0,
    this.startDateRaw,
    this.endDateRaw,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // ── Status (derived from endDate) ───────────────────────────

  /// ACTIVE / EXPIRING / EXPIRED — use this everywhere in the UI.
  String get displayStatus => computeMembershipStatus(status, endDateRaw);

  bool get isActive => displayStatus == 'ACTIVE';
  bool get isExpiring => displayStatus == 'EXPIRING';
  bool get isExpired => displayStatus == 'EXPIRED';

  /// Days until the plan ends (negative when already expired).
  int? get daysLeft {
    if (endDateRaw == null) return null;
    return endDateRaw!.difference(DateTime.now()).inDays;
  }

  // ── Plan / price ────────────────────────────────────────────

  MembershipPlan? get _catalogPlan => MembershipPlan.byKey(membershipPlan);

  /// Human-readable plan name, e.g. "Premium Membership".
  String get planDisplayName {
    if (planName.trim().isNotEmpty) return planName;
    return planLabelFromKey(membershipPlan);
  }

  /// GET /members doesn't return price — fall back to the plan catalog.
  double get effectivePrice =>
      price > 0 ? price : (_catalogPlan?.price.toDouble() ?? 0);

  /// GET /members doesn't return durationMonths — fall back to the catalog,
  /// then to the difference between start and end date.
  int get effectiveDurationMonths {
    if (durationMonths > 0) return durationMonths;
    if (_catalogPlan != null) return _catalogPlan!.durationMonths;
    if (startDateRaw != null && endDateRaw != null) {
      return (endDateRaw!.year - startDateRaw!.year) * 12 +
          endDateRaw!.month -
          startDateRaw!.month;
    }
    return 0;
  }

  bool get hasPrice => effectivePrice > 0;
  bool get hasDuration => effectiveDurationMonths > 0;

  String get formattedPrice => hasPrice ? formatRupees(effectivePrice) : 'N/A';

  String get durationLabel {
    final m = effectiveDurationMonths;
    if (m <= 0) return 'N/A';
    return '$m month${m == 1 ? '' : 's'}';
  }

  // ── Display helpers ─────────────────────────────────────────

  String get initials => initialsOf(fullName);

  /// Alias used by MemberCard
  String get name => fullName;

  /// Alias used by MemberCard
  String get plan => planDisplayName;

  String get startDate => startDateRaw == null
      ? 'N/A'
      : DateFormat('dd MMM yyyy').format(startDateRaw!.toLocal());

  String get endDate => endDateRaw == null
      ? 'N/A'
      : DateFormat('dd MMM yyyy').format(endDateRaw!.toLocal());

  /// Alias used by MemberCard (join date = start date)
  String get joinDate => startDate;

  // ── JSON ────────────────────────────────────────────────────

  factory OwnerMemberModel.fromJson(Map<String, dynamic> json) {
    return OwnerMemberModel(
      // POST returns `id`, GET returns `_id`
      id: parseString(json['_id'] ?? json['id']),
      fullName: parseString(json['fullName']),
      planName: parseString(json['planName']),
      phone: parseString(json['phone']),
      email: parseString(json['email']),
      gymId: parseString(json['gymId']),
      membershipPlan: parseString(json['membershipPlan']),
      price: parseDouble(json['price']),
      durationMonths: parseInt(json['durationMonths']),
      startDateRaw: parseDate(json['startDate']),
      endDateRaw: parseDate(json['endDate']),
      status: json['status'] == null ? 'ACTIVE' : parseString(json['status']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'planName': planName,
    'phone': phone,
    'email': email,
    'membershipPlan': membershipPlan,
  };
}
