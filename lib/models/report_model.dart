class ReportModel {
  final String startDate;
  final String endDate;
  final int barangMasuk;
  final int barangKeluar;
  final int aktivitas;
  final double nilaiBarangMasuk;
  final double nilaiBarangKeluar;
  final List<ReportItemModel> data;

  ReportModel({
    required this.startDate,
    required this.endDate,
    required this.barangMasuk,
    required this.barangKeluar,
    required this.aktivitas,
    required this.nilaiBarangMasuk,
    required this.nilaiBarangKeluar,
    required this.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final periode = json["periode"] ?? {};
    final summary = json["summary"] ?? {};
    int toInt(dynamic value) {
      return int.tryParse(value?.toString() ?? "") ?? 0;
    }

    double toDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? "") ?? 0;
    }

    return ReportModel(
      startDate: periode["start_date"]?.toString() ?? "",
      endDate: periode["end_date"]?.toString() ?? "",
      barangMasuk: toInt(summary["barang_masuk"]),
      barangKeluar: toInt(summary["barang_keluar"]),
      aktivitas: toInt(summary["aktivitas"]),
      nilaiBarangMasuk: toDouble(summary["nilai_barang_masuk"]),
      nilaiBarangKeluar: toDouble(summary["nilai_barang_keluar"]),
      data: (json["data"] as List? ?? [])
          .map((e) => ReportItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ReportItemModel {
  final int id;
  final int? barangId;
  final String namaBarang;
  final String aksi;
  final String? jenisTransaksi;
  final int jumlah;
  final double hargaSatuan;
  final String? orderOleh;
  final String? dikirimOleh;
  final String? diambilOleh;
  final String? untukSiapa;
  final String? diketahuiOleh;
  final String? lokasi;
  final int stockSebelum;
  final int stockSesudah;
  final int selisih;
  final String? keterangan;
  final int? userId;
  final String createdAt;
  final String? namaUser;

  ReportItemModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.aksi,
    required this.jenisTransaksi,
    required this.jumlah,
    required this.hargaSatuan,
    required this.orderOleh,
    required this.dikirimOleh,
    required this.diambilOleh,
    required this.untukSiapa,
    required this.diketahuiOleh,
    required this.lokasi,
    required this.stockSebelum,
    required this.stockSesudah,
    required this.selisih,
    required this.keterangan,
    required this.userId,
    required this.createdAt,
    required this.namaUser,
  });

  factory ReportItemModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      return int.tryParse(value?.toString() ?? "") ?? 0;
    }

    double toDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? "") ?? 0;
    }

    String? nullableString(dynamic value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) {
        return null;
      }
      return text;
    }

    String? namaUser;
    if (json["user"] is Map) {
      namaUser = json["user"]["name"]?.toString();
    }
    return ReportItemModel(
      id: toInt(json["id"]),
      barangId: json["barang_id"] == null ? null : toInt(json["barang_id"]),
      namaBarang: json["nama_barang"]?.toString() ?? "",
      aksi: json["aksi"]?.toString() ?? "",
      jenisTransaksi: nullableString(json["jenis_transaksi"]),
      jumlah: toInt(json["jumlah"]),
      hargaSatuan: toDouble(json["harga_satuan"]),
      orderOleh: nullableString(json["order_oleh"]),
      dikirimOleh: nullableString(json["dikirim_oleh"]),
      diambilOleh: nullableString(json["diambil_oleh"]),
      untukSiapa: nullableString(json["untuk_siapa"]),
      diketahuiOleh: nullableString(json["diketahui_oleh"]),
      lokasi: nullableString(json["lokasi"]),
      stockSebelum: toInt(json["stock_sebelum"]),
      stockSesudah: toInt(json["stock_sesudah"]),
      selisih: toInt(json["selisih"]),
      keterangan: nullableString(json["keterangan"]),
      userId: json["user_id"] == null ? null : toInt(json["user_id"]),
      createdAt: json["created_at"]?.toString() ?? "",
      namaUser: namaUser,
    );
  }

  double get totalNilai {
    return jumlah * hargaSatuan;
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

  String get detailTransaksi {
    final detail = <String>[];
    if (orderOleh != null) {
      detail.add("Order: $orderOleh");
    }
    if (dikirimOleh != null) {
      detail.add("Dikirim: $dikirimOleh");
    }
    if (diambilOleh != null) {
      detail.add("Diambil: $diambilOleh");
    }
    if (untukSiapa != null) {
      detail.add("Untuk: $untukSiapa");
    }
    if (diketahuiOleh != null) {
      detail.add("Diketahui: $diketahuiOleh");
    }
    if (lokasi != null) {
      detail.add("Lokasi: $lokasi");
    }
    if (keterangan != null) {
      detail.add("Ket: $keterangan");
    }
    return detail.isEmpty ? "-" : detail.join("\n");
  }
}
