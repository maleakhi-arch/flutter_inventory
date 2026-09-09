import 'package:flutter/material.dart';
import '../../core/ui/app_state_view.dart';
import 'package:intl/intl.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/export_service.dart';
import '../../core/services/report_service.dart';
import '../../models/report_model.dart';

class ReportDesktop extends StatefulWidget {
  const ReportDesktop({super.key});

  @override
  State<ReportDesktop> createState() => _ReportDesktopState();
}

class _ReportDesktopState extends State<ReportDesktop> {
  final ReportService reportService = ReportService();
  final AuthService authService = AuthService();

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

  // ============================================================
  // LOAD REPORT
  // ============================================================

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
      debugPrint("Report error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Gagal mengambil data laporan.";
      });
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

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

    if (range == null) return;

    setState(() {
      startDate = range.start;
      endDate = range.end;
    });

    await loadReport();
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Future<void> exportBarang() async {
    if (isExporting) return;

    setState(() {
      isExporting = true;
    });

    bool berhasil = false;
    try {
      await ExportService.exportBarang();
      berhasil = true;
    } catch (_) {
      berhasil = false;
    }

    if (!mounted) return;

    setState(() {
      isExporting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? "Data barang berhasil diunduh."
              : "Gagal mengunduh data barang.",
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatRupiah(double value) {
    return NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    ).format(value);
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return "Pilih periode laporan";
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  String formatDateTime(String value) {
    if (value.isEmpty) return "-";

    try {
      final date = DateTime.parse(value).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day/$month/$year\n$hour:$minute";
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildFilter(),

            const SizedBox(height: 22),

            Expanded(
              child: isLoading
                  ? const AppStateView.loading(
                      title: "Memuat laporan",
                      message: "Sedang menghitung aktivitas inventory.",
                    )
                  : errorMessage != null
                  ? _buildError()
                  : _buildReportContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Laporan Inventory",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Pantau transaksi, nilai barang, dan perubahan stok berdasarkan periode.",
                style: TextStyle(color: Color(0xff6b7280), fontSize: 13),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: isLoading ? null : loadReport,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text("Refresh"),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: isExporting ? null : exportBarang,
          icon: isExporting
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.file_download_outlined, size: 18),
          label: Text(isExporting ? "Menyiapkan..." : "Download Data Barang"),
        ),
      ],
    );
  }
  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    final hasRange = startDate != null && endDate != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffeff6ff),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.date_range_outlined,
              color: Color(0xff2563eb),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Periode Laporan",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff374151),
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Pilih rentang tanggal transaksi",
                style: TextStyle(fontSize: 11, color: Color(0xff9ca3af)),
              ),
            ],
          ),
          const SizedBox(width: 22),
          Expanded(
            child: InkWell(
              onTap: pilihTanggal,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff8fafc),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffe5e7eb)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Color(0xff6b7280),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      hasRange
                          ? "${formatDate(startDate)}  —  ${formatDate(endDate)}"
                          : report != null
                          ? "${report!.startDate}  —  ${report!.endDate}"
                          : "Pilih periode laporan",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: hasRange || report != null
                            ? const Color(0xff374151)
                            : const Color(0xff9ca3af),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Color(0xff9ca3af),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: pilihTanggal,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text("Pilih Periode"),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return AppStateView.error(
      title: "Laporan gagal dimuat",
      message: errorMessage ?? "Terjadi kesalahan saat mengambil laporan.",
      onAction: loadReport,
    );
  }
  // ============================================================
  // REPORT CONTENT
  // ============================================================

  Widget _buildReportContent() {
    if (report == null) {
      return const Center(child: Text("Belum ada data laporan."));
    }

    return Column(
      children: [
        _buildSummary(),

        const SizedBox(height: 25),

        Expanded(child: _buildActivityTable()),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: "Barang Masuk",
                value: report!.barangMasuk.toString(),
                icon: Icons.south_west_rounded,
                iconColor: const Color(0xff16a34a),
                backgroundColor: const Color(0xffecfdf3),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: "Barang Keluar",
                value: report!.barangKeluar.toString(),
                icon: Icons.north_east_rounded,
                iconColor: const Color(0xffdc2626),
                backgroundColor: const Color(0xfffff1f2),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: "Total Aktivitas",
                value: report!.aktivitas.toString(),
                icon: Icons.history_rounded,
                iconColor: const Color(0xff2563eb),
                backgroundColor: const Color(0xffeff6ff),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: "Nilai Barang Masuk",
                value: formatRupiah(report!.nilaiBarangMasuk),
                icon: Icons.payments_outlined,
                iconColor: const Color(0xff16a34a),
                backgroundColor: const Color(0xffecfdf3),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: "Nilai Barang Keluar",
                value: formatRupiah(report!.nilaiBarangKeluar),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xffdc2626),
                backgroundColor: const Color(0xfffff1f2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff6b7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // ACTIVITY TABLE
  // ============================================================

  Widget _buildActivityTable() {
    final data = report!.data;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Text(
                  "Detail Aktivitas",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                  ),
                ),

                const Spacer(),

                Text(
                  "${data.length} aktivitas",
                  style: const TextStyle(
                    color: Color(0xff6b7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: data.isEmpty
                ? const AppStateView.empty(
                    icon: Icons.bar_chart_outlined,
                    title: "Tidak ada aktivitas",
                    message:
                        "Belum ada transaksi pada periode laporan yang dipilih.",
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columnSpacing: 28,
                              horizontalMargin: 18,
                              headingRowHeight: 50,
                              dataRowMinHeight: 58,
                              dataRowMaxHeight: 96,
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xfff8fafc),
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "Tanggal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Barang",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Jenis",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Jumlah",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Harga Satuan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Total Nilai",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Stok Sebelum",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Perubahan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Stok Sesudah",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Detail",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "User",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: data.map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(formatDateTime(item.createdAt)),
                                    ),
                                    DataCell(
                                      Text(
                                        item.namaBarang,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(_aksiBadge(item)),
                                    DataCell(
                                      Text(
                                        item.jumlah == 0
                                            ? "-"
                                            : item.jumlah.toString(),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item.hargaSatuan == 0
                                            ? "-"
                                            : formatRupiah(item.hargaSatuan),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        item.jumlah == 0
                                            ? "-"
                                            : formatRupiah(item.totalNilai),
                                      ),
                                    ),
                                    DataCell(
                                      Text(item.stockSebelum.toString()),
                                    ),
                                    DataCell(
                                      Text(
                                        "${item.selisih >= 0 ? '+' : ''}${item.selisih}",
                                        style: TextStyle(
                                          color: item.selisih >= 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(item.stockSesudah.toString()),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 220,
                                          maxWidth: 280,
                                        ),
                                        child: Text(
                                          item.detailTransaksi,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.45,
                                            color: Color(0xff4b5563),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(item.namaUser ?? "System")),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AKSI BADGE
  // ============================================================

  Widget _aksiBadge(ReportItemModel item) {
    Color color;
    Color background;

    if (item.jenisTransaksi == "masuk") {
      color = Colors.green;
      background = const Color(0xffe8f5e9);
    } else if (item.jenisTransaksi == "keluar") {
      color = Colors.red;
      background = const Color(0xffffebee);
    } else {
      switch (item.aksi) {
        case "tambah":
          color = Colors.green;
          background = const Color(0xffe8f5e9);
          break;
        case "hapus":
          color = Colors.red;
          background = const Color(0xffffebee);
          break;
        case "edit":
          color = Colors.orange;
          background = const Color(0xfffff3e0);
          break;
        default:
          color = Colors.blue;
          background = const Color(0xffe3f2fd);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.namaAksi,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
