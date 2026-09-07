// ignore_for_file: avoid_print

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

    print("==== GRAFIK ====");
    print(json);

    print("tanggal = ${json["tanggal"]} (${json["tanggal"].runtimeType})");
    print("masuk   = ${json["masuk"]} (${json["masuk"].runtimeType})");
    print("keluar  = ${json["keluar"]} (${json["keluar"].runtimeType})");

    return GrafikDashboardModel(
      tanggal: json["tanggal"].toString(),
      masuk: int.tryParse(json["masuk"].toString()) ?? 0,
      keluar: int.tryParse(json["keluar"].toString()) ?? 0,
    );
  }
}