import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/product_item.dart';
import '../../domain/usecases/product_usecases.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required GetProductsUseCase getProducts,
    required AddProductUseCase addProduct,
    required UpdateProductUseCase updateProduct,
    required DeleteProductUseCase deleteProduct,
  })  : _getProducts = getProducts,
        _addProduct = addProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        super(const ProductState()) {
    on<ProductsLoaded>(_onProductsLoaded);
    on<ProductAdded>(_onProductAdded);
    on<ProductUpdated>(_onProductUpdated);
    on<ProductDeleted>(_onProductDeleted);
  }

  final GetProductsUseCase _getProducts;
  final AddProductUseCase _addProduct;
  final UpdateProductUseCase _updateProduct;
  final DeleteProductUseCase _deleteProduct;

  Future<void> _reloadProducts(
    Emitter<ProductState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: ProductStatus.loading, clearError: true));
    }

    final result = await _getProducts();
    if (result is FailureResult<List<ProductItem>>) {
      emit(state.copyWith(status: ProductStatus.failure, error: result.code ?? 'products_load_failed'));
      return;
    }

    emit(
      state.copyWith(
        status: ProductStatus.loaded,
        products: (result as Success<List<ProductItem>>).data,
        clearError: true,
      ),
    );
  }

  Future<void> _onProductsLoaded(ProductsLoaded event, Emitter<ProductState> emit) async {
    await _reloadProducts(emit, showLoading: true);
  }

  Future<void> _onProductAdded(ProductAdded event, Emitter<ProductState> emit) async {
    final result = await _addProduct(
      name: event.name,
      buyingPrice: event.buyingPrice,
      sellingPrice: event.sellingPrice,
      stock: event.stock,
    );
    if (result is FailureResult<void>) {
      emit(state.copyWith(status: ProductStatus.failure, error: result.code ?? 'product_add_failed'));
      return;
    }
    await _reloadProducts(emit, showLoading: false);
  }

  Future<void> _onProductUpdated(ProductUpdated event, Emitter<ProductState> emit) async {
    final result = await _updateProduct(
      id: event.id,
      name: event.name,
      buyingPrice: event.buyingPrice,
      sellingPrice: event.sellingPrice,
      stock: event.stock,
    );
    if (result is FailureResult<void>) {
      emit(state.copyWith(status: ProductStatus.failure, error: result.code ?? 'product_update_failed'));
      return;
    }
    await _reloadProducts(emit, showLoading: false);
  }

  Future<void> _onProductDeleted(ProductDeleted event, Emitter<ProductState> emit) async {
    final result = await _deleteProduct(event.id);
    if (result is FailureResult<void>) {
      emit(state.copyWith(status: ProductStatus.failure, error: result.code ?? 'product_delete_failed'));
      return;
    }
    await _reloadProducts(emit, showLoading: false);
  }
}
