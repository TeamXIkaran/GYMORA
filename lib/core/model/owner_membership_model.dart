class OwnerMembershipModel {
  final String memberName;
  final String initials;
  final String plan;
  final String price;
  final String startDate;
  final String expiryDate;
  final int daysLeft;
  final String status; // 'Active', 'Expiring Soon', 'Expired'

  const OwnerMembershipModel({
    required this.memberName,
    required this.initials,
    required this.plan,
    required this.price,
    required this.startDate,
    required this.expiryDate,
    required this.daysLeft,
    required this.status,
  });
}
