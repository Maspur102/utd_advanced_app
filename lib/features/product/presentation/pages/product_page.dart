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
        toolbarHeight: 75,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: const Icon(Icons.storefront, color: Colors.tealAccent, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UTD Store',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white, 
                    letterSpacing: 0.5
                  ),
                ),
                Text(
                  'Purnama', 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w400, 
                    color: Colors.tealAccent
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
              onPressed: () => context.push('/profile'),
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
            
            // MENGGUNAKAN GRIDVIEW AGAR TAMPILAN JADI KOTAK BERJEJER
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Menampilkan 2 kotak per baris
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Mengatur rasio tinggi kotak
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return GestureDetector(
                  onTap: () => context.push('/detail', extra: item),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BAGIAN GAMBAR
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Image.network(
                                  item.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                              // TOMBOL FAVORITE DI DALAM KOTAK
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black.withOpacity(0.05),
                                  radius: 18,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.favorite_border, color: Colors.pinkAccent, size: 20),
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
                              ),
                            ],
                          ),
                        ),
                        // BAGIAN TEKS INFORMASI
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${item.id}',
                                style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
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