// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_inventory/core/api/api_endpoints.dart';
import 'package:flutter_inventory/core/api/api_service.dart';
import 'package:flutter_inventory/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final ApiService apiService = ApiService();

  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await apiService.getRequest(
      ApiEndpoints.users,
      token: token,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json["data"];

      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil user");
  }

  Future<bool> tambahUser(
    String nama,
    String email,
    String password,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await apiService.postRequest(ApiEndpoints.users, {
      "name": nama,
      "email": email,
      "password": password,
      "role": role,
    }, token: token);

    print("========== TAMBAH USER ==========");
    print("URL : ${ApiEndpoints.users}");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("=================================");

    return response.statusCode == 201;
  }

  Future<bool> updateUser(
    int id,
    String name,
    String email,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await apiService.putRequest("${ApiEndpoints.user}/$id", {
      "name": name,
      "email": email,
      "role": role,
    }, token: token);

    print("========== UPDATE USER ==========");
    print("URL : ${ApiEndpoints.user}/$id");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("================================");

    return response.statusCode == 200;
  }

  Future<bool> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await apiService.deleteRequest(
      "${ApiEndpoints.users}/$id",
      token: token,
    );

    print("========== DELETE USER ==========");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("================================");

    return response.statusCode == 200;
  }
}
