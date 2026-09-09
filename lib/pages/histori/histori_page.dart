import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/ui/app_state_view.dart';
import 'package:intl/intl.dart';

import 'package:flutter_inventory/core/services/histori_service.dart';
import 'package:flutter_inventory/models/histori_stok.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  final HistoriService historiService = HistoriService();
  final TextEditingController searchController = TextEditingController();

  List<HistoriStok> semuaHistori = [];
  List<HistoriStok> historiList = [];

  bool isLoading = true;

  String selectedFilter = "semua";

  @override
  void initState() {
    super.initState();
    loadHistori();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD DATA
  // =========================================================

  Future<void> loadHistori({String search = ""}) async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final data = await historiService.getHistori(search: search);

      if (!mounted) return;

      setState(() {
        semuaHistori = data;
        historiList = _filterData(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR HISTORI = $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  List<HistoriStok> _filterData(List<HistoriStok> data) {
    switch (selectedFilter) {
      case "masuk":
        return data.where((e) => e.jenisTransaksi == "masuk").toList();

      case "keluar":
        return data.where((e) => e.jenisTransaksi == "keluar").toList();

      case "tambah":
        return data.where((e) => e.aksi == "tambah").toList();

      case "edit":
        return data.where((e) => e.aksi == "edit").toList();

      case "hapus":
        return data.where((e) => e.aksi == "hapus").toList();

      default:
        return data;
    }
  }

  void _ubahFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      historiList = _filterData(semuaHistori);
    });
  }

  // =========================================================
  // FORMAT
  // =========================================================

  String formatTanggal(String tanggal) {
    if (tanggal.isEmpty) {
      return "-";
    }

    try {
      final date = DateTime.parse(tanggal).toLocal();

      return DateFormat("dd MMMM yyyy • HH:mm", "id_ID").format(date);
    } catch (_) {
      return tanggal;
    }
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    ).format(value);
  }

  String formatSelisih(int value) {
    if (value > 0) {
      return "+$value";
    }

    return value.toString();
  }

  // =========================================================
  // WARNA / ICON
  // =========================================================

  Color getColor(HistoriStok histori) {
    if (histori.jenisTransaksi == "masuk") {
      return Colors.green;
    }

    if (histori.jenisTransaksi == "keluar") {
      return Colors.red;
    }

    switch (histori.aksi) {
      case "tambah":
        return Colors.green;

      case "edit":
        return Colors.orange;

      case "hapus":
        return Colors.red;

      case "update_stock":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  IconData getIcon(HistoriStok histori) {
    if (histori.jenisTransaksi == "masuk") {
      return Icons.south_west_rounded;
    }

    if (histori.jenisTransaksi == "keluar") {
      return Icons.north_east_rounded;
    }

    switch (histori.aksi) {
      case "tambah":
        return Icons.add_circle;

      case "edit":
        return Icons.edit;

      case "hapus":
        return Icons.delete;

      case "update_stock":
        return Icons.sync_alt_rounded;

      default:
        return Icons.history;
    }
  }

  String getActionName(HistoriStok histori) {
    if (histori.jenisTransaksi == "masuk") {
      return "BARANG MASUK";
    }

    if (histori.jenisTransaksi == "keluar") {
      return "BARANG KELUAR";
    }

    switch (histori.aksi) {
      case "tambah":
        return "TAMBAH";

      case "edit":
        return "EDIT";

      case "hapus":
        return "HAPUS";

      case "update_stock":
        return "UPDATE STOCK";

      default:
        return histori.aksi.toUpperCase();
    }
  }

  // =========================================================
  // FILTER CHIP
  // =========================================================

  Widget _filterChip(String value, String label) {
    final selected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      side: BorderSide(
        color: selected ? const Color(0xffbfdbfe) : const Color(0xffe5e7eb),
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xffeff6ff),
      labelStyle: TextStyle(
        color: selected ? const Color(0xff2563eb) : const Color(0xff4b5563),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      onSelected: (_) {
        _ubahFilter(value);
      },
    );
  }
  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionalRow(IconData icon, String title, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _detailRow(icon, title, value);
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Histori Stok",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Riwayat perubahan dan transaksi inventory.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff6b7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffe5e7eb)),
                      ),
                      child: IconButton(
                        tooltip: "Refresh Histori",
                        onPressed: () {
                          loadHistori(search: searchController.text);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // SEARCH + FILTER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffe5e7eb)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Cari nama barang pada histori...",
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: "Hapus pencarian",
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {});
                                    loadHistori();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                        ),
                        onSubmitted: (value) {
                          loadHistori(search: value);
                        },
                        onChanged: (value) {
                          setState(() {});
                          if (value.isEmpty) {
                            loadHistori();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Filter Aktivitas",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff374151),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterChip("semua", "Semua"),
                          _filterChip("masuk", "Barang Masuk"),
                          _filterChip("keluar", "Barang Keluar"),
                          _filterChip("tambah", "Tambah"),
                          _filterChip("edit", "Edit"),
                          _filterChip("hapus", "Hapus"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "${historiList.length} aktivitas",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff6b7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // LIST
                Expanded(
                  child: isLoading
                      ? const AppStateView.loading(
                          title: "Memuat histori",
                          message: "Sedang mengambil aktivitas inventory.",
                        )
                      : historiList.isEmpty
                      ? AppStateView.empty(
                          icon: Icons.history_rounded,
                          title: "Histori tidak ditemukan",
                          message: searchController.text.trim().isNotEmpty
                              ? "Tidak ada aktivitas yang cocok dengan pencarian."
                              : selectedFilter != "semua"
                              ? "Tidak ada aktivitas pada filter yang dipilih."
                              : "Aktivitas inventory akan muncul di sini.",
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              loadHistori(search: searchController.text),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: historiList.length,
                            itemBuilder: (context, index) {
                              return _buildHistoriCard(historiList[index]);
                            },
                          ),
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
  // CARD HISTORI
  // =========================================================

  Widget _buildHistoriCard(HistoriStok histori) {
    final color = getColor(histori);

    final bool isMasuk = histori.jenisTransaksi == "masuk";

    final bool isKeluar = histori.jenisTransaksi == "keluar";

    final bool isTransaksi = isMasuk || isKeluar;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(getIcon(histori), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    histori.namaBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getActionName(histori),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =================================================
            // STOK
            // =================================================
            _detailRow(
              Icons.inventory_2_outlined,
              "Stock",
              "${histori.stockSebelum} → ${histori.stockSesudah}",
              bold: true,
            ),

            _detailRow(
              histori.selisih >= 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              "Selisih",
              formatSelisih(histori.selisih),
              valueColor: histori.selisih >= 0 ? Colors.green : Colors.red,
              bold: true,
            ),

            // =================================================
            // KHUSUS TRANSAKSI
            // =================================================
            if (isTransaksi) ...[
              const Divider(height: 24),

              _detailRow(
                Icons.numbers_rounded,
                "Jumlah",
                histori.jumlah.toString(),
                bold: true,
              ),

              _detailRow(
                Icons.payments_outlined,
                "Harga Satuan",
                formatRupiah(histori.hargaSatuan),
                bold: true,
              ),

              if (isMasuk) ...[
                _optionalRow(
                  Icons.shopping_cart_outlined,
                  "Order Oleh",
                  histori.orderOleh,
                ),

                _optionalRow(
                  Icons.local_shipping_outlined,
                  "Dikirim Oleh",
                  histori.dikirimOleh,
                ),
              ],

              if (isKeluar)
                _optionalRow(
                  Icons.person_outline,
                  "Diambil Oleh",
                  histori.diambilOleh,
                ),

              _optionalRow(
                Icons.person_pin_outlined,
                "Untuk",
                histori.untukSiapa,
              ),

              _optionalRow(
                Icons.verified_user_outlined,
                "Diketahui Oleh",
                histori.diketahuiOleh,
              ),

              _optionalRow(
                Icons.location_on_outlined,
                "Lokasi",
                histori.lokasi,
              ),
            ],

            const Divider(height: 24),

            // =================================================
            // USER & KETERANGAN
            // =================================================
            _detailRow(Icons.person_outline, "User", histori.userName),

            _detailRow(
              Icons.description_outlined,
              isTransaksi ? "Keterangan" : "Alasan",
              histori.keterangan ?? "-",
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  formatTanggal(histori.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
