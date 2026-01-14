import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderUseCase {
  final OrderRepository _orderRepository;

  OrderUseCase(this._orderRepository);

  Future<Map<String, dynamic>> checkout({
    required String shippingAddress,
  }) async {
    if (shippingAddress.isEmpty) {
      throw Exception('Alamat pengiriman tidak boleh kosong');
    }

    if (shippingAddress.length < 10) {
      throw Exception('Alamat pengiriman terlalu pendek (minimal 10 karakter)');
    }

    return await _orderRepository.checkout(
      shippingAddress: shippingAddress,
    );
  }

  Future<List<OrderModel>> getOrders() async {
    final orders = await _orderRepository.getOrders();
    
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return orders;
  }

  Future<OrderModel> getOrderById(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    return await _orderRepository.getOrderById(orderId);
  }

  Future<OrderModel> cancelOrder(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    final order = await _orderRepository.getOrderById(orderId);
    
    if (!order.canBeCancelled) {
      throw Exception('Pesanan tidak dapat dibatalkan');
    }

    return await _orderRepository.cancelOrder(orderId);
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    return await _orderRepository.checkPaymentStatus(orderId);
  }

  List<OrderModel> filterOrdersByStatus(
    List<OrderModel> orders,
    OrderStatus status,
  ) {
    switch (status) {
      case OrderStatus.pending:
        return orders.where((o) => o.isPending).toList();
      case OrderStatus.paid:
        return orders.where((o) => o.isPaid).toList();
      case OrderStatus.shipped:
        return orders.where((o) => o.isShipped).toList();
      case OrderStatus.completed:
        return orders.where((o) => o.isCompleted).toList();
      case OrderStatus.cancelled:
        return orders.where((o) => o.isCancelled).toList();
      case OrderStatus.all:
        return orders;
    }
  }

  List<OrderModel> getActiveOrders(List<OrderModel> orders) {
    return orders.where((order) => 
      !order.isCompleted && !order.isCancelled
    ).toList();
  }

  List<OrderModel> getCompletedOrders(List<OrderModel> orders) {
    return orders.where((order) => order.isCompleted).toList();
  }

  int calculateTotalSpent(List<OrderModel> orders) {
    return orders
        .where((order) => order.isPaid || order.isCompleted)
        .fold(0, (sum, order) => sum + order.totalAmount);
  }

  int calculateTotalItemsOrdered(List<OrderModel> orders) {
    int total = 0;
    for (final order in orders) {
      for (final item in order.items) {
        total += item.quantity;
      }
    }
    return total;
  }

  OrderSummary getOrderSummary(List<OrderModel> orders) {
    return OrderSummary(
      totalOrders: orders.length,
      pendingOrders: orders.where((o) => o.isPending).length,
      paidOrders: orders.where((o) => o.isPaid).length,
      shippedOrders: orders.where((o) => o.isShipped).length,
      completedOrders: orders.where((o) => o.isCompleted).length,
      cancelledOrders: orders.where((o) => o.isCancelled).length,
      totalSpent: calculateTotalSpent(orders),
      totalItems: calculateTotalItemsOrdered(orders),
    );
  }

  bool validateShippingAddress(String address) {
    if (address.isEmpty) return false;
    if (address.length < 10) return false;
    if (address.length > 500) return false;
    
    return true;
  }

  bool needsAttention(OrderModel order) {
    if (order.isPending) {
      final hoursSinceCreated = 
        DateTime.now().difference(order.createdAt).inHours;
      return hoursSinceCreated > 24;
    }
    return false;
  }

  DateTime? getEstimatedDelivery(OrderModel order) {
    if (order.isShipped) {
      return order.createdAt.add(const Duration(days: 7));
    }
    return null;
  }
}

enum OrderStatus {
  all,
  pending,
  paid,
  shipped,
  completed,
  cancelled,
}

class OrderSummary {
  final int totalOrders;
  final int pendingOrders;
  final int paidOrders;
  final int shippedOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int totalSpent;
  final int totalItems;

  OrderSummary({
    required this.totalOrders,
    required this.pendingOrders,
    required this.paidOrders,
    required this.shippedOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
    required this.totalItems,
  });
}