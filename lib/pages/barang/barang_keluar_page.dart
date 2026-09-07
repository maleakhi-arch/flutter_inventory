import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/barang_service.dart';
import 'package:flutter_inventory/models/barang.dart';

class BarangKeluarPage extends StatefulWidget {
  const BarangKeluarPage({super.key});

  @override
  State<BarangKeluarPage> createState() => _BarangKeluarPageState();
}

class _BarangKeluarPageState extends State<BarangKeluarPage> {
  final BarangService barangService = BarangService();

  final jumlahController = TextEditingController();
  final hargaSatuanController = TextEditingController();
  final diambilOlehController = TextEditingController();
  final untukSiapaController = TextEditingController();
  final diketahuiOlehController = TextEditingController();
  final lokasiController = TextEditingController();
  final keteranganController = TextEditingController();

  List<Barang> barangList = [];

  Barang? selectedBarang;

  bool isLoadingBarang = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadBarang();
  }

  @override
  void dispose() {
    jumlahController.dispose();
    hargaSatuanController.dispose();
    diambilOlehController.dispose();
    untukSiapaController.dispose();
    diketahuiOlehController.dispose();
    lokasiController.dispose();
    keteranganController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD BARANG
  // ============================================================

  Future<void> loadBarang() async {
    try {
      final data = await barangService.getBarang();

      if (!mounted) return;

      setState(() {
        barangList = data;
        isLoadingBarang = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingBarang = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengambil data barang: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // SIMPAN BARANG KELUAR
  // ============================================================

  Future<void> simpanBarangKeluar() async {
    if (selectedBarang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan pilih barang",
          ),
        ),
      );
      return;
    }

    final jumlahText = jumlahController.text.trim();

    if (jumlahText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Jumlah barang wajib diisi",
          ),
        ),
      );
      return;
    }

    final jumlah = int.tryParse(jumlahText);

    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Jumlah barang tidak valid",
          ),
        ),
      );
      return;
    }

    // Jangan izinkan stock menjadi minus.
    if (jumlah > selectedBarang!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Stock tidak mencukupi. Stock saat ini: "
            "${selectedBarang!.stock}",
          ),
        ),
      );
      return;
    }

    final hargaText = hargaSatuanController.text.trim();

    double? hargaSatuan;

    if (hargaText.isNotEmpty) {
      hargaSatuan = double.tryParse(
        hargaText.replaceAll(',', '.'),
      );

      if (hargaSatuan == null || hargaSatuan < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Harga satuan tidak valid",
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      final berhasil = await barangService.barangKeluar(
        barangId: selectedBarang!.id,
        jumlah: jumlah,
        hargaSatuan: hargaSatuan,
        diambilOleh: _nullableText(
          diambilOlehController,
        ),
        untukSiapa: _nullableText(
          untukSiapaController,
        ),
        diketahuiOleh: _nullableText(
          diketahuiOlehController,
        ),
        lokasi: _nullableText(
          lokasiController,
        ),
        keterangan: _nullableText(
          keteranganController,
        ),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Barang keluar berhasil disimpan",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal menyimpan barang keluar",
            ),
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
          content: Text(
            "Terjadi kesalahan: $e",
          ),
        ),
      );
    }
  }

  String? _nullableText(
    TextEditingController controller,
  ) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Barang Keluar",
        ),
      ),
      body: isLoadingBarang
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Input Barang Keluar",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Catat barang yang keluar dari inventory.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // BARANG
                      // ==================================================

                      DropdownButtonFormField<Barang>(
                        initialValue: selectedBarang,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Barang",
                          border: OutlineInputBorder(),
                        ),
                        items: barangList.map(
                          (barang) {
                            return DropdownMenuItem<Barang>(
                              value: barang,
                              child: Text(
                                "${barang.namaBarang} "
                                "(Stock: ${barang.stock})",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  selectedBarang = value;
                                });
                              },
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // INFO STOCK
                      // ==================================================

                      if (selectedBarang != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange
                                .withValues(
                              alpha: 0.08,
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange
                                  .withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Stock saat ini: "
                                "${selectedBarang!.stock}",
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // JUMLAH
                      // ==================================================

                      buildTextField(
                        controller: jumlahController,
                        label: "Jumlah",
                        hint: "Contoh: 5",
                        keyboardType:
                            TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // HARGA SATUAN
                      // ==================================================

                      buildTextField(
                        controller: hargaSatuanController,
                        label: "Harga Satuan",
                        hint: "Contoh: 15000",
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // DIAMBIL OLEH
                      // ==================================================

                      buildTextField(
                        controller: diambilOlehController,
                        label: "Diambil Oleh",
                        hint: "Nama pihak yang mengambil",
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // UNTUK SIAPA
                      // ==================================================

                      buildTextField(
                        controller: untukSiapaController,
                        label: "Untuk Siapa",
                        hint: "Penerima / tujuan barang",
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // DIKETAHUI OLEH
                      // ==================================================

                      buildTextField(
                        controller: diketahuiOlehController,
                        label: "Diketahui Oleh",
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // LOKASI
                      // ==================================================

                      buildTextField(
                        controller: lokasiController,
                        label: "Lokasi",
                        hint: "Contoh: Gudang A",
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // KETERANGAN
                      // ==================================================

                      buildTextField(
                        controller: keteranganController,
                        label: "Keterangan",
                        hint: "Catatan tambahan",
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : simpanBarangKeluar,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "SIMPAN BARANG KELUAR",
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
}