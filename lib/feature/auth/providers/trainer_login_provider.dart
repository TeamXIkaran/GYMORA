import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/trainer_login_service.dart';

import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';

enum TrainerStatus {
  initial,
  loading,
  success,
  error,
}

class TrainerProvider extends ChangeNotifier {
  final TrainerLoginService _trainerService;

  TrainerProvider({
    TrainerLoginService? trainerService,
  }) : _trainerService = trainerService ?? TrainerLoginService();

  TrainerStatus _status = TrainerStatus.initial;

  OwnerTrainerModel? _trainer;

  String? _errorMessage;
  String? _successMessage;

  TrainerStatus get status => _status;

  OwnerTrainerModel? get trainer => _trainer;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  bool get isLoading => _status == TrainerStatus.loading;

  bool get isSuccess => _status == TrainerStatus.success;

  Future<bool> createTrainer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String specialization,
    required int experience,
  }) async {
    _status = TrainerStatus.loading;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();

    try {
      final response = await _trainerService.createTrainer(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        specialization: specialization,
        experience: experience,
      );

      if (response.success && response.data != null) {
        _trainer = response.data;

        _status = TrainerStatus.success;
        _successMessage =
            response.message ?? 'Trainer added successfully';

        notifyListeners();

        return true;
      }

      _status = TrainerStatus.error;
      _errorMessage =
          response.message ?? 'Failed to add trainer';

      notifyListeners();

      return false;
    } catch (e) {
      _status = TrainerStatus.error;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  void clearState() {
    _status = TrainerStatus.initial;
    _trainer = null;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}