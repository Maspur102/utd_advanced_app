import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_state.dart';
import '../../domain/product_service.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _service;

  ProductCubit(this._service) : super(ProductLoading());

  Future<void> fetchAllProducts() async {
    emit(ProductLoading());
    try {
      final data = await _service.fetchProducts();
      emit(ProductLoaded(data)); // Memancarkan data yang sudah didiskon
    } catch (e) {
      emit(ProductError('Gagal memuat produk: $e'));
    }
  }
}