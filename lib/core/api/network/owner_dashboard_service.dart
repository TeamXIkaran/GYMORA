import 'package:gymora_fitness_management/core/api/base_api/api_service.dart';
import 'package:gymora_fitness_management/core/model/owner_dashboard_model.dart';

class OwnerDashboardService {
  static Future<OwnerDashboardModel> getDashboard() async {
    final response = await ApiService.get('api/owner/dashboard');

    return OwnerDashboardModel.fromJson(response);
  }
}
