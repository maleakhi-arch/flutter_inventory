class ApiEndpoints {
  static const String baseUrl =
      "https://medifra.net/inventory/api";

  static const String login = "$baseUrl/login";
  static const String firebaseLogin = "$baseUrl/firebase-login";
  static const String logout = "$baseUrl/logout";
  static const String dashboard = "$baseUrl/dashboard";

  static const String barang = "$baseUrl/barang";

  static const String barangMasuk =
      "$baseUrl/barang-masuk";

  static const String barangKeluar =
      "$baseUrl/barang-keluar";

  static const String histori =
      "$baseUrl/histori-stok";

  static const String user = "$baseUrl/users";
  static const String users = "$baseUrl/users";

  static const String exportBarang =
      "$baseUrl/export/barang";

  static const String report =
      "$baseUrl/report";
}