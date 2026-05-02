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
    required String unit,
    String? categoryName,
  }) async {
    await _local.insertProduct(
      name: name,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stock: stock,
      unit: unit,
      categoryName: categoryName,
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
          (record) => ProductItem(
            id: record.product.id,
            name: record.product.name,
            buyingPrice: record.product.buyingPrice / _centsMultiplier,
            sellingPrice: record.product.sellingPrice / _centsMultiplier,
            stock: record.product.stock,
            unit: record.product.unit,
            categoryName: record.categoryName,
            createdAt: record.product.createdAt,
            updatedAt: record.product.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<String>> listCategories() {
    return _local.getCategories();
  }

  @override
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  }) {
    return _local.updateProduct(
      id: id,
      name: name,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stock: stock,
      unit: unit,
      categoryName: categoryName,
    );
  }
}
