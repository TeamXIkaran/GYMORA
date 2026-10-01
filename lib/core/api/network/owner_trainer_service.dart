import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';

class OwnerTrainerService {
  /// Fetch all trainers.
  /// Endpoint: GET /api/trainers
  static Future<List<OwnerTrainerModel>> getTrainers() async {
    final response = await ApiService.get('api/trainers');

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid trainers response');
    }

    final trainers = data['trainers'];

    if (trainers is! List) {
      throw Exception('Trainers list not found in response');
    }

    return trainers
        .map(
          (json) => OwnerTrainerModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  /// Add a new trainer.
  /// Endpoint: POST /api/trainers
  static Future<OwnerTrainerModel> addTrainer({
    required String trainerId,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String specialization,
    required int experience,
  }) async {
    final response = await ApiService.post('api/trainers', {
      'trainerId': trainerId,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'specialization': specialization,
      'experience': experience,
    });

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid trainer response');
    }

    final trainer = data['trainer'];

    if (trainer is! Map<String, dynamic>) {
      throw Exception('Trainer data not found in response');
    }

    return OwnerTrainerModel.fromJson(trainer);
  }

  /// Delete a trainer owned by the authenticated gym.
  /// Endpoint: DELETE /api/trainers/:id
  static Future<void> deleteTrainer(String id) async {
    await ApiService.delete('api/trainers/${Uri.encodeComponent(id)}');
  }
}
