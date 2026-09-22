/// Single source of truth for the plan catalog used by Add Member,
/// Add Membership and the Renew sheet.
///
/// NOTE: prices here must match the backend. Ideally the backend exposes
/// GET /api/plans and this list is fetched instead of hardcoded.
class MembershipPlan {
  final String key; // value sent to the API as `membershipPlan`
  final String name; // value sent to the API as `planName`
  final String shortName;
  final int price;
  final int durationMonths;

  const MembershipPlan({
    required this.key,
    required this.name,
    required this.shortName,
    required this.price,
    required this.durationMonths,
  });

  String get durationLabel =>
      '$durationMonths Month${durationMonths == 1 ? '' : 's'}';

  static const basic = MembershipPlan(
    key: 'BASIC',
    name: 'Basic Membership',
    shortName: 'Basic',
    price: 5000,
    durationMonths: 1,
  );

  static const standard = MembershipPlan(
    key: 'STANDARD',
    name: 'Standard Membership',
    shortName: 'Standard',
    price: 10000,
    durationMonths: 3,
  );

  static const premium = MembershipPlan(
    key: 'PREMIUM',
    name: 'Premium Membership',
    shortName: 'Premium',
    price: 15000,
    durationMonths: 6,
  );

  static const all = [basic, standard, premium];

  static MembershipPlan? byKey(String key) {
    final k = key.trim().toUpperCase();
    for (final p in all) {
      if (p.key == k) return p;
    }
    return null;
  }
}
