part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.error,
  });

  final ProductStatus status;
  final List<ProductItem> products;
  final List<String> categories;
  final String? error;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductItem>? products,
    List<String>? categories,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, products, categories, error];
}
