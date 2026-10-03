import 'package:intl/intl.dart';

import 'package:gymora_fitness_management/core/model/membership_plan_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class OwnerMemberModel {
  final String id;

  /// Client's login/registration ID.
  final String clientId;

  final String fullName;
  final String planName;
  final String phone;
  final String email;

  /// Gym ID returned by backend.
  final String gymId;

  /// Assigned trainer ID.
  final String trainerId;

  /// Assigned trainer name.
  final String trainerName;

  final String membershipPlan;

  final double price;
  final int durationMonths;

  final DateTime? startDateRaw;
  final DateTime? endDateRaw;

  /// Raw status from backend.
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  OwnerMemberModel({
    required this.id,
    this.clientId = '',
    required this.fullName,
    this.planName = '',
    required this.phone,
    required this.email,
    this.gymId = '',
    this.trainerId = '',
    this.trainerName = '',
    required this.membershipPlan,
    this.price = 0,
    this.durationMonths = 0,
    this.startDateRaw,
    this.endDateRaw,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // ── Status ─────────────────────────────────────────────────

  /// ACTIVE / EXPIRING / EXPIRED
  String get displayStatus => computeMembershipStatus(status, endDateRaw);

  bool get isActive => displayStatus == 'ACTIVE';

  bool get isExpiring => displayStatus == 'EXPIRING';

  bool get isExpired => displayStatus == 'EXPIRED';

  /// Days until membership ends.
  int? get daysLeft {
    if (endDateRaw == null) return null;

    return endDateRaw!.difference(DateTime.now()).inDays;
  }

  // ── Plan / Price ───────────────────────────────────────────

  MembershipPlan? get _catalogPlan => MembershipPlan.byKey(membershipPlan);

  /// Human-readable plan name.
  String get planDisplayName {
    if (planName.trim().isNotEmpty) {
      return planName;
    }

    return planLabelFromKey(membershipPlan);
  }

  /// GET /members may not return price.
  /// Fall back to membership plan catalog.
  double get effectivePrice {
    return price > 0 ? price : (_catalogPlan?.price.toDouble() ?? 0);
  }

  /// GET /members may not return durationMonths.
  /// Fall back to membership plan catalog.
  int get effectiveDurationMonths {
    if (durationMonths > 0) {
      return durationMonths;
    }

    if (_catalogPlan != null) {
      return _catalogPlan!.durationMonths;
    }

    if (startDateRaw != null && endDateRaw != null) {
      return (endDateRaw!.year - startDateRaw!.year) * 12 +
          endDateRaw!.month -
          startDateRaw!.month;
    }

    return 0;
  }

  bool get hasPrice => effectivePrice > 0;

  bool get hasDuration => effectiveDurationMonths > 0;

  String get formattedPrice {
    return hasPrice ? formatRupees(effectivePrice) : 'N/A';
  }

  String get durationLabel {
    final months = effectiveDurationMonths;

    if (months <= 0) {
      return 'N/A';
    }

    return '$months month${months == 1 ? '' : 's'}';
  }

  // ── Display helpers ─────────────────────────────────────────

  String get initials => initialsOf(fullName);

  /// Alias used by MemberCard.
  String get name => fullName;

  /// Alias used by MemberCard.
  String get plan => planDisplayName;

  String get startDate {
    if (startDateRaw == null) {
      return 'N/A';
    }

    return DateFormat('dd MMM yyyy').format(startDateRaw!.toLocal());
  }

  String get endDate {
    if (endDateRaw == null) {
      return 'N/A';
    }

    return DateFormat('dd MMM yyyy').format(endDateRaw!.toLocal());
  }

  /// Alias used by MemberCard.
  String get joinDate => startDate;

  // ── JSON ────────────────────────────────────────────────────

  factory OwnerMemberModel.fromJson(Map<String, dynamic> json) {
    final trainerJson = json['trainer'];

    String trainerId = '';
    String trainerName = '';

    if (trainerJson is Map) {
      trainerId = parseString(
        trainerJson['trainerId'] ?? trainerJson['id'] ?? trainerJson['_id'],
      );
      trainerName = parseString(trainerJson['fullName'] ?? trainerJson['name']);
    } else if (trainerJson is String) {
      trainerId = trainerJson;
    }
    trainerId = trainerId.isNotEmpty
        ? trainerId
        : parseString(json['trainerId']);
    trainerName = trainerName.isNotEmpty
        ? trainerName
        : parseString(json['trainerName']);

    return OwnerMemberModel(
      // POST returns `id`
      // GET may return `_id`
      id: parseString(json['id'] ?? json['_id']),

      clientId: parseString(json['clientId']),

      fullName: parseString(json['fullName']),

      planName: parseString(json['planName']),

      phone: parseString(json['phone']),

      email: parseString(json['email']),

      gymId: parseString(json['gymId']),

      trainerId: trainerId,

      trainerName: trainerName,

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'membershipPlan': membershipPlan,
      'experience': durationMonths,
      'status': status,
      if (startDateRaw != null) 'startDate': startDateRaw!.toIso8601String(),
      if (endDateRaw != null) 'endDate': endDateRaw!.toIso8601String(),
      if (price > 0) 'price': price,
      if (durationMonths > 0) 'durationMonths': durationMonths,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
