import 'dart:convert';

import 'package:flutter_inventory/core/api/api_endpoints.dart';
import 'package:flutter_inventory/core/api/api_service.dart';
import 'package:flutter_inventory/models/barang.dart';
import 'package:flutter_inventory/models/paginated_barang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangService {
  final ApiService apiService = ApiService();

  // ============================================================
  // GET SEMUA BARANG
  // ============================================================

  Future<List<Barang>> getBarang() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.getRequest(
      "${ApiEndpoints.barang}?per_page=100",
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json["data"];

      return data.map((e) => Barang.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil data barang");
  }

  // ============================================================
  // TAMBAH BARANG
  // ============================================================

  Future<bool> tambahBarang(
    String namaBarang,
    int stock,
    double harga,
    String? lokasi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.postRequest(
      ApiEndpoints.barang,
      {
        "nama_barang": namaBarang,
        "stock": stock,
        "harga": harga,
        "lokasi": lokasi,
      },
      token: token,
    );

    return response.statusCode == 201;
  }

  // ============================================================
  // UPDATE DATA BARANG
  // ============================================================
  //
  // UPDATE BARANG TIDAK MENGUBAH STOCK.
  //
  // Stock hanya berubah melalui:
  // - barangMasuk()
  // - barangKeluar()
  //
  // ============================================================

  Future<bool> updateBarang(
    int id,
    String namaBarang,
    double harga,
    String? lokasi,
    String? keterangan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.putRequest(
      "${ApiEndpoints.barang}/$id",
      {
        "nama_barang": namaBarang,
        "harga": harga,
        "lokasi": lokasi,
        "keterangan": keterangan,
      },
      token: token,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // DELETE BARANG
  // ============================================================

  Future<bool> deleteBarang(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.deleteRequest(
      "${ApiEndpoints.barang}/$id",
      token: token,
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // SEARCH BARANG
  // ============================================================

  Future<List<Barang>> searchBarang(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url =
        "${ApiEndpoints.barang}?search=${Uri.encodeQueryComponent(keyword)}";

    final response = await apiService.getRequest(
      url,
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json["data"];

      return data.map((e) => Barang.fromJson(e)).toList();
    }

    throw Exception("Gagal mencari barang");
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Future<PaginatedBarang> getBarangPerPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.getRequest(
      "${ApiEndpoints.barang}?page=$page",
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return PaginatedBarang.fromJson(json);
    }

    throw Exception("Gagal mengambil data barang");
  }

  // ============================================================
  // BARANG MASUK
  // ============================================================

  Future<bool> barangMasuk({
    required int barangId,
    required int jumlah,
    double? hargaSatuan,
    String? orderOleh,
    String? dikirimOleh,
    String? untukSiapa,
    String? diketahuiOleh,
    String? lokasi,
    String? keterangan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.postRequest(
      ApiEndpoints.barangMasuk,
      {
        "barang_id": barangId,
        "jumlah": jumlah,
        "harga_satuan": hargaSatuan,
        "order_oleh": orderOleh,
        "dikirim_oleh": dikirimOleh,
        "untuk_siapa": untukSiapa,
        "diketahui_oleh": diketahuiOleh,
        "lokasi": lokasi,
        "keterangan": keterangan,
      },
      token: token,
    );

    return response.statusCode == 201;
  }

  // ============================================================
  // BARANG KELUAR
  // ============================================================

  Future<bool> barangKeluar({
    required int barangId,
    required int jumlah,
    double? hargaSatuan,
    String? diambilOleh,
    String? untukSiapa,
    String? diketahuiOleh,
    String? lokasi,
    String? keterangan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await apiService.postRequest(
      ApiEndpoints.barangKeluar,
      {
        "barang_id": barangId,
        "jumlah": jumlah,
        "harga_satuan": hargaSatuan,
        "diambil_oleh": diambilOleh,
        "untuk_siapa": untukSiapa,
        "diketahui_oleh": diketahuiOleh,
        "lokasi": lokasi,
        "keterangan": keterangan,
      },
      token: token,
    );

    return response.statusCode == 201;
  }
}
