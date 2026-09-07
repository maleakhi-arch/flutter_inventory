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
        title: const Text("Tambah Barang"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ====================================================
            // NAMA BARANG
            // ====================================================

            TextField(
              controller: namaController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Nama Barang",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // STOCK
            // ====================================================

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Stock Awal",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // HARGA
            // ====================================================

            TextField(
              controller: hargaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Harga",
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // LOKASI
            // ====================================================

            TextField(
              controller: lokasiController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Lokasi",
                hintText: "Contoh: Gudang A",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // BUTTON SIMPAN
            // ====================================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : simpanBarang,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("SIMPAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}