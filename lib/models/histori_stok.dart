class HistoriStok {
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
  final String createdAt;
  final String userName;

  HistoriStok({
    required this.id,
    this.barangId,
    required this.namaBarang,
    required this.aksi,
    this.jenisTransaksi,
    required this.jumlah,
    required this.hargaSatuan,
    this.orderOleh,
    this.dikirimOleh,
    this.diambilOleh,
    this.untukSiapa,
    this.diketahuiOleh,
    this.lokasi,
    required this.stockSebelum,
    required this.stockSesudah,
    required this.selisih,
    this.keterangan,
    required this.createdAt,
    required this.userName,
  });

  factory HistoriStok.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double toDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    String? nullableString(dynamic value) {
      if (value == null) return null;

      final text = value.toString().trim();

      if (text.isEmpty || text.toLowerCase() == 'null') {
        return null;
      }

      return text;
    }

    String userName = "System";

    if (json["user"] is Map) {
      final user = json["user"] as Map;
      userName = user["name"]?.toString() ?? "System";
    }

    return HistoriStok(
      id: toInt(json["id"]),
      barangId: json["barang_id"] == null
          ? null
          : toInt(json["barang_id"]),
      namaBarang: json["nama_barang"]?.toString() ?? "-",
      aksi: json["aksi"]?.toString() ?? "-",

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
      createdAt: json["created_at"]?.toString() ?? "",
      userName: userName,
    );
  }
}