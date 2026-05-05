import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/bookmark_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [BookmarkSchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveBookmark(Bookmark newBookmark) async {
    final isar = await db;
    // Cek apakah produk sudah dibookmark agar tidak duplikat
    final existing = await isar.bookmarks.filter().productIdEqualTo(newBookmark.productId).findFirst();
    
    if (existing == null) {
      isar.writeTxnSync(() => isar.bookmarks.putSync(newBookmark));
    }
  }

  Future<void> removeBookmark(Id id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.bookmarks.deleteSync(id));
  }

  // Reactive Stream: UI akan otomatis update tanpa setState!
  Stream<List<Bookmark>> listenToBookmarks() async* {
    final isar = await db;
    yield* isar.bookmarks.where().watch(fireImmediately: true);
  }
}