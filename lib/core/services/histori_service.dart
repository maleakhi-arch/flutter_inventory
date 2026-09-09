import 'dart:convert';

import 'package:flutter_inventory/core/api/api_endpoints.dart';
import 'package:flutter_inventory/core/api/api_service.dart';
import 'package:flutter_inventory/models/histori_stok.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoriService {
  final ApiService apiService = ApiService();

  Future<List<HistoriStok>> getHistori({
    String search = "",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final queryParameters = <String, String>{};

    if (search.trim().isNotEmpty) {
      queryParameters["search"] = search.trim();
    }

    final uri = Uri.parse(
      ApiEndpoints.histori,
    ).replace(
      queryParameters:
          queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await apiService.getRequest(
      uri.toString(),
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json["data"] ?? [];

      return data
          .map(
            (e) => HistoriStok.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    throw Exception(
      "Gagal mengambil histori (${response.statusCode})",
    );
  }
}