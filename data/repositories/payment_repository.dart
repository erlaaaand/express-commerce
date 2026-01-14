import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class PaymentRepository {
  final ApiService _apiService = ApiService();

  /// Process payment for an order
  Future<PaymentModel> processPayment({
    required String orderId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.payment,
        {'orderId': orderId},
        requiresAuth: true,
      );

      final data = response['data'] as Map<String, dynamic>;
      return PaymentModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  /// Check payment status
  Future<PaymentModel> checkPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.paymentStatus(orderId),
        requiresAuth: true,
      );

      final data = response['data'] as Map<String, dynamic>;
      return PaymentModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }

  /// Handle payment notification/callback
  Future<void> handlePaymentNotification(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      await _apiService.post(
        ApiConstants.paymentNotification,
        notificationData,
        requiresAuth: false,
      );
    } catch (e) {
      throw Exception('Failed to handle payment notification: $e');
    }
  }

  /// Cancel payment
  Future<void> cancelPayment(String orderId) async {
    try {
      await _apiService.post(
        '${ApiConstants.payment}/$orderId/cancel',
        {},
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to cancel payment: $e');
    }
  }

  /// Get payment history
  Future<List<PaymentModel>> getPaymentHistory() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.payment}/history',
        requiresAuth: true,
      );

      final data = response['data'] as List<dynamic>;
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }
}