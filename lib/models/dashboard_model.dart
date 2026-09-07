import 'aktivitas_model.dart';
import 'grafik_dashboard_model.dart';
import 'summary_periode_model.dart';

class DashboardModel {
  final int totalBarang;
  final int totalStok;
  final int barangMasukHariIni;
  final int barangKeluarHariIni;
  final int barangAman;
  final int barangSekarat;

  final List<AktivitasModel> aktivitas;
  final List<GrafikDashboardModel> grafik;
  final SummaryPeriodeModel summaryPeriode;

  DashboardModel({
    required this.totalBarang,
    required this.totalStok,
    required this.barangMasukHariIni,
    required this.barangKeluarHariIni,
    required this.barangAman,
    required this.barangSekarat,
    required this.aktivitas,
    required this.grafik,
    required this.summaryPeriode,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final summary = json["summary"] ?? {};

    return DashboardModel(
      totalBarang: int.tryParse(summary["total_barang"].toString()) ?? 0,
      totalStok: int.tryParse(summary["total_stok"].toString()) ?? 0,
      barangMasukHariIni:
          int.tryParse(summary["barang_masuk_hari_ini"].toString()) ?? 0,
      barangKeluarHariIni:
          int.tryParse(summary["barang_keluar_hari_ini"].toString()) ?? 0,

      barangAman: int.tryParse(summary["barang_aman"].toString()) ?? 0,
      barangSekarat:
          int.tryParse(summary["barang_sekarat"].toString()) ?? 0,

      aktivitas: (json["aktivitas_terbaru"] as List? ?? [])
          .map((e) => AktivitasModel.fromJson(e))
          .toList(),

      grafik: (json["grafik"] as List? ?? [])
          .map((e) => GrafikDashboardModel.fromJson(e))
          .toList(),

      summaryPeriode: SummaryPeriodeModel.fromJson(
        json["summary_periode"] ?? {},
      ),
    );
  }
}
