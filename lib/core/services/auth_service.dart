// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inventory/core/api/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Method Login
  Future<bool> login(String email, String password) async {
    try {
      // ===========================
      // LOGIN FIREBASE
      // ===========================
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ===========================
      // AMBIL FIREBASE ID TOKEN
      // ===========================
      final idToken = await credential.user?.getIdToken();

      if (idToken == null) {
        print("Gagal mengambil ID Token dari Firebase.");
        return false;
      }

      print("=================================");
      print("Firebase Login Berhasil");
      print("User : ${credential.user?.email}");
      print("ID TOKEN:");
      print(idToken);
      print("=================================");

      // ===========================
      // REQUEST KE LARAVEL
      // ===========================
      print("URL:");
      print(ApiEndpoints.firebaseLogin);

      print("REQUEST AKAN DIKIRIM");

      final response = await http.post(
        Uri.parse(ApiEndpoints.firebaseLogin),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"idToken": idToken}),
      );

      print("=================================");
      print("STATUS : ${response.statusCode}");
      print("BODY:");
      print(response.body);
      print("=================================");

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data["token"]);
      await prefs.setString("role", data["role"]);
      await prefs.setString("name", data["name"]);

      return true;
    } on FirebaseAuthException catch (e) {
      print("=================================");
      print("FIREBASE ERROR");
      print(e.code);
      print(e.message);
      print("=================================");

      return false;
    } catch (e, s) {
      print("=================================");
      print("HTTP ERROR");
      print(e);
      print(s);
      print("=================================");

      return false;
    }
  }

  // 2. Method Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
      } catch (e) {
        print(e);
      }
    }

    await _auth.signOut();
    await prefs.clear();
  }

  // 3. Method isLogin
  Future<bool> isLogin() async {
    return _auth.currentUser != null;
  }

  // 4. Method getEmail
  Future<String?> getEmail() async {
    return _auth.currentUser?.email;
  }

  // 5. Method getToken
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 6. Method getRole
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  // 7. Method getName
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }
}