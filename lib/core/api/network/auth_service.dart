import 'package:karan_fitness/core/api/base_api/api_helper.dart';
import 'package:karan_fitness/core/api/base_api/api_response.dart';
import 'package:karan_fitness/core/model/user_model.dart';

class AuthService {
  final ApiHelper _api;

  AuthService({ApiHelper? api}) : _api = api ?? ApiHelper();

  /// Login for all roles (owner / trainer / client).
  /// Endpoint: POST /api/auth/login
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    final response = await _api.post<Map<String, dynamic>>(
      'api/auth/login',
      request.toJson(),
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Login failed',
        statusCode: response.statusCode,
      );
    }
    
    try {
      final loginData = LoginResponse.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      return ApiResponse.success(
        loginData,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to parse login response');
    }
  }

  /// Owner creates a trainer.
  /// Endpoint: POST /api/auth/create-trainer
  Future<ApiResponse<UserModel>> createTrainer(
    CreateUserRequest request,
  ) async {
    final response = await _api.post<Map<String, dynamic>>(
      'api/auth/create-trainer',
      request.toJson(),
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Failed to create trainer',
        statusCode: response.statusCode,
      );
    }

    try {
      final user = UserModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      return ApiResponse.success(
        user,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to parse response');
    }
  }

  /// Owner or Trainer creates a client.
  /// Endpoint: POST /api/auth/create-client
  Future<ApiResponse<UserModel>> createClient(CreateUserRequest request) async {
    final response = await _api.post<Map<String, dynamic>>(
      'api/auth/create-client',
      request.toJson(),
    );

    if (!response.success || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'Failed to create client',
        statusCode: response.statusCode,
      );
    }

    try {
      final user = UserModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      return ApiResponse.success(
        user,
        message: response.data!['message']?.toString(),
      );
    } catch (e) {
      return ApiResponse.error('Failed to parse response');
    }
  }
}
