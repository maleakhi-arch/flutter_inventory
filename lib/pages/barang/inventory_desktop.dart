// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/auth_service.dart';
import 'package:flutter_inventory/core/services/barang_service.dart';

import 'package:flutter_inventory/models/barang.dart';

import 'package:flutter_inventory/pages/barang/barang_masuk_page.dart';
import 'package:flutter_inventory/pages/barang/barang_keluar_page.dart';
import 'package:flutter_inventory/pages/barang/tambah_barang_page.dart';
import 'package:flutter_inventory/pages/barang/edit_barang_page.dart';

class InventoryDesktop extends StatefulWidget {
  const InventoryDesktop({super.key});

  @override
  State<InventoryDesktop> createState() => _InventoryDesktopState();
}

class _InventoryDesktopState extends State<InventoryDesktop> {
  final BarangService barangService = BarangService();
  final AuthService authService = AuthService();

  final TextEditingController searchController =
      TextEditingController();

  List<Barang> barangList = [];

  String? role;

  bool isLoading = true;
  bool isLoadMore = false;

  int currentPage = 1;
  int lastPage = 1;

  @override
  void initState() {
    super.initState();

    loadBarang();
    loadRole();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD BARANG
  // ============================================================

  Future<void> loadBarang() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await barangService.getBarangPerPage(1);

      if (!mounted) return;

      setState(() {
        barangList = result.data;

        currentPage = result.currentPage;
        lastPage = result.lastPage;

        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal mengambil data barang",
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOAD ROLE
  // ============================================================

  Future<void> loadRole() async {
    final result = await authService.getRole();

    if (!mounted) return;

    setState(() {
      role = result;
    });
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> loadMoreBarang() async {
    if (isLoadMore) return;

    if (currentPage >= lastPage) return;

    setState(() {
      isLoadMore = true;
    });

    try {
      final result = await barangService.getBarangPerPage(
        currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        barangList.addAll(result.data);

        currentPage = result.currentPage;
        lastPage = result.lastPage;

        isLoadMore = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoadMore = false;
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> cariBarang(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        await loadBarang();
        return;
      }

      final data = await barangService.searchBarang(
        keyword.trim(),
      );

      if (!mounted) return;

      setState(() {
        barangList = data;

        currentPage = 1;
        lastPage = 1;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal mencari barang",
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> hapusBarang(Barang barang) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Hapus Barang",
          ),
          content: Text(
            "Yakin ingin menghapus ${barang.namaBarang}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Batal",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Hapus",
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) return;

    final berhasil = await barangService.deleteBarang(
      barang.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? "Barang berhasil dihapus"
              : "Gagal menghapus barang",
        ),
      ),
    );

    if (berhasil) {
      loadBarang();
    }
  }

  // ============================================================
  // TAMBAH BARANG
  // ============================================================

  Future<void> barangMasuk() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarangMasukPage(),
      ),
    );

    if (mounted && result == true) {
      loadBarang();
    }
  }

  Future<void> barangKeluar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarangKeluarPage(),
      ),
    );

    if (mounted && result == true) {
      loadBarang();
    }
  }

  Future<void> tambahBarang() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TambahBarangPage(),
      ),
    );

    if (result == true) {
      loadBarang();
    }
  }

  // ============================================================
  // EDIT BARANG
  // ============================================================

  Future<void> editBarang(Barang barang) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBarangPage(
          barang: barang,
        ),
      ),
    );

    if (result == true) {
      loadBarang();
    }
  }

  // ============================================================
  // FORMAT HARGA
  // ============================================================

  String formatHarga(double harga) {
    return "Rp ${harga.toStringAsFixed(0)}";
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
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inventory",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Daftar barang inventory",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                if (role != "view_only")
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: barangMasuk,
                          icon: const Icon(Icons.south_west_rounded),
                          label: const Text('Barang Masuk'),
                        ),
                        ElevatedButton.icon(
                          onPressed: barangKeluar,
                          icon: const Icon(Icons.north_east_rounded),
                          label: const Text('Barang Keluar'),
                        ),
                        ElevatedButton.icon(
                          onPressed: tambahBarang,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Barang'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SEARCH
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Cari barang...",
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: cariBarang,
                  ),
                ),

                const SizedBox(width: 15),

                IconButton(
                  tooltip: "Refresh",
                  onPressed: loadBarang,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TABLE
            // ==================================================

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.05,
                      ),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : barangList.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "Belum ada barang",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification
                                  is ScrollEndNotification) {
                                if (notification.metrics.pixels >=
                                    notification.metrics.maxScrollExtent) {
                                  loadMoreBarang();
                                }
                              }

                              return false;
                            },
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor:
                                    WidgetStateProperty.all(
                                  const Color(
                                    0xfff1f3f6,
                                  ),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "No",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Nama Barang",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Stock",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Harga",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Lokasi",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Status",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Aksi",
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  barangList.length,
                                  (index) {
                                    final barang =
                                        barangList[index];

                                    final stock =
                                        barang.stock;

                                    return DataRow(
                                      cells: [
                                        // ==========================
                                        // NO
                                        // ==========================

                                        DataCell(
                                          Text(
                                            "${index + 1}",
                                          ),
                                        ),

                                        // ==========================
                                        // NAMA BARANG
                                        // ==========================

                                        DataCell(
                                          Text(
                                            barang.namaBarang,
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        // ==========================
                                        // STOCK
                                        // ==========================

                                        DataCell(
                                          Text(
                                            stock.toString(),
                                          ),
                                        ),

                                        // ==========================
                                        // HARGA
                                        // ==========================

                                        DataCell(
                                          Text(
                                            formatHarga(
                                              barang.harga,
                                            ),
                                          ),
                                        ),

                                        // ==========================
                                        // LOKASI
                                        // ==========================

                                        DataCell(
                                          Text(
                                            barang.lokasi == null ||
                                                    barang.lokasi!
                                                        .trim()
                                                        .isEmpty
                                                ? "-"
                                                : barang.lokasi!,
                                          ),
                                        ),

                                        // ==========================
                                        // STATUS
                                        // ==========================

                                        DataCell(
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: stock <= 5
                                                  ? Colors.red
                                                      .withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : Colors.green
                                                      .withValues(
                                                      alpha: 0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                20,
                                              ),
                                            ),
                                            child: Text(
                                              stock <= 5
                                                  ? "Stok Rendah"
                                                  : "Aman",
                                              style: TextStyle(
                                                color: stock <= 5
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // ==========================
                                        // AKSI
                                        // ==========================

                                        DataCell(
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              if (role == "admin" ||
                                                  role == "user")
                                                IconButton(
                                                  tooltip: "Edit",
                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .edit_outlined,
                                                  ),
                                                  onPressed: () =>
                                                      editBarang(
                                                    barang,
                                                  ),
                                                ),

                                              if (role == "admin")
                                                IconButton(
                                                  tooltip: "Hapus",
                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .delete_outline,
                                                    color:
                                                        Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      hapusBarang(
                                                    barang,
                                                  ),
                                                ),
                                            ],
                                          ),
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

            // ==================================================
            // LOADING MORE
            // ==================================================

            if (isLoadMore)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
