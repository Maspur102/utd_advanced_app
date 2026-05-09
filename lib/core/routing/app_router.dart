import 'package:go_router/go_router.dart'; // Baris ini sudah diperbaiki
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/product/presentation/pages/detail_page.dart'; 
import '../../features/product/domain/product_model.dart'; 
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/bookmark/presentation/pages/bookmark_page.dart';
import '../../features/crypto/presentation/pages/crypto_page.dart';
import '../../features/native/presentation/pages/native_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/sync/presentation/pages/background_sync_page.dart';
import '../di/injection.dart'; 

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/product',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => locator<ProductCubit>()..fetchAllProducts(),
            child: const ProductPage(),
          );
        },
      ),
      GoRoute(path: '/bookmark', builder: (context, state) => const BookmarkPage()),
      GoRoute(path: '/crypto', builder: (context, state) => const CryptoPage()),
      GoRoute(path: '/native', builder: (context, state) => const NativePage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()), 
      GoRoute(path: '/sync', builder: (context, state) => const BackgroundSyncPage()),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return DetailPage(product: product);
        },
      ),
    ],
  );
}