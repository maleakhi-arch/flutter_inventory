import 'package:flutter_inventory/models/barang.dart';

class PaginatedBarang {
  final List<Barang> data;
  final int currentPage;
  final int lastPage;

  PaginatedBarang({
    required this.data,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedBarang.fromJson(Map<String, dynamic> json) {
    return PaginatedBarang(
      data: (json["data"] as List)
          .map((e) => Barang.fromJson(e))
          .toList(),
      currentPage: json["meta"]["current_page"],
      lastPage: json["meta"]["last_page"],
    );
  }
}