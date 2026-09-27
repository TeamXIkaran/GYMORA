import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/model/trainer_login_model.dart';

class TrainerLoginService {
  final ApiHelper _apiHelper;

  TrainerLoginService({ApiHelper? apiHelper})
    : _apiHelper = apiHelper ?? ApiHelper();

  // ============================================================
  // TRAINER LOGIN
  // POST /api/trainers/login
  //
  // Request:
  // {
  //   "trainerId": "0002",
  //   "password": "Barani00"
  // }
  // ============================================================

  Future<ApiResponse<TrainerLoginModel>> loginTrainer({
    required String trainerId,
    required String password,
  }) async {
    final response = await _apiHelper.post<Map<String, dynamic>>(
      'api/trainers/login',
      {'trainerId': trainerId.trim(), 'password': password},
    );

    // API / network error
    if (!response.success || response.data == null) {
      return ApiResponse<TrainerLoginModel>(
        success: false,
        message: response.message ?? 'Invalid Trainer ID or password',
      );
    }

    final data = response.data!;

    // Backend response:
    // {
    //   "success": false,
    //   "message": "Invalid Trainer ID or password"
    // }
    if (data['success'] != true) {
      return ApiResponse<TrainerLoginModel>(
        success: false,
        message:
            data['message']?.toString() ?? 'Invalid Trainer ID or password',
      );
    }

    try {
      return ApiResponse<TrainerLoginModel>(
        success: true,
        message: data['message']?.toString() ?? 'Trainer login successful',
        data: TrainerLoginModel.fromJson(data),
      );
    } catch (e) {
      return ApiResponse<TrainerLoginModel>(
        success: false,
        message: 'Invalid trainer login response from server',
      );
    }
  }

  // ============================================================
  // CREATE TRAINER
  // POST /api/trainers
  // ============================================================

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
