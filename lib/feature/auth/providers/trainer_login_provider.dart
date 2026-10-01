import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/core/api/network/trainer_login_service.dart';
import 'package:gymora_fitness_management/core/api/network/owner_trainer_service.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/model/trainer_login_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

// ============================================================
// TRAINER LOGIN PROVIDER
// ============================================================

enum TrainerStatus { initial, loading, success, error }

class TrainerLoginProvider extends ChangeNotifier {
  final TrainerLoginService _trainerService;

  TrainerLoginProvider({TrainerLoginService? trainerService})
    : _trainerService = trainerService ?? TrainerLoginService();

  TrainerStatus _status = TrainerStatus.initial;

  TrainerLoginModel? _loggedInTrainer;

  String? _errorMessage;
  String? _successMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  TrainerStatus get status => _status;

  TrainerLoginModel? get loggedInTrainer => _loggedInTrainer;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  bool get isLoading => _status == TrainerStatus.loading;

  bool get isSuccess => _status == TrainerStatus.success;

  bool get hasTrainer => _loggedInTrainer != null;

  // ============================================================
  // TRAINER LOGIN
  // POST /api/trainers/login
  //
  // {
  //   "trainerId": "0002",
  //   "password": "Barani00"
  // }
  // ============================================================

  Future<bool> loginTrainer({
    required String trainerId,
    required String password,
  }) async {
    _status = TrainerStatus.loading;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();

    try {
      final response = await _trainerService.loginTrainer(
        trainerId: trainerId.trim(),
        password: password,
      );

      if (response.success && response.data != null) {
        _loggedInTrainer = response.data;

        _status = TrainerStatus.success;
        _successMessage = response.message ?? 'Trainer login successful';

        notifyListeners();
        return true;
      }

      _status = TrainerStatus.error;
      _errorMessage = response.message ?? 'Invalid Trainer ID or password';

      notifyListeners();
      return false;
    } catch (error) {
      _status = TrainerStatus.error;
      _errorMessage = 'Unable to sign in. Check your connection and try again.';

      debugPrint('TRAINER_LOGIN_ERROR: ${error.runtimeType}');

      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // CLEAR LOGIN STATE
  // ============================================================

  void clearState() {
    _status = TrainerStatus.initial;

    _loggedInTrainer = null;

    _errorMessage = null;
    _successMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    if (_status == TrainerStatus.error) {
      _status = TrainerStatus.initial;
    }

    notifyListeners();
  }
}

// ============================================================
// OWNER TRAINER MANAGEMENT PROVIDER
// ============================================================

class OwnerTrainerProvider extends ChangeNotifier {
  List<OwnerTrainerModel> _trainers = [];

  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  List<OwnerTrainerModel> get trainers => List.unmodifiable(_trainers);

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  bool get hasLoaded => _hasLoaded;

  String? get error => _error;

  // ============================================================
  // ENSURE TRAINERS LOADED
  // ============================================================

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;

    await fetchTrainers();
  }

  // ============================================================
  // FETCH TRAINERS
  // ============================================================

  Future<void> fetchTrainers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _trainers = await OwnerTrainerService.getTrainers();

      _hasLoaded = true;
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ADD TRAINER
  // ============================================================
  Future<bool> addTrainer({
    required String trainerId,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String specialization,
    required int experience,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;

    notifyListeners();

    try {
      final newTrainer = await OwnerTrainerService.addTrainer(
        trainerId: trainerId,
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        specialization: specialization,
        experience: experience,
      );

      _trainers = [newTrainer, ..._trainers];

      return true;
    } catch (e) {
      _error = cleanError(e);

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  // ============================================================
  // FILTER TRAINERS
  //
  // 0 = All
  // 1 = Active
  // 2 = Inactive
  // ============================================================

  List<OwnerTrainerModel> filterByStatus(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return _trainers.where((trainer) => trainer.isActive).toList();

      case 2:
        return _trainers.where((trainer) => !trainer.isActive).toList();

      default:
        return trainers;
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _trainers = [];

    _hasLoaded = false;

    _error = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}
