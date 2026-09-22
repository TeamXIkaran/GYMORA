

import 'package:gymora_fitness_management/core/utils/formatters.dart';

/// Wraps the entire `/api/owner/dashboard` response.
class DashboardModel {
  final OwnerInfo owner;
  final DashboardSummary summary;
  final RevenueOverview revenueOverview;
  final List<RecentMember> recentMembers;
  final List<TrainerOverviewItem> trainerOverview;

  DashboardModel({
    required this.owner,
    required this.summary,
    required this.revenueOverview,
    required this.recentMembers,
    required this.trainerOverview,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // The API wraps everything under `data`
    final data = json['data'] is Map ? asJsonMap(json['data']) : json;

    return DashboardModel(
      owner: OwnerInfo.fromJson(asJsonMap(data['owner'])),
      summary: DashboardSummary.fromJson(asJsonMap(data['summary'])),
      revenueOverview: RevenueOverview.fromJson(
        asJsonMap(data['revenueOverview']),
      ),
      recentMembers: asJsonList(
        data['recentMembers'],
      ).map(RecentMember.fromJson).toList(),
      trainerOverview: asJsonList(
        data['trainerOverview'],
      ).map(TrainerOverviewItem.fromJson).toList(),
    );
  }
}

// ── Sub-models ─────────────────────────────────────────────────

class OwnerInfo {
  final String name;
  final String gymName;
  final String gymId;

  OwnerInfo({required this.name, required this.gymName, required this.gymId});

  String get initials => initialsOf(name);

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      name: parseString(json['name']),
      gymName: parseString(json['gymName']),
      gymId: parseString(json['gymId']),
    );
  }
}

class DashboardSummary {
  final int totalMembers;
  final int totalTrainers;
  final double totalRevenue;

  DashboardSummary({
    required this.totalMembers,
    required this.totalTrainers,
    required this.totalRevenue,
  });

  /// Compact form for stat cards: ₹30K, ₹1.5L, ₹2.3Cr
  String get formattedRevenue => formatRupeesCompact(totalRevenue);

  /// Full form for detail rows: ₹30,000 / ₹1,50,000
  String get formattedRevenueFull => formatRupees(totalRevenue);

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalMembers: parseInt(json['totalMembers']),
      totalTrainers: parseInt(json['totalTrainers']),
      totalRevenue: parseDouble(json['totalRevenue']),
    );
  }
}

class RevenueOverview {
  final double revenue;
  final double currentMonthRevenue;
  final double previousMonthRevenue;
  final double percentageChange;

  RevenueOverview({
    required this.revenue,
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.percentageChange,
  });

  /// A % change against ₹0 last month is meaningless, so don't show it.
  bool get hasComparison => previousMonthRevenue > 0;

  String get formattedCurrentMonth => formatRupees(currentMonthRevenue);

  factory RevenueOverview.fromJson(Map<String, dynamic> json) {
    return RevenueOverview(
      revenue: parseDouble(json['revenue']),
      currentMonthRevenue: parseDouble(json['currentMonthRevenue']),
      previousMonthRevenue: parseDouble(json['previousMonthRevenue']),
      percentageChange: parseDouble(json['percentageChange']),
    );
  }
}

class RecentMember {
  final String id;
  final String fullName;
  final String membershipPlan;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  RecentMember({
    required this.id,
    required this.fullName,
    required this.membershipPlan,
    required this.status,
    this.startDate,
    this.endDate,
  });

  String get initials => initialsOf(fullName);

  /// "PREMIUM" → "Premium Membership"
  String get planDisplayName => planLabelFromKey(membershipPlan);

  /// ACTIVE / EXPIRING / EXPIRED, derived from endDate.
  String get displayStatus => computeMembershipStatus(status, endDate);

  factory RecentMember.fromJson(Map<String, dynamic> json) {
    return RecentMember(
      id: parseString(json['id'] ?? json['_id']),
      fullName: parseString(json['fullName']),
      membershipPlan: parseString(json['membershipPlan']),
      status: parseString(json['status']),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
    );
  }
}

class TrainerOverviewItem {
  final String id;
  final String fullName;
  final String specialization;
  final int experience;
  final String status;

  TrainerOverviewItem({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.experience,
    required this.status,
  });

  String get initials => initialsOf(fullName);

  bool get isActive => status.toLowerCase() == 'active';

  factory TrainerOverviewItem.fromJson(Map<String, dynamic> json) {
    return TrainerOverviewItem(
      id: parseString(json['id'] ?? json['_id']),
      fullName: parseString(json['fullName']),
      specialization: parseString(json['specialization']),
      experience: parseInt(json['experience']),
      status: parseString(json['status']),
    );
  }
}
