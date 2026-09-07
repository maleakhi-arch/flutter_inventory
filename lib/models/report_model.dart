class ReportModel {
  final String startDate;
  final String endDate;

  final int barangMasuk;
  final int barangKeluar;
  final int aktivitas;

  final List<ReportItemModel> data;

  ReportModel({
    required this.startDate,
    required this.endDate,
    required this.barangMasuk,
    required this.barangKeluar,
    required this.aktivitas,
    required this.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final periode = json["periode"] ?? {};
    final summary = json["summary"] ?? {};

    return ReportModel(
      startDate: periode["start_date"] ?? "",
      endDate: periode["end_date"] ?? "",

      barangMasuk: summary["barang_masuk"] ?? 0,
      barangKeluar: summary["barang_keluar"] ?? 0,
      aktivitas: summary["aktivitas"] ?? 0,

      data: (json["data"] as List? ?? [])
          .map((e) => ReportItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ReportItemModel {
  final int id;
  final int barangId;
  final String namaBarang;
  final String aksi;

  final int stockSebelum;
  final int stockSesudah;
  final int selisih;

  final String keterangan;
  final int? userId;

  final String createdAt;
  final String? namaUser;

  ReportItemModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.aksi,
    required this.stockSebelum,
    required this.stockSesudah,
    required this.selisih,
    required this.keterangan,
    required this.userId,
    required this.createdAt,
    required this.namaUser,
  });

  factory ReportItemModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"];

    return ReportItemModel(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      barangId: int.tryParse(json["barang_id"]?.toString() ?? "") ?? 0,

      namaBarang: json["nama_barang"]?.toString() ?? "",
      aksi: json["aksi"]?.toString() ?? "",

      stockSebelum: int.tryParse(json["stock_sebelum"]?.toString() ?? "0") ?? 0,

      stockSesudah: int.tryParse(json["stock_sesudah"]?.toString() ?? "0") ?? 0,

      selisih: int.tryParse(json["selisih"]?.toString() ?? "0") ?? 0,

      keterangan: json["keterangan"]?.toString() ?? "",

      userId: int.tryParse(json["user_id"]?.toString() ?? ""),

      createdAt: json["created_at"]?.toString() ?? "",

      namaUser: user != null ? user["name"]?.toString() : null,
    );
  }
}
