class Barang {
  final int id;
  final String namaBarang;
  final int stock;
  final double harga;
  final String? lokasi;
  final String? createdAt;
  final String? updatedAt;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.stock,
    required this.harga,
    this.lokasi,
    this.createdAt,
    this.updatedAt,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      stock: int.parse(json['stock'].toString()),
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      lokasi: json['lokasi'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'stock': stock,
      'harga': harga,
      'lokasi': lokasi,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}