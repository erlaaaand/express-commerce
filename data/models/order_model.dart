class OrderItemModel {
  final String productId;
  final String productName;
  final int priceAtPurchase;
  final int quantity;
  final String imageUrl;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.priceAtPurchase,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      priceAtPurchase: json['priceAtPurchase'] ?? 0,
      quantity: json['quantity'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  int get subtotal => priceAtPurchase * quantity;
}

class OrderModel {
  final String id;
  final String orderId;
  final String userId;
  final List<OrderItemModel> items;
  final int totalAmount;
  final String status;
  final String shippingAddress;
  final String? paymentToken;
  final String? paymentUrl;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    this.paymentToken,
    this.paymentUrl,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      items: itemsList.map((item) => OrderItemModel.fromJson(item)).toList(),
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? 'Pending',
      shippingAddress: json['shippingAddress'] ?? '',
      paymentToken: json['paymentToken'],
      paymentUrl: json['paymentUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isPending => status == 'Pending';
  bool get isPaid => status == 'Paid';
  bool get isShipped => status == 'Shipped';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';
  
  bool get canBeCancelled => isPending;
}