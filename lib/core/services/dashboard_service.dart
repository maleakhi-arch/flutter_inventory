import 'dart:convert';

import 'package:flutter_inventory/core/api/api_endpoints.dart';
import 'package:flutter_inventory/core/api/api_service.dart';
import 'package:flutter_inventory/models/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  final ApiService api = ApiService();

  Future<DashboardModel> getDashboard({
    String? startDate,
    String? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    String url = ApiEndpoints.dashboard;
    if (startDate != null && endDate != null) {
      url += "?start_date=$startDate&end_date=$endDate";
    }

    final response = await api.getRequest(
      url,
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return DashboardModel.fromJson(json);
    }

    throw Exception("Gagal mengambil dashboard");
  }
}