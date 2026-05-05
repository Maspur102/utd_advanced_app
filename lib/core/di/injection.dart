import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/splash/domain/splash_service.dart';
import '../../features/product/data/product_repository.dart';
import '../../features/product/domain/product_service.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/bookmark/data/isar_service.dart'; // Import baru

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  locator.registerLazySingleton<SplashService>(() => SplashService());
  
  // Daftarkan Database Isar
  locator.registerLazySingleton<IsarService>(() => IsarService());
  
  // Daftarkan Layer Produk
  locator.registerLazySingleton<ProductRepository>(() => ProductRepository());
  locator.registerFactory<ProductService>(() => ProductService(locator()));
  locator.registerFactory<ProductCubit>(() => ProductCubit(locator()));
}