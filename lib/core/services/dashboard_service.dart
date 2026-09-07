// ignore_for_file: avoid_print

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

    // KODE DEBUG TAMBAHAN SESUAI PERMINTAAN
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");

    print("===== DASHBOARD =====");
    print("URL: $url");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // KODE DEBUG ISI GRAFIK BARU ✅
      print("=========== ISI DATA GRAFIK ===========");
      if (json["grafik"] != null) {
        for (var item in json["grafik"]) {
          print(item);
        }
      } else {
        print("Data grafik null");
      }
      print("=======================================");

      // BLOK TRY-CATCH PARSING MODEL
      try {
        return DashboardModel.fromJson(json);
      } catch (e, s) {
        print("=========== ERROR DASHBOARD ===========");
        print(e);
        print(s);
        print("=======================================");
        rethrow;
      }
    }

    throw Exception("Gagal mengambil dashboard");
  }
}