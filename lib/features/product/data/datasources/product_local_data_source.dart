import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Drift-specific product queries live here.
class ProductLocalDataSource {
  ProductLocalDataSource(this._db);

  final AppDatabase _db;
  static const int _centsMultiplier = 100;

  int _toCents(double price) => (price * _centsMultiplier).round();
  
  Future<int?> _readSessionUserId() async {
    final row = await (_db.select(_db.session)..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.userId;
  }

  Future<void> insertProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) {
      throw StateError('No active user session');
    }

    await _db.into(_db.products).insert(
      ProductsCompanion.insert(
        userId: Value(sessionUserId),
        name: name,
        buyingPrice: _toCents(buyingPrice),
        sellingPrice: _toCents(sellingPrice),
        stock: stock,
      ),
    );
  }

  Future<List<Product>> getProducts() async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) return const [];

    return (_db.select(_db.products)
          ..where((t) => t.userId.equals(sessionUserId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) {
      throw StateError('No active user session');
    }

    final updatedRows = await (_db.update(_db.products)
          ..where((t) => t.id.equals(id) & t.userId.equals(sessionUserId)))
        .write(
      ProductsCompanion(
        name: Value(name),
        buyingPrice: Value(_toCents(buyingPrice)),
        sellingPrice: Value(_toCents(sellingPrice)),
        stock: Value(stock),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (updatedRows == 0) {
      throw StateError('Product not found or not accessible');
    }
  }

  Future<void> deleteProduct(int id) async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) {
      throw StateError('No active user session');
    }

    final deletedRows = await (_db.delete(_db.products)
          ..where((t) => t.id.equals(id) & t.userId.equals(sessionUserId)))
        .go();
    if (deletedRows == 0) {
      throw StateError('Product not found or not accessible');
    }
  }
}
