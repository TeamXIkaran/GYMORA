import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/core/api/network/owner_member_service.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class MemberProvider extends ChangeNotifier {
  List<OwnerMemberModel> _members = [];
  bool _hasLoaded = false;

  /// True while GET /members is running (drives the list spinner).
  bool _isLoading = false;

  /// True while POST /members is running (drives the form button spinner).
  bool _isSubmitting = false;

  String? _error;

  List<OwnerMemberModel> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  // ── Filtered lists (status derived from endDate) ────────────

  List<OwnerMemberModel> get activeMembers =>
      _members.where((m) => m.isActive).toList();

  List<OwnerMemberModel> get expiringMembers =>
      _members.where((m) => m.isExpiring).toList();

  List<OwnerMemberModel> get expiredMembers =>
      _members.where((m) => m.isExpired).toList();

  // ── Fetch ───────────────────────────────────────────────────

  /// Fetch only once. Every tab can call this safely.
  /// The IndexedStack builds all tabs at startup,
  /// so this prevents duplicate requests.
  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;

    await fetchMembers();
  }

  Future<void> fetchMembers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await OwnerMemberService.getMembers();
      _hasLoaded = true;
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add Member ──────────────────────────────────────────────

  Future<bool> addMember({
    required String fullName,
    required String planName,
    required String phone,
    required String email,
    required String password,
    required String gymId,
    required String membershipPlan,
    required String startDate,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final newMember = await OwnerMemberService.addMember(
        fullName: fullName,
        planName: planName,
        phone: phone,
        email: email,
        password: password,
        gymId: gymId,
        membershipPlan: membershipPlan,
        startDate: startDate,
      );

      _members = [newMember, ..._members];

      return true;
    } catch (e) {
      _error = cleanError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Search / Filter ─────────────────────────────────────────

  List<OwnerMemberModel> searchMembers(String query) {
    if (query.trim().isEmpty) {
      return members;
    }

    final q = query.toLowerCase();

    return _members.where((m) {
      return m.fullName.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          m.planDisplayName.toLowerCase().contains(q);
    }).toList();
  }

  List<OwnerMemberModel> filterByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return members;
    }

    return _members
        .where((m) => m.displayStatus == status.toUpperCase())
        .toList();
  }

  // ── Reset ───────────────────────────────────────────────────

  void reset() {
    _members = [];
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  // ── Error ───────────────────────────────────────────────────

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
