class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
}
