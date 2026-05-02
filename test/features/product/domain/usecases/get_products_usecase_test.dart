import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/result.dart';
import 'package:inventory_management_app/features/product/domain/entities/product_item.dart';
import 'package:inventory_management_app/features/product/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/features/product/domain/usecases/product_usecases.dart';

class _FakeProductRepository implements ProductRepository {
  @override
  Future<void> addProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  }) async {}

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<List<ProductItem>> listProducts() async {
    return [
      ProductItem(
        id: 1,
        name: 'Rice',
        buyingPrice: 100,
        sellingPrice: 120,
        stock: 5,
        unit: 'KG',
        categoryName: 'Grocery',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      ),
    ];
  }

  @override
  Future<List<String>> listCategories() async => ['Grocery'];

  @override
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
    required String unit,
    String? categoryName,
  }) async {}
}

void main() {
  test('GetProductsUseCase returns product list on success', () async {
    final useCase = GetProductsUseCase(_FakeProductRepository());
    final result = await useCase();

    expect(result, isA<Success<List<ProductItem>>>());
    expect((result as Success<List<ProductItem>>).data.length, 1);
  });
}
