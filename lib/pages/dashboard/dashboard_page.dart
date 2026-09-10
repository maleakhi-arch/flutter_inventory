import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/ui/app_state_view.dart';
import 'package:flutter_inventory/core/services/dashboard_service.dart';
// Langkah 1 — Import Service Tambahan ✅
import 'package:flutter_inventory/core/services/export_service.dart';
import 'package:flutter_inventory/core/services/auth_service.dart';
import 'package:flutter_inventory/models/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService service = DashboardService();
  // Object exportService dihapus karena method bersifat static
  final AuthService authService = AuthService();

  DashboardModel? dashboard;
  bool isLoading = true;

  // STATE VARIABEL TANGGAL BARU
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // METHOD DENGAN PENGIRIMAN FILTER TANGGAL
  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true; // Set loading true saat refresh filter tanggal
      });

      final data = await service.getDashboard(
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
      );

      setState(() {
        dashboard = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  // METHOD UNTUK MENAMPILKAN DATE RANGE PICKER
  Future<void> pilihTanggal() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (result == null) return;

    startDate = result.start;
    endDate = result.end;

    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await ExportService.exportBarang();
            },
          ),
        ],
      ),
      body: isLoading
          ? const AppStateView.loading(
              title: "Memuat dashboard",
              message: "Sedang mengambil data inventory.",
            )
          : dashboard == null
          ? AppStateView.error(
              title: "Dashboard gagal dimuat",
              message: "Data dashboard tidak dapat diambil dari server.",
              onAction: loadDashboard,
            )
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 28,
                  16,
                  isMobile ? 16 : 28,
                  32,
                ),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pilihTanggal,
                      icon: const Icon(Icons.calendar_month_outlined, size: 19),
                      label: Text(
                        startDate != null && endDate != null
                            ? "${startDate!.day}/${startDate!.month}/${startDate!.year} - "
                                  "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                            : "Pilih Periode",
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isMobile ? 1.22 : 1.55,
                    children: [
                      _summaryCard(
                        "Total Barang",
                        dashboard!.totalBarang.toString(),
                        Icons.inventory_2_outlined,
                        const Color(0xff2563eb),
                      ),
                      _summaryCard(
                        "Total Stok",
                        dashboard!.totalStok.toString(),
                        Icons.warehouse_outlined,
                        const Color(0xfff59e0b),
                      ),
                      _summaryCard(
                        "Barang Aman",
                        dashboard!.barangAman.toString(),
                        Icons.check_circle_outline_rounded,
                        const Color(0xff16a34a),
                      ),
                      _summaryCard(
                        "Stok Rendah",
                        dashboard!.barangSekarat.toString(),
                        Icons.warning_amber_rounded,
                        const Color(0xffdc2626),
                      ),
                      _summaryCard(
                        "Masuk Hari Ini",
                        dashboard!.barangMasukHariIni.toString(),
                        Icons.south_west_rounded,
                        const Color(0xff16a34a),
                      ),
                      _summaryCard(
                        "Keluar Hari Ini",
                        dashboard!.barangKeluarHariIni.toString(),
                        Icons.north_east_rounded,
                        const Color(0xffdc2626),
                      ),
                    ],
                  ),

                  // Komponen Aktivitas Terbaru
                  const SizedBox(height: 25),
                  const Text(
                    "Aktivitas Terbaru",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  dashboard?.aktivitas == null || dashboard!.aktivitas.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "Belum ada aktivitas terbaru",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dashboard!.aktivitas.length,
                          itemBuilder: (context, index) {
                            final item = dashboard!.aktivitas[index];

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    item.aksi == "tambah"
                                        ? Icons.add
                                        : item.aksi == "edit"
                                        ? Icons.edit
                                        : Icons.delete,
                                  ),
                                ),
                                title: Text(item.namaBarang),
                                subtitle: Text(
                                  "${item.namaUser ?? '-'} • ${item.namaAksi}",
                                ),
                                trailing: Text(
                                  item.selisih >= 0
                                      ? "+${item.selisih}"
                                      : "${item.selisih}",
                                  style: TextStyle(
                                    color: item.selisih >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  // Komponen Grafik Perubahan Stok
                  const SizedBox(height: 30),
                  const Text(
                    "Grafik Perubahan Stok",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 15),

                  dashboard?.grafik == null || dashboard!.grafik.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                "Belum ada data grafik",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 260,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(),
                                    rightTitles: const AxisTitles(),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >=
                                              dashboard!.grafik.length) {
                                            return const SizedBox();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              dashboard!
                                                  .grafik[value.toInt()]
                                                  .tanggal,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(
                                    dashboard!.grafik.length,
                                    (index) {
                                      final item = dashboard!.grafik[index];

                                      return BarChartGroupData(
                                        x: index,
                                        barsSpace: 4,
                                        barRods: [
                                          BarChartRodData(
                                            toY: item.masuk.toDouble(),
                                            width: 8,
                                            color: Colors.green,
                                          ),
                                          BarChartRodData(
                                            toY: item.keluar.toDouble(),
                                            width: 8,
                                            color: Colors.red,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  // ===============================
                  // GRAFIK KONDISI PERSEDIAAN
                  // ===============================
                  const SizedBox(height: 30),
                  const Text(
                    "Kondisi Persediaan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 240,
                        child:
                            dashboard == null ||
                                (dashboard!.barangAman == 0 &&
                                    dashboard!.barangSekarat == 0)
                            ? const Center(
                                child: Text(
                                  "Belum ada data kondisi stok",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    PieChartSectionData(
                                      value: dashboard!.barangAman.toDouble(),
                                      title: "${dashboard!.barangAman}",
                                      color: Colors.green,
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: dashboard!.barangSekarat
                                          .toDouble(),
                                      title: "${dashboard!.barangSekarat}",
                                      color: Colors.red,
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Aman (${dashboard?.barangAman ?? 0})",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      const SizedBox(width: 25),

                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Sekarat (${dashboard?.barangSekarat ?? 0})",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // CARD RINGKASAN PERIODE BARU
                  const SizedBox(height: 25),
                  dashboard?.summaryPeriode == null
                      ? const SizedBox()
                      : Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ringkasan Periode",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    "Barang Masuk: ${dashboard!.summaryPeriode.barangMasuk}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    "Barang Keluar: ${dashboard!.summaryPeriode.barangKeluar}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.history,
                                    color: Colors.grey,
                                  ),
                                  title: Text(
                                    "Total Aktivitas: ${dashboard!.summaryPeriode.aktivitas}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: Color(0xff6b7280),
            ),
          ),
        ],
      ),
    );
  }
}
