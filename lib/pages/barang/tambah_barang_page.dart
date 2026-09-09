// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/barang_service.dart';

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final BarangService barangService = BarangService();

  final namaController = TextEditingController();
  final stockController = TextEditingController();
  final hargaController = TextEditingController();
  final lokasiController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    stockController.dispose();
    hargaController.dispose();
    lokasiController.dispose();
    super.dispose();
  }

  Future<void> simpanBarang() async {
    final nama = namaController.text.trim();
    final stockText = stockController.text.trim();
    final hargaText = hargaController.text.trim();
    final lokasi = lokasiController.text.trim();

    // ============================================================
    // VALIDASI NAMA
    // ============================================================

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama barang wajib diisi"),
        ),
      );
      return;
    }

    // ============================================================
    // VALIDASI STOCK
    // ============================================================

    if (stockText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stock wajib diisi"),
        ),
      );
      return;
    }

    final stock = int.tryParse(stockText);

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stock tidak valid"),
        ),
      );
      return;
    }

    // ============================================================
    // VALIDASI HARGA
    // ============================================================

    if (hargaText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harga wajib diisi"),
        ),
      );
      return;
    }

    final harga = double.tryParse(
      hargaText.replaceAll(',', '.'),
    );

    if (harga == null || harga < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harga tidak valid"),
        ),
      );
      return;
    }

    // ============================================================
    // SIMPAN
    // ============================================================

    setState(() {
      isLoading = true;
    });

    try {
      final berhasil = await barangService.tambahBarang(
        nama,
        stock,
        harga,
        lokasi.isEmpty ? null : lokasi,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Barang berhasil ditambahkan"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambahkan barang"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Barang",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffe5e7eb)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final fieldWidth = isWide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xffeff6ff),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_box_outlined,
                              color: Color(0xff2563eb),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tambah Barang Baru",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Masukkan informasi barang inventory.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff6b7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "Informasi Barang",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff374151),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: namaController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "Nama Barang",
                          hintText: "Contoh: Keyboard Logitech",
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 16,
                        runSpacing: 18,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: "Stock Awal",
                                hintText: "0",
                                prefixIcon: Icon(Icons.numbers_rounded),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: hargaController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: "Harga",
                                hintText: "0",
                                prefixText: "Rp ",
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: lokasiController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!isLoading) {
                            simpanBarang();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: "Lokasi",
                          hintText: "Contoh: Gudang A",
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text("Batal"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : simpanBarang,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, size: 18),
                            label: Text(
                              isLoading ? "Menyimpan..." : "Simpan Barang",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
