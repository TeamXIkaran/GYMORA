import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';

class MemberService {
  /// Fetch all members.
  /// Endpoint: GET /api/members
  static Future<List<OwnerMemberModel>> getMembers() async {
    final response = await ApiService.get('api/members');

    final data = response['data'] as Map<String, dynamic>;
    final membersList = data['members'] as List;

    return membersList
        .map((json) => OwnerMemberModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new member.
  /// Endpoint: POST /api/members
  static Future<OwnerMemberModel> addMember({
    required String fullName,
    required String planName,
    required String phone,
    required String email,
    required String password,
    required String gymId,
    required String membershipPlan,
    required String startDate,
  }) async {
    final response = await ApiService.post('api/members', {
      'fullName': fullName,
      'planName': planName,
      'phone': phone,
      'email': email,
      'password': password,
      'gymId': gymId,
      'membershipPlan': membershipPlan,
      'startDate': startDate,
    });

    final data = response['data'] as Map<String, dynamic>? ?? response;

    final memberJson = data['member'] as Map<String, dynamic>? ?? data;

    return OwnerMemberModel.fromJson(memberJson);
  }
}
