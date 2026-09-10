import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/export_service.dart';
import '../../core/services/report_service.dart';
import '../../core/ui/app_state_view.dart';
import '../../models/report_model.dart';

class ReportMobile extends StatefulWidget {
  const ReportMobile({super.key});

  @override
  State<ReportMobile> createState() => _ReportMobileState();
}

class _ReportMobileState extends State<ReportMobile> {
  final ReportService reportService = ReportService();

  ReportModel? report;

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true;
  bool isExporting = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await reportService.getReport(
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      setState(() {
        report = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Report mobile error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Gagal mengambil data laporan.";
      });
    }
  }

  Future<void> pilihTanggal() async {
    final initialDate = startDate ?? DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(start: initialDate, end: initialDate),
    );

    if (range == null || !mounted) return;

    setState(() {
      startDate = range.start;
      endDate = range.end;
    });

    await loadReport();
  }

  Future<void> exportBarang() async {
    if (isExporting) return;

    setState(() {
      isExporting = true;
    });

    try {
      await ExportService.exportBarang();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data barang berhasil diunduh.")),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengunduh data barang.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    ).format(value);
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";

    return DateFormat("dd MMM yyyy", "id_ID").format(date);
  }

  String formatDateTime(String value) {
    if (value.isEmpty) return "-";

    try {
      final date = DateTime.parse(value).toLocal();

      return DateFormat("dd MMM yyyy • HH:mm", "id_ID").format(date);
    } catch (_) {
      return value;
    }
  }

  Color _activityColor(ReportItemModel item) {
    if (item.jenisTransaksi == "masuk") {
      return const Color(0xff16a34a);
    }

    if (item.jenisTransaksi == "keluar") {
      return const Color(0xffdc2626);
    }

    switch (item.aksi) {
      case "tambah":
        return const Color(0xff16a34a);
      case "edit":
        return const Color(0xfff59e0b);
      case "hapus":
        return const Color(0xffdc2626);
      default:
        return const Color(0xff2563eb);
    }
  }

  IconData _activityIcon(ReportItemModel item) {
    if (item.jenisTransaksi == "masuk") {
      return Icons.south_west_rounded;
    }

    if (item.jenisTransaksi == "keluar") {
      return Icons.north_east_rounded;
    }

    switch (item.aksi) {
      case "tambah":
        return Icons.add_circle_outline_rounded;
      case "edit":
        return Icons.edit_outlined;
      case "hapus":
        return Icons.delete_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xff6b7280)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xff374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionalRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _detailRow(label, value);
  }

  Widget _activityCard(ReportItemModel item) {
    final color = _activityColor(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(_activityIcon(item), color: color, size: 20),
        ),
        title: Text(
          item.namaBarang,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.namaAksi,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatDateTime(item.createdAt),
                style: const TextStyle(fontSize: 10, color: Color(0xff9ca3af)),
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 10),
          _detailRow("Jumlah", "${item.jumlah} unit"),
          _detailRow("Harga Satuan", formatRupiah(item.hargaSatuan)),
          _detailRow("Total Nilai", formatRupiah(item.totalNilai)),
          _detailRow("Stok", "${item.stockSebelum} → ${item.stockSesudah}"),
          _detailRow(
            "Perubahan",
            item.selisih > 0 ? "+${item.selisih}" : "${item.selisih}",
            valueColor: item.selisih >= 0
                ? const Color(0xff16a34a)
                : const Color(0xffdc2626),
          ),
          _optionalRow("Order Oleh", item.orderOleh),
          _optionalRow("Dikirim Oleh", item.dikirimOleh),
          _optionalRow("Diambil Oleh", item.diambilOleh),
          _optionalRow("Untuk Siapa", item.untukSiapa),
          _optionalRow("Diketahui", item.diketahuiOleh),
          _optionalRow("Lokasi", item.lokasi),
          _optionalRow("Keterangan", item.keterangan),
          _detailRow("User", item.namaUser ?? "-"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text(
          "Report",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: isLoading ? null : loadReport,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const AppStateView.loading(
              title: "Memuat report",
              message: "Sedang mengambil laporan inventory.",
            )
          : errorMessage != null
          ? AppStateView.error(
              title: "Report gagal dimuat",
              message: errorMessage!,
              onAction: loadReport,
            )
          : report == null
          ? const AppStateView.empty(
              icon: Icons.description_outlined,
              title: "Report belum tersedia",
              message: "Belum ada data laporan.",
            )
          : RefreshIndicator(
              onRefresh: loadReport,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffe5e7eb)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Periode Laporan",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff374151),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: pilihTanggal,
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              size: 19,
                            ),
                            label: Text(
                              startDate != null && endDate != null
                                  ? "${formatDate(startDate)} — ${formatDate(endDate)}"
                                  : "Pilih Periode",
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isExporting ? null : exportBarang,
                            icon: isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded, size: 18),
                            label: Text(
                              isExporting
                                  ? "Mengunduh..."
                                  : "Download Data Barang",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.18,
                    children: [
                      _summaryCard(
                        title: "Barang Masuk",
                        value: report!.barangMasuk.toString(),
                        icon: Icons.south_west_rounded,
                        color: const Color(0xff16a34a),
                      ),
                      _summaryCard(
                        title: "Barang Keluar",
                        value: report!.barangKeluar.toString(),
                        icon: Icons.north_east_rounded,
                        color: const Color(0xffdc2626),
                      ),
                      _summaryCard(
                        title: "Total Aktivitas",
                        value: report!.aktivitas.toString(),
                        icon: Icons.history_rounded,
                        color: const Color(0xff2563eb),
                      ),
                      _summaryCard(
                        title: "Nilai Masuk",
                        value: formatRupiah(report!.nilaiBarangMasuk),
                        icon: Icons.payments_outlined,
                        color: const Color(0xff16a34a),
                      ),
                      _summaryCard(
                        title: "Nilai Keluar",
                        value: formatRupiah(report!.nilaiBarangKeluar),
                        icon: Icons.payments_outlined,
                        color: const Color(0xffdc2626),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Detail Aktivitas",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111827),
                          ),
                        ),
                      ),
                      Text(
                        "${report!.data.length} aktivitas",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff6b7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report!.data.isEmpty)
                    const AppStateView.empty(
                      icon: Icons.history_rounded,
                      title: "Belum ada aktivitas",
                      message: "Tidak ada aktivitas pada periode ini.",
                    )
                  else
                    ...report!.data.map(_activityCard),
                ],
              ),
            ),
    );
  }
}
