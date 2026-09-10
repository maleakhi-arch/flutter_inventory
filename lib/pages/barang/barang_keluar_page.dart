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
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? 52 : 0),
                child: Icon(icon),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Barang Keluar",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: isLoadingBarang
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600 ? 16 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 600 ? 18 : 28,
                    ),
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
                        final isWide = constraints.maxWidth >= 650;
                        final fieldWidth = isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfffff1f2),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.north_east_rounded,
                                    color: Color(0xffdc2626),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Input Barang Keluar",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff111827),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Catat pengeluaran barang dan tujuan penggunaannya.",
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
                            // DROPDOWN BARANG
                            DropdownButtonFormField<Barang>(
                              initialValue: selectedBarang,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Pilih Barang",
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              items: barangList.map((barang) {
                                return DropdownMenuItem<Barang>(
                                  value: barang,
                                  child: Text(
                                    "${barang.namaBarang} • Stock ${barang.stock}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedBarang = value;
                                      });
                                    },
                            ),
                            if (selectedBarang != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xfffff7ed),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xfffed7aa)),
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
                                            color: const Color(0xffffedd5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xffea580c),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Stock Tersedia",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xff9a3412),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "${selectedBarang!.stock} unit",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xff7c2d12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 18,
                                          color: Color(0xffea580c),
                                        ),
                                        SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            "Jumlah keluar tidak boleh melebihi stok yang tersedia.",
                                            style: TextStyle(
                                              fontSize: 11,
                                              height: 1.4,
                                              color: Color(0xff9a3412),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 16,
                              runSpacing: 18,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: jumlahController,
                                    label: "Jumlah Keluar",
                                    hint: "Contoh: 5",
                                    keyboardType: TextInputType.number,
                                    icon: Icons.remove_circle_outline,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: hargaSatuanController,
                                    label: "Harga Satuan",
                                    hint: "Contoh: 15000",
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    icon: Icons.payments_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            const Divider(),
                            const SizedBox(height: 22),
                            const Text(
                              "Informasi Transaksi",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff374151),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 16,
                              runSpacing: 18,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: diambilOlehController,
                                    label: "Diambil Oleh",
                                    hint: "Nama pihak yang mengambil",
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: untukSiapaController,
                                    label: "Untuk Siapa",
                                    hint: "Penerima / tujuan barang",
                                    icon: Icons.person_pin_outlined,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: diketahuiOlehController,
                                    label: "Diketahui Oleh",
                                    hint: "Nama pihak yang mengetahui",
                                    icon: Icons.verified_user_outlined,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: lokasiController,
                                    label: "Lokasi",
                                    hint: "Contoh: Gudang A",
                                    icon: Icons.location_on_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            buildTextField(
                              controller: keteranganController,
                              label: "Keterangan",
                              hint: "Catatan tambahan transaksi barang keluar",
                              maxLines: 3,
                              icon: Icons.notes_outlined,
                            ),
                            const SizedBox(height: 30),
                            const Divider(),
                            const SizedBox(height: 18),
                            if (isWide)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    label: const Text("Batal"),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffdc2626), foregroundColor: Colors.white),
                                    onPressed: isLoading ? null : simpanBarangKeluar,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.north_east_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isLoading
                                          ? "Menyimpan..."
                                          : "Simpan Barang Keluar",
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffdc2626), foregroundColor: Colors.white),
                                    onPressed: isLoading ? null : simpanBarangKeluar,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.north_east_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isLoading
                                          ? "Menyimpan..."
                                          : "Simpan Barang Keluar",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    label: const Text("Batal"),
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
