// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../api/api_endpoints.dart';
import 'auth_service.dart';

class ExportService {
  static Future<void> exportBarang() async {
    try {
      final token = await AuthService().getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan");
      }

      final dio = Dio();

      // =========================================================
      // WEB
      // =========================================================

      if (kIsWeb) {
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

        return;
      }

      // =========================================================
      // WINDOWS / DESKTOP
      // =========================================================

      final directory = await getApplicationDocumentsDirectory();

      final filePath =
          "${directory.path}/Data_Barang_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      await dio.download(
        ApiEndpoints.exportBarang,
        filePath,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
          responseType: ResponseType.bytes,
        ),
      );

      await OpenFilex.open(filePath);

      print("Export berhasil");
      print(filePath);
    } catch (e) {
      print("Export error: $e");
      rethrow;
    }
  }
}