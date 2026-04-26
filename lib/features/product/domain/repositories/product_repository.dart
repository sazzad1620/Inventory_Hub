import '../entities/product_item.dart';

abstract class ProductRepository {
  Future<List<ProductItem>> listProducts();
  Future<void> addProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  });
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  });
  Future<void> deleteProduct(int id);
}
