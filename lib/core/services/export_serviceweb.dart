// ignore_for_file: avoid_print

import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';
import 'auth_service.dart';

class ExportService {
  static Future<void> exportBarang() async {
    try {
      final token = await AuthService().getToken();

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final dio = Dio();

      final response = await dio.get<List<int>>(
        ApiEndpoints.exportBarang,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept":
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data == null) {
        throw Exception("File Excel kosong");
      }

      final bytes = Uint8List.fromList(response.data!);

      final blob = html.Blob(
        [
          bytes,
        ],
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      );

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "Data_Barang_${DateTime.now().millisecondsSinceEpoch}.xlsx",
        )
        ..style.display = "none";

      html.document.body?.append(anchor);

      anchor.click();

      anchor.remove();

      html.Url.revokeObjectUrl(url);

      print("Excel berhasil didownload");
    } catch (e) {
      print("Export error: $e");
      rethrow;
    }
  }
}