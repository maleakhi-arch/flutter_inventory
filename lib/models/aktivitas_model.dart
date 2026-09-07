class AktivitasModel {
  final String namaBarang;
  final String aksi;
  final int stockSebelum;
  final int stockSesudah;
  final int selisih;
  final String? namaUser;
  final String createdAt;

  AktivitasModel({
    required this.namaBarang,
    required this.aksi,
    required this.stockSebelum,
    required this.stockSesudah,
    required this.selisih,
    required this.namaUser,
    required this.createdAt,
  });

  factory AktivitasModel.fromJson(Map<String, dynamic> json) {
    return AktivitasModel(
      namaBarang: json["nama_barang"] ?? "",
      aksi: json["aksi"] ?? "",
      stockSebelum: json["stock_sebelum"] ?? 0,
      stockSesudah: json["stock_sesudah"] ?? 0,
      selisih: json["selisih"] ?? 0,
      namaUser: json["user"]?["name"],
      createdAt: json["created_at"] ?? "",
    );
  }
}