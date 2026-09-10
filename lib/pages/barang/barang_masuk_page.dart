import 'package:flutter/material.dart';

import 'package:flutter_inventory/core/services/barang_service.dart';
import 'package:flutter_inventory/models/barang.dart';

class BarangMasukPage extends StatefulWidget {
  const BarangMasukPage({super.key});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  final BarangService barangService = BarangService();

  final jumlahController = TextEditingController();
  final hargaSatuanController = TextEditingController();
  final orderOlehController = TextEditingController();
  final dikirimOlehController = TextEditingController();
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
    orderOlehController.dispose();
    dikirimOlehController.dispose();
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
  // SIMPAN BARANG MASUK
  // ============================================================

  Future<void> simpanBarangMasuk() async {
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
      final berhasil = await barangService.barangMasuk(
        barangId: selectedBarang!.id,
        jumlah: jumlah,
        hargaSatuan: hargaSatuan,
        orderOleh: _nullableText(
          orderOlehController,
        ),
        dikirimOleh: _nullableText(
          dikirimOlehController,
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
              "Barang masuk berhasil disimpan",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal menyimpan barang masuk",
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
          "Barang Masuk",
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
                                    color: const Color(0xffecfdf3),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.south_west_rounded,
                                    color: Color(0xff16a34a),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Input Barang Masuk",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff111827),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Catat penerimaan barang dan informasi pendukung transaksi.",
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff8fafc),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xffe5e7eb),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: Color(0xff2563eb),
                                    ),
                                    const SizedBox(width: 9),
                                    Text(
                                      "Stock saat ini: ${selectedBarang!.stock} unit",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff374151),
                                      ),
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
                                    label: "Jumlah Masuk",
                                    hint: "Contoh: 10",
                                    keyboardType: TextInputType.number,
                                    icon: Icons.add_box_outlined,
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
                                    controller: orderOlehController,
                                    label: "Order Oleh",
                                    hint: "Nama pemesan",
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: dikirimOlehController,
                                    label: "Dikirim Oleh",
                                    hint: "Nama pengirim",
                                    icon: Icons.local_shipping_outlined,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: buildTextField(
                                    controller: untukSiapaController,
                                    label: "Untuk Siapa",
                                    hint: "Penerima / tujuan",
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
                              hint: "Catatan tambahan transaksi barang masuk",
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
                                    onPressed: isLoading ? null : simpanBarangMasuk,
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
                                            Icons.south_west_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isLoading
                                          ? "Menyimpan..."
                                          : "Simpan Barang Masuk",
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: isLoading ? null : simpanBarangMasuk,
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
                                            Icons.south_west_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isLoading
                                          ? "Menyimpan..."
                                          : "Simpan Barang Masuk",
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
