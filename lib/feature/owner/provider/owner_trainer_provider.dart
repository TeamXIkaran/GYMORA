import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/core/api/network/owner_trainer_service.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class OwnerTrainerProvider extends ChangeNotifier {
  List<OwnerTrainerModel> _trainers = [];
  final Map<String, OwnerTrainerDetails> _detailsByTrainerId = {};

  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  String? _error;

  List<OwnerTrainerModel> get trainers => List.unmodifiable(_trainers);

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  bool get hasLoaded => _hasLoaded;

  String? get error => _error;

  OwnerTrainerDetails? detailsFor(String trainerId) =>
      _detailsByTrainerId[trainerId];

  Future<void> fetchTrainerDetails(String trainerId) async {
    try {
      final details = await OwnerTrainerService.getTrainerDetails(trainerId);
      _detailsByTrainerId[trainerId] = details;
      notifyListeners();
    } catch (error) {
      _error = cleanError(error);
      notifyListeners();
    }
  }

  Future<bool> assignMember({
    required String trainerId,
    required String clientId,
  }) async {
    try {
      await OwnerTrainerService.assignMember(
        trainerId: trainerId,
        clientId: clientId,
      );
      _detailsByTrainerId.remove(trainerId);
      await fetchTrainers();
      return true;
    } catch (error) {
      _error = cleanError(error);
      notifyListeners();
      return false;
    }
  }

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
      _trainers = await OwnerTrainerService.getTrainers();

      _hasLoaded = true;
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

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

  Future<bool> deleteTrainer(String id) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      OwnerTrainerModel? trainer;
      for (final item in _trainers) {
        if (item.id == id || item.trainerId == id) {
          trainer = item;
          break;
        }
      }
      final deletedTrainer = await OwnerTrainerService.deleteTrainer(
        trainer?.trainerId.isNotEmpty == true ? trainer!.trainerId : id,
      );
      final deletedId = deletedTrainer['id']?.toString();
      final deletedTrainerId = deletedTrainer['trainerId']?.toString();
      _trainers.removeWhere(
        (item) =>
            item.id == id ||
            item.trainerId == id ||
            (deletedId != null && item.id == deletedId) ||
            (deletedTrainerId != null &&
                deletedTrainerId.isNotEmpty &&
                item.trainerId == deletedTrainerId),
      );
      if (trainer != null) _detailsByTrainerId.remove(trainer.trainerId);
      _hasLoaded = true;
      return true;
    } catch (error) {
      _error = cleanError(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// 0 = All
  /// 1 = Active
  /// 2 = Inactive
  List<OwnerTrainerModel> filterByStatus(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return _trainers.where((trainer) => trainer.isActive).toList();

      case 2:
        return _trainers.where((trainer) => !trainer.isActive).toList();

      default:
        return List.unmodifiable(_trainers);
    }
  }

  void reset() {
    _trainers = [];
    _detailsByTrainerId.clear();
    _hasLoaded = false;
    _isLoading = false;
    _isSubmitting = false;
    _error = null;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }
}
