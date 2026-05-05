import 'package:isar/isar.dart';

part 'bookmark_model.g.dart';

@collection
class Bookmark {
  Id id = Isar.autoIncrement; // ID otomatis dari Isar
  
  late String productId;
  late String productName;
  late String productImage;
  
  // Logika Anti-AI: Menyimpan string waktu saat ditekan
  late String timestamp; 
}