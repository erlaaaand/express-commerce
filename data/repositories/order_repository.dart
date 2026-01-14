import '../../core/constants/api_constants.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> checkout({
    required String shippingAddress,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.checkout,
        {'shippingAddress': shippingAddress},
        requiresAuth: true,
      );
      
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Checkout failed: $e');
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiService.get(
        ApiConstants.orders,
        requiresAuth: true,
      );
      
      final data = response['data'] as List<dynamic>;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.orderById(orderId),
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cancelOrder(orderId),
        {},
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.paymentStatus(orderId),
        requiresAuth: true,
      );
      
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }
}