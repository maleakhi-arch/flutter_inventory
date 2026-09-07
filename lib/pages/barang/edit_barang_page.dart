// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_inventory/core/services/barang_service.dart';
import 'package:flutter_inventory/models/barang.dart';

class EditBarangPage extends StatefulWidget {
  final Barang barang;

  const EditBarangPage({
    super.key,
    required this.barang,
  });

  @override
  State<EditBarangPage> createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  final BarangService barangService = BarangService();

  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController lokasiController;
  late TextEditingController alasanController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(
      text: widget.barang.namaBarang,
    );

    hargaController = TextEditingController(
      text: widget.barang.harga.toString(),
    );

    lokasiController = TextEditingController(
      text: widget.barang.lokasi ?? '',
    );

    alasanController = TextEditingController();
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    lokasiController.dispose();
    alasanController.dispose();

    super.dispose();
  }

  Future<void> updateBarang() async {
    final nama = namaController.text.trim();
    final hargaText = hargaController.text.trim();
    final lokasi = lokasiController.text.trim();
    final keterangan = alasanController.text.trim();

    // Validasi nama
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama barang wajib diisi"),
        ),
      );
      return;
    }

    // Validasi harga
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

    setState(() {
      isLoading = true;
    });

    try {
      final berhasil = await barangService.updateBarang(
        widget.barang.id,
        nama,
        harga,
        lokasi.isEmpty ? null : lokasi,
        keterangan.isEmpty ? null : keterangan,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Barang berhasil diperbarui"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengubah barang"),
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
        title: const Text("Edit Barang"),
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
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Lokasi",
                hintText: "Contoh: Gudang A",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // KETERANGAN / ALASAN
            // ====================================================

            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Keterangan / Alasan Perubahan",
                hintText: "Contoh: Perubahan harga dan lokasi barang",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // INFORMASI STOCK
            // ====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Stock saat ini: ${widget.barang.stock}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // BUTTON UPDATE
            // ====================================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateBarang,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("UPDATE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}