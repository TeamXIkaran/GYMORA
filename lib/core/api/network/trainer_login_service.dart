import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';

class TrainerLoginService {
  final ApiHelper _apiHelper;

  TrainerLoginService({ApiHelper? apiHelper})
    : _apiHelper = apiHelper ?? ApiHelper();

  Future<ApiResponse<OwnerTrainerModel>> createTrainer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String specialization,
    required int experience,
  }) async {
    final response = await _apiHelper
        .post<Map<String, dynamic>>('api/trainers', {
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'specialization': specialization,
          'experience': experience,
        });

    if (!response.success || response.data == null) {
      return ApiResponse<OwnerTrainerModel>(
        success: false,
        message: response.message ?? 'Failed to add trainer',
      );
    }

    final data = response.data!;

    final trainerJson = data['trainer'];

    if (trainerJson is! Map<String, dynamic>) {
      return ApiResponse<OwnerTrainerModel>(
        success: false,
        message: 'Invalid trainer response from server',
      );
    }

    return ApiResponse<OwnerTrainerModel>(
      success: true,
      message: response.message ?? 'Trainer added successfully',
      data: OwnerTrainerModel.fromJson(trainerJson),
    );
  }
}
