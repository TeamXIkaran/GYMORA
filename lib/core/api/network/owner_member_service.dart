import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';

class OwnerMemberService {
  /// Fetch all members.
  /// Endpoint: GET /api/members
  static Future<List<OwnerMemberModel>> getMembers() async {
    final response = await ApiService.get('api/members');

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid members response');
    }

    final members = data['members'];

    if (members is! List) {
      throw Exception('Members list not found in response');
    }

    return members
        .map(
          (json) =>
              OwnerMemberModel.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
  }

  /// Add a new member.
  ///
  /// Endpoint:
  /// POST /api/members
  ///
  /// Backend expects:
  /// {
  ///   "clientId": "0001",
  ///   "fullName": "Aarav Sharma",
  ///   "phone": "9876543210",
  ///   "email": "aarav@gmail.com",
  ///   "password": "Aarav123",
  ///   "trainerId": "0003",        // optional
  ///   "membershipPlan": "PREMIUM",
  ///   "startDate": "2026-09-27"
  /// }
  static Future<OwnerMemberModel> addMember({
    required String clientId,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    String? trainerId,
    required String membershipPlan,
    required String startDate,
  }) async {
    final trimmedTrainerId = trainerId?.trim() ?? '';

    final response = await ApiService.post('api/members', {
      'clientId': clientId,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      // Only send trainerId when a trainer was actually chosen.
      if (trimmedTrainerId.isNotEmpty) 'trainerId': trimmedTrainerId,
      'membershipPlan': membershipPlan,
      'startDate': startDate,
    });

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid member response');
    }

    final member = data['client'];

    if (member is! Map) {
      throw Exception('Member data not found in response');
    }

    return OwnerMemberModel.fromJson(Map<String, dynamic>.from(member));
  }

  /// Delete a member owned by the authenticated gym.
  /// Endpoint: DELETE /api/members/:id (Mongo ID or gym client ID)
  static Future<Map<String, dynamic>> deleteMember(String id) async {
    final response = await ApiService.delete(
      'api/members/${Uri.encodeComponent(id)}',
    );
    final data = response['data'];
    final member = data is Map ? data['member'] : null;
    if (member is Map) return Map<String, dynamic>.from(member);

    // Accept older server responses while the API is being rolled out.
    if (data is Map && data['id'] != null) return {'id': data['id']};
    throw Exception(response['message'] ?? 'Deleted member was not returned');
  }
}
