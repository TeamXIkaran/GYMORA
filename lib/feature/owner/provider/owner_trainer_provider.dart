import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/owner_trainer_service.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class TrainerProvider extends ChangeNotifier {
  List<OwnerTrainerModel> _trainers = [];
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<OwnerTrainerModel> get trainers => List.unmodifiable(_trainers);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;
    await fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trainers = await TrainerService.getTrainers();
      _hasLoaded = true;
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrainer({
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
      final newTrainer = await TrainerService.addTrainer(
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

  /// [filterIndex] → 0 = All, 1 = Active, 2 = Inactive
  List<OwnerTrainerModel> filterByStatus(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return _trainers.where((t) => t.isActive).toList();
      case 2:
        return _trainers.where((t) => !t.isActive).toList();
      default:
        return trainers;
    }
  }

  void reset() {
    _trainers = [];
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
