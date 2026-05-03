class Product {
  final String id;
  final String name;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? 'Tanpa Nama',
      image: json['image'] ?? '',
    );
  }

  // Fungsi untuk menggandakan produk dengan nama yang baru (untuk Logika Anti-AI)
  Product copyWith({String? name}) {
    return Product(
      id: id,
      name: name ?? this.name,
      image: image,
    );
  }
}