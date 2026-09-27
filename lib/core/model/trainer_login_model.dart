class TrainerLoginModel {
  final String trainerId;
  final String fullName;
  final String email;
  final String phone;
  final String? specialization;
  final int? experience;
  final String? role;
  final String? gymId;
  final String? gymName;
  final String? token;

  const TrainerLoginModel({
    required this.trainerId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.specialization,
    this.experience,
    this.role,
    this.gymId,
    this.gymName,
    this.token,
  });

  factory TrainerLoginModel.fromJson(Map<String, dynamic> json) {
    return TrainerLoginModel(
      trainerId: _stringValue(
        json['trainerId'] ?? json['trainer_id'] ?? json['id'],
      ),
      fullName: _stringValue(
        json['fullName'] ?? json['full_name'] ?? json['name'],
      ),
      email: _stringValue(json['email']),
      phone: _stringValue(
        json['phone'] ?? json['mobile'] ?? json['phoneNumber'],
      ),
      specialization: _nullableString(
        json['specialization'],
      ),
      experience: _intValue(
        json['experience'],
      ),
      role: _nullableString(
        json['role'],
      ),
      gymId: _nullableString(
        json['gymId'] ?? json['gym_id'],
      ),
      gymName: _nullableString(
        json['gymName'] ?? json['gym_name'],
      ),
      token: _nullableString(
        json['token'] ?? json['accessToken'] ?? json['access_token'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainerId': trainerId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'experience': experience,
      'role': role,
      'gymId': gymId,
      'gymName': gymName,
      'token': token,
    };
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    if (result.isEmpty) return null;

    return result;
  }

  static int? _intValue(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}