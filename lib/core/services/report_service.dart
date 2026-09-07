import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_endpoints.dart';
import '../services/auth_service.dart';
import '../../models/report_model.dart';

class ReportService {
  final AuthService authService = AuthService();

  Future<ReportModel> getReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan");
    }

    final queryParameters = <String, String>{};

    if (startDate != null) {
      queryParameters["start_date"] = _formatDate(startDate);
    }

    if (endDate != null) {
      queryParameters["end_date"] = _formatDate(endDate);
    }

    final uri = Uri.parse(
      ApiEndpoints.report,
    ).replace(
      queryParameters:
          queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Report gagal: ${response.statusCode}\n${response.body}",
      );
    }

    final json = jsonDecode(response.body);

    return ReportModel.fromJson(json);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return "${date.year}-$month-$day";
  }
}