class SummaryPeriodeModel {

  final int barangMasuk;
  final int barangKeluar;
  final int aktivitas;

  SummaryPeriodeModel({
    required this.barangMasuk,
    required this.barangKeluar,
    required this.aktivitas,
  });

  factory SummaryPeriodeModel.fromJson(Map<String,dynamic> json){

    return SummaryPeriodeModel(

      barangMasuk: json["barang_masuk"] ?? 0,

      barangKeluar: json["barang_keluar"] ?? 0,

      aktivitas: json["aktivitas"] ?? 0,

    );

  }

}