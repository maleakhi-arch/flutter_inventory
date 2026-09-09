class GrafikDashboardModel {
  final String tanggal;
  final int masuk;
  final int keluar;

  GrafikDashboardModel({
    required this.tanggal,
    required this.masuk,
    required this.keluar,
  });

  factory GrafikDashboardModel.fromJson(Map<String, dynamic> json) {
    return GrafikDashboardModel(
      tanggal: json["tanggal"]?.toString() ?? "",
      masuk: int.tryParse(json["masuk"]?.toString() ?? "0") ?? 0,
      keluar: int.tryParse(json["keluar"]?.toString() ?? "0") ?? 0,
    );
  }
}
