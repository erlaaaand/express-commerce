import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentUseCase {
  final PaymentRepository _paymentRepository;

  PaymentUseCase(this._paymentRepository);

  Future<PaymentModel> processPayment({
    required String orderId,
  }) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    return await _paymentRepository.processPayment(orderId: orderId);
  }

  Future<PaymentModel> checkPaymentStatus(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    return await _paymentRepository.checkPaymentStatus(orderId);
  }

  Future<void> cancelPayment(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID tidak valid');
    }

    await _paymentRepository.cancelPayment(orderId);
  }

  Future<List<PaymentModel>> getPaymentHistory() async {
    final payments = await _paymentRepository.getPaymentHistory();

    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return payments;
  }

  List<PaymentModel> filterPaymentsByStatus(
    List<PaymentModel> payments,
    PaymentStatus status,
  ) {
    switch (status) {
      case PaymentStatus.pending:
        return payments.where((p) => p.isPending).toList();
      case PaymentStatus.success:
        return payments.where((p) => p.isSuccess).toList();
      case PaymentStatus.failed:
        return payments.where((p) => p.isFailed).toList();
      case PaymentStatus.all:
        return payments;
    }
  }

  List<PaymentModel> getPendingPayments(List<PaymentModel> payments) {
    return payments.where((payment) => payment.isPending).toList();
  }

  List<PaymentModel> getSuccessfulPayments(List<PaymentModel> payments) {
    return payments.where((payment) => payment.isSuccess).toList();
  }

  int calculateTotalPaid(List<PaymentModel> payments) {
    return payments
        .where((payment) => payment.isSuccess)
        .fold(0, (sum, payment) => sum + payment.amount);
  }

  bool isPaymentExpired(PaymentModel payment) {
    if (!payment.isPending) return false;

    final expiryTime = payment.createdAt.add(const Duration(hours: 24));
    return DateTime.now().isAfter(expiryTime);
  }

  Duration? getTimeRemaining(PaymentModel payment) {
    if (!payment.isPending) return null;

    final expiryTime = payment.createdAt.add(const Duration(hours: 24));
    final remaining = expiryTime.difference(DateTime.now());

    if (remaining.isNegative) return null;
    return remaining;
  }

  String formatTimeRemaining(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} menit';
    } else {
      return 'Kurang dari 1 menit';
    }
  }

  bool isValidPaymentUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

enum PaymentStatus {
  all,
  pending,
  success,
  failed,
}