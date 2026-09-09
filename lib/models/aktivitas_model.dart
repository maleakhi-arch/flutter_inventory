class AktivitasModel {
  final String namaBarang;
  final String aksi;
  final String? jenisTransaksi;
  final int stockSebelum;
  final int stockSesudah;
  final int selisih;
  final String? namaUser;
  final String createdAt;

  AktivitasModel({
    required this.namaBarang,
    required this.aksi,
    required this.jenisTransaksi,
    required this.stockSebelum,
    required this.stockSesudah,
    required this.selisih,
    required this.namaUser,
    required this.createdAt,
  });

  factory AktivitasModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return AktivitasModel(
      namaBarang: json["nama_barang"]?.toString() ?? "",
      aksi: json["aksi"]?.toString() ?? "",
      jenisTransaksi: json["jenis_transaksi"]?.toString(),
      stockSebelum: toInt(json["stock_sebelum"]),
      stockSesudah: toInt(json["stock_sesudah"]),
      selisih: toInt(json["selisih"]),
      namaUser: json["user"] is Map
          ? json["user"]["name"]?.toString()
          : null,
      createdAt: json["created_at"]?.toString() ?? "",
    );
  }

  String get namaAksi {
    if (jenisTransaksi == "masuk") {
      return "Barang Masuk";
    }

    if (jenisTransaksi == "keluar") {
      return "Barang Keluar";
    }

    switch (aksi) {
      case "tambah":
        return "Tambah Barang";
      case "edit":
        return "Edit Barang";
      case "hapus":
        return "Hapus Barang";
      case "update_stock":
        return "Update Stock";
      default:
        return aksi;
    }
  }
}
