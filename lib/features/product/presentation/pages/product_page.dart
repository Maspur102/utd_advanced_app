import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../../../core/di/injection.dart';
import '../../../bookmark/data/isar_service.dart';
import '../../../bookmark/domain/bookmark_model.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.storefront, color: Colors.tealAccent, size: 24),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                text: 'UTD Store ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                children: [
                  TextSpan(text: 'Purnama', style: TextStyle(fontWeight: FontWeight.w300, color: Colors.tealAccent)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // IKON PROFIL BARU
          Container(
            margin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
              onPressed: () => context.push('/profile'), // MENUJU HALAMAN PROFIL
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.settings_cell, color: Colors.tealAccent, size: 20),
              onPressed: () => context.push('/native'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.deepPurpleAccent, size: 20),
              onPressed: () => context.push('/bookmark'),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          } else if (state is ProductError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent, fontSize: 16)));
          } else if (state is ProductLoaded) {
            final products = state.products;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 10), 
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    // NAVIGASI KLIK KE DETAIL PRODUK
                    onTap: () => context.push('/detail', extra: item), 
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.white, 
                        child: Image.network(
                          item.image, width: 50, height: 50, fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('ID: ${item.id}', style: const TextStyle(color: Colors.white54)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.pinkAccent),
                      onPressed: () {
                        final now = DateTime.now();
                        final timeString = "Disimpan pada ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                        final bookmark = Bookmark()..productId = item.id..productName = item.name..productImage = item.image..timestamp = timeString;
                        locator<IsarService>().saveBookmark(bookmark);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tersimpan! $timeString', style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.deepPurpleAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/crypto'),
        icon: const Icon(Icons.show_chart),
        label: const Text('Live Crypto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black87,
        elevation: 6,
      ),
    );
  }
}