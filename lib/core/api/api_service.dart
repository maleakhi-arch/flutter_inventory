import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<http.Response> getRequest(
    String url, {
    String? token,
  }) async {
    return await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }

  Future<http.Response> postRequest(
    String url,
    Map<String, dynamic> body, {
    String? token, 
  }) async {
    return await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> putRequest(
    String url,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return await http.put(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteRequest(
    String url, {
    String? token,
  }) async {
    return await http.delete(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }
}