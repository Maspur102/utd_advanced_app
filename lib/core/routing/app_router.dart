import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Tambahkan ini
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/product/presentation/cubit/product_cubit.dart'; // Tambahkan ini
import '../di/injection.dart'; // Tambahkan ini

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/product',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => locator<ProductCubit>()..fetchAllProducts(),
            child: const ProductPage(),
          );
        },
      ),
    ],
  );
}