import 'package:flutter/material.dart';

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
          ? DateTimeRange(
              start: startDate!,
              end: endDate!,
            )
          : DateTimeRange(
              start: initialDate,
              end: initialDate,
            ),
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
    } catch (e) {
      debugPrint('Export error: $e');
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
              ? "Excel berhasil dibuat."
              : "Gagal membuat file Excel.",
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

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
      backgroundColor: const Color(0xfff5f6fa),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 25),

            _buildFilter(),

            const SizedBox(height: 25),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Laporan Inventory",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Laporan perubahan stok dan aktivitas inventory",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const Spacer(),

        OutlinedButton.icon(
          onPressed: loadReport,
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh"),
        ),

        const SizedBox(width: 10),

        ElevatedButton.icon(
          onPressed: isExporting ? null : exportBarang,
          icon: isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.download),
          label: Text(
            isExporting ? "Export..." : "Download Excel",
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: Colors.blue,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: InkWell(
              onTap: pilihTanggal,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xffe5e7eb),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      startDate != null && endDate != null
                          ? "${formatDate(startDate)} - ${formatDate(endDate)}"
                          : "Pilih periode laporan",
                      style: TextStyle(
                        color: startDate != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          ElevatedButton.icon(
            onPressed: pilihTanggal,
            icon: const Icon(Icons.search),
            label: const Text("Tampilkan"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            Text(
              errorMessage ?? "Terjadi kesalahan.",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REPORT CONTENT
  // ============================================================

  Widget _buildReportContent() {
    if (report == null) {
      return const Center(
        child: Text("Belum ada data laporan."),
      );
    }

    return Column(
      children: [
        _buildSummary(),

        const SizedBox(height: 25),

        Expanded(
          child: _buildActivityTable(),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: "Barang Masuk",
            value: report!.barangMasuk.toString(),
            icon: Icons.arrow_downward,
            iconColor: Colors.green,
            backgroundColor: const Color(0xffe8f5e9),
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: _summaryCard(
            title: "Barang Keluar",
            value: report!.barangKeluar.toString(),
            icon: Icons.arrow_upward,
            iconColor: Colors.red,
            backgroundColor: const Color(0xffffebee),
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: _summaryCard(
            title: "Total Aktivitas",
            value: report!.aktivitas.toString(),
            icon: Icons.history,
            iconColor: Colors.blue,
            backgroundColor: const Color(0xffe3f2fd),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  "${data.length} aktivitas",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada aktivitas pada periode ini.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(
                          const Color(0xfff5f6fa),
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
                              "Aksi",
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
                              "Keterangan",
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
                                Text(
                                  formatDateTime(
                                    item.createdAt,
                                  ),
                                ),
                              ),

                              DataCell(
                                Text(
                                  item.namaBarang,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              DataCell(
                                _aksiBadge(item.aksi),
                              ),

                              DataCell(
                                Text(
                                  item.stockSebelum.toString(),
                                ),
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
                                Text(
                                  item.stockSesudah.toString(),
                                ),
                              ),

                              DataCell(
                                Text(
                                  item.keterangan.isEmpty
                                      ? "-"
                                      : item.keterangan,
                                ),
                              ),

                              DataCell(
                                Text(
                                  item.namaUser ?? "-",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AKSI BADGE
  // ============================================================

  Widget _aksiBadge(String aksi) {
    Color color;
    Color background;
    String text;

    switch (aksi) {
      case "tambah":
        color = Colors.green;
        background = const Color(0xffe8f5e9);
        text = "+ Tambah";
        break;

      case "hapus":
        color = Colors.red;
        background = const Color(0xffffebee);
        text = "Hapus";
        break;

      case "edit":
        color = Colors.orange;
        background = const Color(0xfffff3e0);
        text = "Edit";
        break;

      case "update_stock":
        color = Colors.blue;
        background = const Color(0xffe3f2fd);
        text = "Update";
        break;

      default:
        color = Colors.grey;
        background = const Color(0xffeeeeee);
        text = aksi;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}