// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/auth_service.dart';
import 'package:flutter_inventory/core/services/barang_service.dart';

import 'package:flutter_inventory/models/barang.dart';

import 'package:flutter_inventory/pages/barang/tambah_barang_page.dart';
import 'package:flutter_inventory/pages/barang/edit_barang_page.dart';
import 'package:flutter_inventory/pages/histori/histori_page.dart';
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
    loadRole();

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
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadRole() async {
    final result = await authService.getRole();

    if (!mounted) return;

    setState(() {
      role = result;
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
      print(e);

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
    } catch (e) {
      print(e);
    }
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
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,

                child: Icon(Icons.inventory, size: 35, color: Colors.blue),
              ),

              accountName: const Text("Sistem Informasi Gudang"),

              accountEmail: Text(
                "Hak Akses: ${(role ?? 'Memuat...').toUpperCase()}",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),

              title: const Text("Dashboard Analitik"),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),

              title: const Text("Histori Perubahan Stok"),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoriPage()),
                );
              },
            ),

            if (role == "admin") ...[
              const Divider(),

              ListTile(
                leading: const Icon(Icons.people, color: Colors.teal),

                title: const Text("Manajemen User"),

                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserPage()),
                  );
                },
              ),
            ],
          ],
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
