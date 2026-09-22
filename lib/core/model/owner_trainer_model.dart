
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class OwnerTrainerModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String gymId;
  final String specialization;
  final int experienceYears;

  /// Not returned by the API yet — null means "unknown", so the UI can hide it.
  final double? _rating;

  /// Not returned by the API yet — null means "unknown", so the UI can hide it.
  final int? _clients;

  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OwnerTrainerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.gymId = '',
    required this.specialization,
    required this.experienceYears,
    double? rating,
    int? clients,
    required this.status,
    this.createdAt,
    this.updatedAt,
  }) : _rating = rating,
       _clients = clients;

  String get initials => initialsOf(fullName);

  /// Alias used by TrainerCard
  String get name => fullName;

  /// Kept non-null so existing widgets (TrainerCard) keep compiling.
  double get rating => _rating ?? 0;
  int get clients => _clients ?? 0;

  /// Use these to hide rating / clients until the backend sends them.
  bool get hasRating => _rating != null;
  bool get hasClients => _clients != null;

  String get experience =>
      '$experienceYears ${experienceYears == 1 ? 'Year' : 'Years'}';

  bool get isActive => status.toLowerCase() == 'active';

  factory OwnerTrainerModel.fromJson(Map<String, dynamic> json) {
    return OwnerTrainerModel(
      id: parseString(json['_id'] ?? json['id']),
      fullName: parseString(json['fullName']),
      phone: parseString(json['phone']),
      email: parseString(json['email']),
      gymId: parseString(json['gymId']),
      specialization: parseString(json['specialization']),
      experienceYears: parseInt(json['experience']),
      rating: json['rating'] == null ? null : parseDouble(json['rating']),
      clients: json['clients'] == null ? null : parseInt(json['clients']),
      status: json['status'] == null ? 'ACTIVE' : parseString(json['status']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'specialization': specialization,
    'experience': experienceYears,
  };
}
