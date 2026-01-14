class ProductModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final int promoPrice;
  final String imageUrl;
  final String category;
  final int stock;
  final String vendor;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.promoPrice,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.vendor,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      promoPrice: json['promoPrice'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      vendor: json['vendor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'promoPrice': promoPrice,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'vendor': vendor,
    };
  }

  bool get hasPromo => promoPrice > 0 && promoPrice < price;
  int get effectivePrice => hasPromo ? promoPrice : price;
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 10;

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    int? promoPrice,
    String? imageUrl,
    String? category,
    int? stock,
    String? vendor,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      promoPrice: promoPrice ?? this.promoPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      vendor: vendor ?? this.vendor,
    );
  }
}