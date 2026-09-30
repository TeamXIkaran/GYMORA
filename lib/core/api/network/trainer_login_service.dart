import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/model/trainer_login_model.dart';
import 'package:gymora_fitness_management/core/service/secure_storage_service.dart';

class TrainerLoginService {
  final ApiHelper _apiHelper;

  TrainerLoginService({ApiHelper? apiHelper})
    : _apiHelper = apiHelper ?? ApiHelper();

  // ============================================================
  // TRAINER LOGIN
  // POST /api/trainers/login
  // ============================================================

  Future<ApiResponse<TrainerLoginModel>> loginTrainer({
    required String trainerId,
    required String password,
  }) async {
    final response = await _apiHelper.post<Map<String, dynamic>>(
      'trainers/login',
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

    // Backend success check
    if (data['success'] != true) {
      return ApiResponse<TrainerLoginModel>(
        success: false,
        message:
            data['message']?.toString() ?? 'Invalid Trainer ID or password',
      );
    }

    try {
      // Support both:
      //
      // 1. Root response:
      // {
      //   "success": true,
      //   "trainerId": "0002",
      //   "fullName": "...",
      //   "token": "..."
      // }
      //
      // 2. Nested response:
      // {
      //   "success": true,
      //   "data": {
      //     "trainerId": "0002",
      //     "fullName": "...",
      //     "token": "..."
      //   }
      // }

      final trainerData = data['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['data'])
          : data;

      // If token is at root but trainer data is nested,
      // copy token into trainerData.
      final rootToken =
          data['token'] ?? data['accessToken'] ?? data['access_token'];

      if (!trainerData.containsKey('token') && rootToken != null) {
        trainerData['token'] = rootToken;
      }

      final trainer = TrainerLoginModel.fromJson(trainerData);

      // ==========================================================
      // TOKEN CHECK
      // ==========================================================

      final token = trainer.token;

      if (token == null || token.isEmpty) {
        return ApiResponse<TrainerLoginModel>(
          success: false,
          message:
              'Login successful, but authentication token was not received.',
        );
      }

      // ==========================================================
      // SAVE TOKEN + TRAINER DATA
      // ==========================================================

      await SecureStorageService().saveUserData(
        token: token,
        employeeId: trainer.trainerId,
        username: trainer.fullName,
        email: trainer.email,
        role: trainer.role ?? 'trainer',
      );

      return ApiResponse<TrainerLoginModel>(
        success: true,
        message: data['message']?.toString() ?? 'Trainer login successful',
        data: trainer,
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
    final response = await _apiHelper.post<Map<String, dynamic>>('trainers', {
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
