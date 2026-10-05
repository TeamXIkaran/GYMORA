import 'package:flutter/material.dart';

import 'package:gymora_fitness_management/core/api/network/owner_member_service.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/core/utils/formatters.dart';

class OwnerMemberProvider extends ChangeNotifier {
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

  /// Add a new member. [trainerId] is optional — pass null for a
  /// self-guided member.
  ///
  /// Backend request:
  /// POST /api/members
  Future<bool> addMember({
    required String clientId,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    String? trainerId,
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

      _members = [newMember, ..._members];

      // Always re-fetch so the list carries the server's populated
      // trainer data (name / ids) instead of the raw create response.
      try {
        _members = await OwnerMemberService.getMembers();
      } catch (refreshError) {
        debugPrint('Member list refresh after creation failed: $refreshError');
      }

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

  Future<bool> deleteMember(String id) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      OwnerMemberModel? target;
      for (final member in _members) {
        if (member.id == id || member.clientId == id) {
          target = member;
          break;
        }
      }
      // The public API accepts the client's business ID (for example "0004").
      final apiId = target != null && target.clientId.isNotEmpty
          ? target.clientId
          : id;
      final deletedMember = await OwnerMemberService.deleteMember(apiId);
      final deletedId = deletedMember['id']?.toString();
      final deletedClientId = deletedMember['clientId']?.toString();
      _members.removeWhere(
        (member) =>
            member.id == id ||
            member.clientId == id ||
            (deletedId != null && member.id == deletedId) ||
            (deletedClientId != null &&
                deletedClientId.isNotEmpty &&
                member.clientId == deletedClientId),
      );
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
    _isLoading = false;
    _isSubmitting = false;
    _error = null;

    notifyListeners();
  }

  // ── Error ───────────────────────────────────────────────────

  void clearError() {
    _error = null;

    notifyListeners();
  }
}
