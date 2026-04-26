part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.error,
  });

  final ProductStatus status;
  final List<ProductItem> products;
  final String? error;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductItem>? products,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, products, error];
}
