import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/core/api/network/owner_member_service.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class MemberProvider extends ChangeNotifier {
  List<OwnerMemberModel> _members = [];
  bool _hasLoaded = false;

  /// True while GET /api/members is running.
  bool _isLoading = false;

  /// True while POST /api/members is running.
  bool _isSubmitting = false;

  String? _error;

  List<OwnerMemberModel> get members => List.unmodifiable(_members);

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  bool get hasLoaded => _hasLoaded;

  String? get error => _error;

  // ── Filtered Lists ─────────────────────────────────────────

  List<OwnerMemberModel> get activeMembers =>
      _members.where((m) => m.isActive).toList();

  List<OwnerMemberModel> get expiringMembers =>
      _members.where((m) => m.isExpiring).toList();

  List<OwnerMemberModel> get expiredMembers =>
      _members.where((m) => m.isExpired).toList();

  // ── Fetch Members ──────────────────────────────────────────

  /// Fetch members only once.
  ///
  /// Endpoint:
  /// GET /api/members
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
      final fetchedMembers = await OwnerMemberService.getMembers();

      _members = fetchedMembers;
      _hasLoaded = true;
    } catch (e) {
      _error = cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ── Add Member ──────────────────────────────────────────────

  /// Add a new member.
  ///
  /// Backend request:
  /// POST /api/members
  ///
  /// Body:
  /// {
  ///   "clientId": "0001",
  ///   "fullName": "Aarav Sharma",
  ///   "phone": "9876543210",
  ///   "email": "aarav@gmail.com",
  ///   "password": "Aarav123",
  ///   "trainerId": "0003",
  ///   "membershipPlan": "PREMIUM",
  ///   "startDate": "2026-09-27"
  /// }
  Future<bool> addMember({
    required String clientId,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String trainerId,
    required String membershipPlan,
    required String startDate,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;

    notifyListeners();

    try {
      final newMember = await OwnerMemberService.addMember(
        clientId: clientId,
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        trainerId: trainerId,
        membershipPlan: membershipPlan,
        startDate: startDate,
      );

      // Add newly created member at the top.
      _members = [newMember, ..._members];

      // Data is now available locally.
      _hasLoaded = true;

      return true;
    } catch (e) {
      _error = cleanError(e);

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  // ── Search Members ──────────────────────────────────────────

  List<OwnerMemberModel> searchMembers(String query) {
    if (query.trim().isEmpty) {
      return members;
    }

    final q = query.trim().toLowerCase();

    return _members.where((m) {
      return m.fullName.toLowerCase().contains(q) ||
          m.clientId.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          m.trainerName.toLowerCase().contains(q) ||
          m.planDisplayName.toLowerCase().contains(q);
    }).toList();
  }

  // ── Filter By Status ───────────────────────────────────────

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
