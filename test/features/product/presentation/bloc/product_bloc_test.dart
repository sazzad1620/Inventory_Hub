import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/result.dart';
import 'package:inventory_management_app/features/product/domain/entities/product_item.dart';
import 'package:inventory_management_app/features/product/domain/repositories/product_repository.dart';
import 'package:inventory_management_app/features/product/domain/usecases/product_usecases.dart';
import 'package:inventory_management_app/features/product/presentation/bloc/product_bloc.dart';

class _FakeGetProductsUseCase extends GetProductsUseCase {
  _FakeGetProductsUseCase() : super(_NoopProductRepo());

  @override
  Future<Result<List<ProductItem>>> call() async {
    return Success([
      ProductItem(
        id: 1,
        name: 'Oil',
        buyingPrice: 140,
        sellingPrice: 160,
        stock: 3,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 3),
      ),
    ]);
  }
}

class _FailingGetProductsUseCase extends GetProductsUseCase {
  _FailingGetProductsUseCase() : super(_NoopProductRepo());

  @override
  Future<Result<List<ProductItem>>> call() async {
    return const FailureResult('Failed', code: 'products_load_failed');
  }
}

class _FakeAddUseCase extends AddProductUseCase {
  _FakeAddUseCase() : super(_NoopProductRepo());
  @override
  Future<Result<void>> call({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    return const Success(null);
  }
}

class _FakeUpdateUseCase extends UpdateProductUseCase {
  _FakeUpdateUseCase() : super(_NoopProductRepo());
  @override
  Future<Result<void>> call({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    return const Success(null);
  }
}

class _FakeDeleteUseCase extends DeleteProductUseCase {
  _FakeDeleteUseCase() : super(_NoopProductRepo());
  @override
  Future<Result<void>> call(int id) async {
    return const Success(null);
  }
}

class _NoopProductRepo implements ProductRepository {
  @override
  Future<void> addProduct({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {}

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<List<ProductItem>> listProducts() async => [];

  @override
  Future<void> updateProduct({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {}
}

void main() {
  blocTest<ProductBloc, ProductState>(
    'emits loading then loaded when products are requested',
    build: () => ProductBloc(
      getProducts: _FakeGetProductsUseCase(),
      addProduct: _FakeAddUseCase(),
      updateProduct: _FakeUpdateUseCase(),
      deleteProduct: _FakeDeleteUseCase(),
    ),
    act: (bloc) => bloc.add(ProductsLoaded()),
    expect: () => [
      const ProductState(status: ProductStatus.loading),
      isA<ProductState>()
          .having((s) => s.status, 'status', ProductStatus.loaded)
          .having((s) => s.products.length, 'products length', 1),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'emits loading then failure when product loading fails',
    build: () => ProductBloc(
      getProducts: _FailingGetProductsUseCase(),
      addProduct: _FakeAddUseCase(),
      updateProduct: _FakeUpdateUseCase(),
      deleteProduct: _FakeDeleteUseCase(),
    ),
    act: (bloc) => bloc.add(ProductsLoaded()),
    expect: () => [
      const ProductState(status: ProductStatus.loading),
      const ProductState(status: ProductStatus.failure, error: 'products_load_failed'),
    ],
  );
}
