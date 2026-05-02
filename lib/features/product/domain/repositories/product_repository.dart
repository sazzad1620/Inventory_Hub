import '../entities/product_item.dart';

abstract class ProductRepository {
  Future<List<ProductItem>> listProducts();
  Future<List<String>> listCategories();
  Future<void> addProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  });
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  });
  Future<void> deleteProduct(int id);
}
