import '../../../../core/errors/result.dart';
import '../entities/product_item.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repo);
  final ProductRepository _repo;

  Future<Result<List<ProductItem>>> call() async {
    try {
      return Success(await _repo.listProducts());
    } catch (e) {
      return FailureResult(
        'Failed to load products',
        code: 'products_load_failed',
      );
    }
  }
}

class AddProductUseCase {
  AddProductUseCase(this._repo);
  final ProductRepository _repo;

  Future<Result<void>> call({
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    try {
      await _repo.addProduct(
        name: name,
        buyingPrice: buyingPrice,
        sellingPrice: sellingPrice,
        stock: stock,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(
        'Failed to add product',
        code: 'product_add_failed',
      );
    }
  }
}

class UpdateProductUseCase {
  UpdateProductUseCase(this._repo);
  final ProductRepository _repo;

  Future<Result<void>> call({
    required int id,
    required String name,
    required double buyingPrice,
    required double sellingPrice,
    required int stock,
  }) async {
    try {
      await _repo.updateProduct(
        id: id,
        name: name,
        buyingPrice: buyingPrice,
        sellingPrice: sellingPrice,
        stock: stock,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(
        'Failed to update product',
        code: 'product_update_failed',
      );
    }
  }
}

class DeleteProductUseCase {
  DeleteProductUseCase(this._repo);
  final ProductRepository _repo;

  Future<Result<void>> call(int id) async {
    try {
      await _repo.deleteProduct(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(
        'Failed to delete product',
        code: 'product_delete_failed',
      );
    }
  }
}
