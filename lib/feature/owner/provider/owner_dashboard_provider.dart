import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/owner_dashboard_service.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Convenience accessors used by the profile / settings screens.
  OwnerInfo? get owner => _dashboard?.owner;
  DashboardSummary? get summary => _dashboard?.summary;

  /// Fetch only if nothing is loaded yet (safe to call from any screen).
  Future<void> ensureLoaded() async {
    if (_dashboard != null || _isLoading) return;
    await fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await OwnerDashboardService.getDashboard();
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call on logout so the next owner doesn't see stale data.
  void reset() {
    _dashboard = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
