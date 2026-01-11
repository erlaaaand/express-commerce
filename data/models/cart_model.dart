class CartItemModel {
  final String productId;
  final String productName;
  final int price;
  final int quantity;
  final String imageUrl;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  int get subtotal => price * quantity;

  CartItemModel copyWith({
    String? productId,
    String? productName,
    int? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    
    return CartModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      items: itemsList.map((item) => CartItemModel.fromJson(item)).toList(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get itemCount => items.length;
  
  int get totalAmount {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
  
  bool get isEmpty => items.isEmpty;

  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}