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
        title: const Text(
          "Edit Barang",
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
                              color: const Color(0xfffff7ed),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xffea580c),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Edit Informasi Barang",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Perbarui nama, harga, lokasi, atau keterangan barang.",
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
                          SizedBox(
                            width: fieldWidth,
                            child: TextField(
                              controller: lokasiController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: "Lokasi",
                                hintText: "Contoh: Gudang A",
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: alasanController,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: "Keterangan / Alasan Perubahan",
                          hintText: "Contoh: Perubahan harga dan lokasi barang",
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 52),
                            child: Icon(Icons.notes_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffe5e7eb)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xffeff6ff),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Color(0xff2563eb),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Stock Saat Ini",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xff6b7280),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${widget.barang.stock} unit",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Tooltip(
                              message: "Stock diubah melalui Barang Masuk atau Barang Keluar",
                              child: Icon(
                                Icons.info_outline,
                                color: Color(0xff9ca3af),
                                size: 19,
                              ),
                            ),
                          ],
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
                            onPressed: isLoading ? null : updateBarang,
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
                              isLoading ? "Menyimpan..." : "Simpan Perubahan",
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
