class ProductModel {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String description;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '-',
      stock: json['stock'] ?? 0,
    );
  }
}