// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/auth_service.dart';
import 'package:flutter_inventory/core/services/barang_service.dart';

import 'package:flutter_inventory/models/barang.dart';

import 'package:flutter_inventory/pages/barang/tambah_barang_page.dart';
import 'package:flutter_inventory/pages/barang/edit_barang_page.dart';
import 'package:flutter_inventory/pages/barang/barang_masuk_page.dart';
import 'package:flutter_inventory/pages/barang/barang_keluar_page.dart';
import 'package:flutter_inventory/pages/histori/histori_page.dart';
import 'package:flutter_inventory/pages/repot/report_mobile.dart';
import 'package:flutter_inventory/pages/user/user_page.dart';
import 'package:flutter_inventory/pages/dashboard/dashboard_page.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  final BarangService barangService = BarangService();
  final AuthService authService = AuthService();

  String? role;
  String? name;

  List<Barang> barangList = [];

  bool isLoading = true;

  int currentPage = 1;
  int lastPage = 1;

  bool isLoadMore = false;

  final TextEditingController searchController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadBarang();
    loadUserAccess();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadMore &&
          currentPage < lastPage) {
        loadMoreBarang();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();

    super.dispose();
  }

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
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserAccess() async {
    final resultRole = await authService.getRole();
    final resultName = await authService.getName();

    if (!mounted) return;

    setState(() {
      role = resultRole;
      name = resultName;
    });
  }

  Future<void> loadMoreBarang() async {
    if (isLoadMore) return;

    setState(() {
      isLoadMore = true;
    });

    try {
      final result = await barangService.getBarangPerPage(currentPage + 1);

      if (!mounted) return;

      setState(() {
        barangList.addAll(result.data);

        currentPage = result.currentPage;

        lastPage = result.lastPage;

        isLoadMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadMore = false;
      });
    }
  }

  Future<void> cariBarang(String keyword) async {
    try {
      if (keyword.isEmpty) {
        await loadBarang();

        return;
      }

      final data = await barangService.searchBarang(keyword);

      if (!mounted) return;

      setState(() {
        barangList = data;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  void _openPage(Widget page) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(
          icon,
          size: 21,
          color: color ?? const Color(0xff6b7280),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff374151),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Barang"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            tooltip: "Logout",

            onPressed: () async {
              await authService.logout();

              if (!mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MEDIFRA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111827),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Inventory System",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff9ca3af),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              const SizedBox(height: 12),

              _drawerItem(
                icon: Icons.dashboard_outlined,
                title: "Dashboard",
                onTap: () {
                  _openPage(
                    const DashboardPage(),
                  );
                },
              ),

              _drawerItem(
                icon: Icons.inventory_2_outlined,
                title: "Inventory",
                color: const Color(0xff2563eb),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              if (role == "admin" || role == "user") ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    6,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "TRANSAKSI",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Color(0xff9ca3af),
                      ),
                    ),
                  ),
                ),

                _drawerItem(
                  icon: Icons.south_west_rounded,
                  title: "Barang Masuk",
                  color: const Color(0xff16a34a),
                  onTap: () {
                    _openPage(
                      const BarangMasukPage(),
                    );
                  },
                ),

                _drawerItem(
                  icon: Icons.north_east_rounded,
                  title: "Barang Keluar",
                  color: const Color(0xffdc2626),
                  onTap: () {
                    _openPage(
                      const BarangKeluarPage(),
                    );
                  },
                ),
              ],

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  6,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "AKTIVITAS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Color(0xff9ca3af),
                    ),
                  ),
                ),
              ),

              _drawerItem(
                icon: Icons.history_rounded,
                title: "Histori Stok",
                onTap: () {
                  _openPage(
                    const HistoriPage(),
                  );
                },
              ),

              _drawerItem(
                icon: Icons.description_outlined,
                title: "Report",
                onTap: () {
                  _openPage(
                    const ReportMobile(),
                  );
                },
              ),

              if (role == "admin")
                _drawerItem(
                  icon: Icons.people_alt_outlined,
                  title: "Management User",
                  onTap: () {
                    _openPage(
                      const UserPage(),
                    );
                  },
                ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8fafc),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xffe5e7eb),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xffdbeafe),
                        child: Text(
                          (name?.isNotEmpty == true ? name![0] : "U")
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xff2563eb),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? "User",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              (role ?? "-").toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xff9ca3af),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  14,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xffdc2626),
                    size: 21,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Color(0xffdc2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    await authService.logout();

                    if (!mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),

                  child: TextField(
                    controller: searchController,

                    decoration: const InputDecoration(
                      hintText: "Cari barang...",

                      prefixIcon: Icon(Icons.search),

                      border: OutlineInputBorder(),
                    ),

                    onChanged: cariBarang,
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadBarang,

                    child: ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),

                      itemCount: barangList.length + (isLoadMore ? 1 : 0),

                      itemBuilder: (context, index) {
                        if (index == barangList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20),

                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final barang = barangList[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),

                          child: ListTile(
                            title: Text(
                              barang.namaBarang,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text("Stock : ${barang.stock}"),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                if (role == "admin" || role == "user")
                                  IconButton(
                                    icon: const Icon(Icons.edit),

                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditBarangPage(barang: barang),
                                        ),
                                      );

                                      if (result == true) {
                                        loadBarang();
                                      }
                                    },
                                  ),

                                if (role == "admin")
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),

                                    onPressed: () async {
                                      final konfirmasi = await showDialog<bool>(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text("Hapus Barang"),

                                            content: Text(
                                              "Yakin ingin menghapus ${barang.namaBarang}?",
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },

                                                child: const Text("Batal"),
                                              ),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },

                                                child: const Text("Hapus"),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (konfirmasi == true) {
                                        final berhasil = await barangService
                                            .deleteBarang(barang.id);

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

      floatingActionButton: role == "view_only"
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahBarangPage()),
                );

                if (result == true) {
                  loadBarang();
                }
              },

              child: const Icon(Icons.add),
            ),
    );
  }
}
