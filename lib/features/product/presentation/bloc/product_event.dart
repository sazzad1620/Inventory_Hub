part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoaded extends ProductEvent {}
class ProductStateReset extends ProductEvent {}

class ProductAdded extends ProductEvent {
  const ProductAdded({
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    required this.unit,
    this.categoryName,
  });

  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final String unit;
  final String? categoryName;

  @override
  List<Object?> get props => [name, buyingPrice, sellingPrice, stock, unit, categoryName];
}

class ProductUpdated extends ProductEvent {
  const ProductUpdated({
    required this.id,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    required this.unit,
    this.categoryName,
  });

  final int id;
  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final String unit;
  final String? categoryName;

  @override
  List<Object?> get props => [id, name, buyingPrice, sellingPrice, stock, unit, categoryName];
}

class ProductDeleted extends ProductEvent {
  const ProductDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
