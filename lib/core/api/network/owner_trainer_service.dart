import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';

class TrainerService {
  /// Fetch all trainers.
  /// Endpoint: GET /api/trainers
  static Future<List<OwnerTrainerModel>> getTrainers() async {
    final response = await ApiService.get('api/trainers');

    final data = response['data'] as Map<String, dynamic>;
    final trainersList = data['trainers'] as List;

    return trainersList
        .map((json) => OwnerTrainerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new trainer.
  /// Endpoint: POST /api/trainers
  static Future<OwnerTrainerModel> addTrainer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String gymId,
    required String specialization,
    required int experience,
  }) async {
    final response = await ApiService.post('api/trainers', {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'gymId': gymId,
      'specialization': specialization,
      'experience': experience,
    });

    final data = response['data'] as Map<String, dynamic>? ?? response;

    final trainerJson = data['trainer'] as Map<String, dynamic>? ?? data;

    return OwnerTrainerModel.fromJson(trainerJson);
  }
}
