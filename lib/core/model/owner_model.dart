class OwnerModel {
  final String name;
  final String initials;
  final String email;
  final String phone;
  final String gymName;
  final String role;
  final bool isVerified;
  final String? profileImageUrl;
  final String joinDate;
  final String address;
  final String city;
  final String state;

  const OwnerModel({
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.gymName,
    required this.role,
    required this.isVerified,
    this.profileImageUrl,
    required this.joinDate,
    required this.address,
    required this.city,
    required this.state,
  });
}
