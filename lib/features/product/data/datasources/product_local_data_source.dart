import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class ProductRecord {
  const ProductRecord({
    required this.product,
    this.categoryName,
  });

  final Product product;
  final String? categoryName;
}

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

  Future<int?> _resolveCategoryId({
    required int userId,
    String? categoryName,
  }) async {
    final normalized = categoryName?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final existing = await (_db.select(_db.categories)
          ..where((c) =>
              c.userId.equals(userId) &
              c.name.lower().equals(normalized.toLowerCase())))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            userId: Value(userId),
            name: normalized,
          ),
        );
  }

  Future<void> insertProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  }) async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) {
      throw StateError('No active user session');
    }
    final categoryId = await _resolveCategoryId(
      userId: sessionUserId,
      categoryName: categoryName,
    );

    await _db.into(_db.products).insert(
      ProductsCompanion.insert(
        userId: Value(sessionUserId),
        categoryId: Value(categoryId),
        name: name,
        buyingPrice: _toCents(buyingPrice),
        sellingPrice: _toCents(sellingPrice),
        stock: stock,
        unit: Value(unit.trim().isEmpty ? 'Unit' : unit.trim()),
      ),
    );
  }

  Future<List<ProductRecord>> getProducts() async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) return const [];

    final query = _db.select(_db.products).join([
      leftOuterJoin(_db.categories, _db.categories.id.equalsExp(_db.products.categoryId)),
    ])
      ..where(_db.products.userId.equals(sessionUserId))
      ..orderBy([OrderingTerm.desc(_db.products.updatedAt)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => ProductRecord(
            product: row.readTable(_db.products),
            categoryName: row.readTableOrNull(_db.categories)?.name,
          ),
        )
        .toList();
  }

  Future<List<String>> getCategories() async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) return const [];

    final rows = await (_db.select(_db.categories)
          ..where((t) => t.userId.equals(sessionUserId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map((c) => c.name).toList();
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  }) async {
    final sessionUserId = await _readSessionUserId();
    if (sessionUserId == null) {
      throw StateError('No active user session');
    }
    final categoryId = await _resolveCategoryId(
      userId: sessionUserId,
      categoryName: categoryName,
    );

    final updatedRows = await (_db.update(_db.products)
          ..where((t) => t.id.equals(id) & t.userId.equals(sessionUserId)))
        .write(
      ProductsCompanion(
        name: Value(name),
        buyingPrice: Value(_toCents(buyingPrice)),
        sellingPrice: Value(_toCents(sellingPrice)),
        stock: Value(stock),
        categoryId: Value(categoryId),
        unit: Value(unit.trim().isEmpty ? 'Unit' : unit.trim()),
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
