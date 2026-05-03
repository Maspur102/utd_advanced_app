import '../data/product_repository.dart';
import 'product_model.dart';

class ProductService {
  final ProductRepository repository;

  ProductService(this.repository);

  Future<List<Product>> fetchProducts() async {
    final products = await repository.getAllProducts();

    // LOGIKA PERSONAL ANTI-AI (NIM Ganjil: 20123011)
    // Menambahkan teks [Diskon 10%] di belakang nama semua produk pada layer Service.
    return products.map((product) {
      return product.copyWith(name: '${product.name} [Diskon 10%]');
    }).toList();
  }
}