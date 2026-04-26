import 'datasources/product_local_data_source.dart';
import '../domain/entities/product_item.dart';
import '../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._local);

  final ProductLocalDataSource _local;
  static const double _centsMultiplier = 100;

  @override
  Future<void> addProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    await _local.insertProduct(
      name: name,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stock: stock,
    );
  }

  @override
  Future<void> deleteProduct(int id) {
    return _local.deleteProduct(id);
  }

  @override
  Future<List<ProductItem>> listProducts() async {
    final items = await _local.getProducts();
    return items
        .map(
          (p) => ProductItem(
            id: p.id,
            name: p.name,
            buyingPrice: p.buyingPrice / _centsMultiplier,
            sellingPrice: p.sellingPrice / _centsMultiplier,
            stock: p.stock,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) {
    return _local.updateProduct(
      id: id,
      name: name,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stock: stock,
    );
  }
}
