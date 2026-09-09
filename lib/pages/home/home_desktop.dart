// ignore_for_file: unused_element

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/auth_service.dart';
import 'package:flutter_inventory/core/services/dashboard_service.dart';
import 'package:flutter_inventory/models/dashboard_model.dart';
import 'package:flutter_inventory/pages/barang/inventory_desktop.dart';
import 'package:flutter_inventory/pages/histori/histori_page.dart';
import 'package:flutter_inventory/pages/repot/report_desktop.dart';
import 'package:flutter_inventory/pages/user/user_desktop.dart';

import '../../widget/dashboard/dashboard_card.dart';
import '../../widget/dashboard/activity_card.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  int selectedIndex = 0;
  String? role;
  String? name;

  final DashboardService dashboardService = DashboardService();

  DashboardModel? dashboard;
  bool dashboardLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final authService = AuthService();

    final resultRole = await authService.getRole();
    final resultName = await authService.getName();

    if (!mounted) return;

    setState(() {
      role = resultRole;
      name = resultName;
    });
  }

  // =========================================================
  // LOAD DASHBOARD
  // =========================================================

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        dashboardLoading = true;
      });

      final data = await dashboardService.getDashboard();

      if (!mounted) return;

      setState(() {
        dashboard = data;
        dashboardLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');

      if (!mounted) return;

      setState(() {
        dashboardLoading = false;
      });
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // =========================================================
  // SIDEBAR
  // =========================================================

  Widget _buildSidebar() {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffe5e7eb))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // LOGO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xff2563eb),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEDIFRA',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Inventory System',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          _buildSectionTitle('MENU'),
          const SizedBox(height: 8),
          _buildMenuItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            title: 'Dashboard',
          ),
          _buildMenuItem(
            index: 1,
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
          ),
          _buildMenuItem(
            index: 2,
            icon: Icons.history_rounded,
            title: 'Histori Stok',
          ),
          _buildMenuItem(
            index: 3,
            icon: Icons.bar_chart_rounded,
            title: 'Report',
          ),
          if (role == 'admin')
            _buildMenuItem(
              index: 4,
              icon: Icons.people_alt_outlined,
              title: 'User',
            ),
          const Spacer(),
          // USER LOGIN CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffe5e7eb)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xffdbeafe),
                  child: Text(
                    (name?.isNotEmpty == true ? name![0] : 'U').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xff2563eb),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        (role ?? '-').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            index: -1,
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap:
              onTap ??
              () {
                setState(() {
                  selectedIndex = index;
                });
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? const Color(0xffeff6ff) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? const Color(0xff2563eb)
                      : const Color(0xff6b7280),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? const Color(0xff2563eb)
                        : const Color(0xff4b5563),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboard();

      case 1:
        return const InventoryDesktop();

      case 2:
        return const HistoriPage();

      case 3:
        return const ReportDesktop();

      case 4:
        return const UserDesktop();

      default:
        return _buildDashboard();
    }
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  Widget _buildDashboard() {
    if (dashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboard == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data dashboard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final data = dashboard!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================
          // HEADER
          // ===================================================
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pantau kondisi inventory dan aktivitas stok.',
                      style: const TextStyle(
                        color: Color(0xff6b7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // REFRESH BUTTON
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffe5e7eb)),
                ),
                child: IconButton(
                  tooltip: 'Refresh Dashboard',
                  onPressed: _loadDashboard,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Color(0xff4b5563),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ===================================================
          // SUMMARY CARDS
          // ===================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total Barang',
                  value: data.totalBarang.toString(),
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: DashboardCard(
                  title: 'Total Stok',
                  value: data.totalStok.toString(),
                  icon: Icons.warehouse,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: DashboardCard(
                  title: 'Barang Aman',
                  value: data.barangAman.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: DashboardCard(
                  title: 'Barang Sekarat',
                  value: data.barangSekarat.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ===================================================
          // AKTIVITAS HARI INI
          // ===================================================
          Row(
            children: [
              Expanded(
                child: _buildActivityStat(
                  title: 'Barang Masuk Hari Ini',
                  value: data.barangMasukHariIni.toString(),
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityStat(
                  title: 'Barang Keluar Hari Ini',
                  value: data.barangKeluarHariIni.toString(),
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),

              // EMPTY SPACE AGAR RAPI
              const Expanded(child: SizedBox()),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 22),

          // ===================================================
          // CHART + ACTIVITY
          // ===================================================
          SizedBox(
            height: 390,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CHART
                Expanded(flex: 7, child: _buildDashboardChart(data)),

                const SizedBox(width: 20),

                // ACTIVITY
                Expanded(flex: 4, child: _buildRecentActivity(data)),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ===================================================
          // KONDISI PERSEDIAAN
          // ===================================================
          _buildInventoryCondition(data),
        ],
      ),
    );
  }

  // =========================================================
  // MODERN SUMMARY CARD
  // =========================================================

  Widget _buildModernSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
            ],
          ),

          const Spacer(),

          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 7),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTIVITY STAT
  // =========================================================

  Widget _buildActivityStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff6b7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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
  // =========================================================
  // BAR CHART
  // =========================================================

  Widget _buildDashboardChart(DashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: data.grafik.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data grafik',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perubahan Stok',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aktivitas stok 7 hari terakhir',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildLegend(Colors.green, 'Masuk'),

                    const SizedBox(width: 18),

                    _buildLegend(Colors.red, 'Keluar'),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,

                      maxY: _getChartMax(data),

                      minY: 0,

                      borderData: FlBorderData(show: false),

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getChartInterval(data),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),

                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            interval: _getChartInterval(data),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 || index >= data.grafik.length) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  data.grafik[index].tanggal,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      barGroups: List.generate(data.grafik.length, (index) {
                        final item = data.grafik[index];

                        return BarChartGroupData(
                          x: index,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: item.masuk.toDouble(),
                              width: 9,
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),

                            BarChartRodData(
                              toY: item.keluar.toDouble(),
                              width: 9,
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  double _getChartMax(DashboardModel data) {
    double maxValue = 0;

    for (final item in data.grafik) {
      if (item.masuk > maxValue) {
        maxValue = item.masuk.toDouble();
      }

      if (item.keluar > maxValue) {
        maxValue = item.keluar.toDouble();
      }
    }

    if (maxValue <= 10) {
      return 10;
    }

    return (maxValue * 1.2).ceilToDouble();
  }

  double _getChartInterval(DashboardModel data) {
    final maxValue = _getChartMax(data);

    if (maxValue <= 10) {
      return 2;
    }

    if (maxValue <= 50) {
      return 10;
    }

    return (maxValue / 5).ceilToDouble();
  }

  // =========================================================
  // LEGEND
  // =========================================================

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // RECENT ACTIVITY
  // =========================================================

  Widget _buildRecentActivity(DashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.aktivitas.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'Aktivitas inventory terbaru',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: data.aktivitas.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada aktivitas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: data.aktivitas.length,
                    separatorBuilder: (context, index) {
                      return Divider(height: 1, color: Colors.grey.shade200);
                    },
                    itemBuilder: (context, index) {
                      final activity = data.aktivitas[index];

                      final bool isTambah = activity.selisih >= 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isTambah
                                    ? Colors.green.withOpacity(0.10)
                                    : Colors.red.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTambah
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isTambah ? Colors.green : Colors.red,
                                size: 17,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.namaBarang,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff111827),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${activity.namaUser ?? "System"} • ${activity.namaAksi}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xff6b7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              activity.selisih >= 0
                                  ? '+${activity.selisih}'
                                  : '${activity.selisih}',
                              style: TextStyle(
                                color: isTambah ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // KONDISI PERSEDIAAN
  // =========================================================

  Widget _buildInventoryCondition(DashboardModel data) {
    final total = data.barangAman + data.barangSekarat;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // TITLE
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kondisi Persediaan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status kesehatan stok saat ini',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 20),
                _buildConditionLegend(Colors.green, 'Aman', data.barangAman),
                const SizedBox(height: 12),
                _buildConditionLegend(
                  Colors.red,
                  'Sekarat',
                  data.barangSekarat,
                ),
              ],
            ),
          ),

          // PIE CHART
          SizedBox(
            width: 250,
            height: 200,
            child: total == 0
                ? const Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 52,
                          sections: [
                            PieChartSectionData(
                              value: data.barangAman.toDouble(),
                              title: '',
                              color: Colors.green,
                              radius: 58,
                            ),
                            PieChartSectionData(
                              value: data.barangSekarat.toDouble(),
                              title: '',
                              color: Colors.red,
                              radius: 58,
                            ),
                          ],
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            total.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Barang',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // PERCENTAGE
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPercentage('Aman', data.barangAman, total, Colors.green),
                const SizedBox(height: 18),
                _buildPercentage(
                  'Sekarat',
                  data.barangSekarat,
                  total,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionLegend(Color color, String title, int value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        Text(
          '($value)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildPercentage(String title, int value, int total, Color color) {
    final percentage = total == 0 ? 0 : (value / total * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$title ${percentage.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : value / total,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
