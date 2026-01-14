import 'package:flutter/material.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../domain/usecases/payment_usecase.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _paymentRepository = PaymentRepository();
  late final PaymentUseCase _paymentUseCase;

  PaymentModel? _currentPayment;
  List<PaymentModel> _paymentHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  PaymentProvider() {
    _paymentUseCase = PaymentUseCase(_paymentRepository);
  }

  PaymentModel? get currentPayment => _currentPayment;
  List<PaymentModel> get paymentHistory => _paymentHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> processPayment({required String orderId}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _currentPayment = await _paymentUseCase.processPayment(
        orderId: orderId,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> checkPaymentStatus(String orderId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _currentPayment = await _paymentUseCase.checkPaymentStatus(orderId);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelPayment(String orderId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _paymentUseCase.cancelPayment(orderId);

      if (_currentPayment?.orderId == orderId) {
        _currentPayment = null;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _paymentHistory = await _paymentUseCase.getPaymentHistory();

      _setLoading(false);
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
    }
  }

  List<PaymentModel> filterPaymentsByStatus(PaymentStatus status) {
    return _paymentUseCase.filterPaymentsByStatus(_paymentHistory, status);
  }

  List<PaymentModel> get pendingPayments {
    return _paymentUseCase.getPendingPayments(_paymentHistory);
  }

  List<PaymentModel> get successfulPayments {
    return _paymentUseCase.getSuccessfulPayments(_paymentHistory);
  }

  int get totalPaidAmount {
    return _paymentUseCase.calculateTotalPaid(_paymentHistory);
  }

  bool isPaymentExpired(PaymentModel payment) {
    return _paymentUseCase.isPaymentExpired(payment);
  }

  Duration? getTimeRemaining(PaymentModel payment) {
    return _paymentUseCase.getTimeRemaining(payment);
  }

  String formatTimeRemaining(Duration duration) {
    return _paymentUseCase.formatTimeRemaining(duration);
  }

  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _extractErrorMessage(String error) {
    String message = error;

    while (message.contains('Exception: ')) {
      message = message.substring(message.indexOf('Exception: ') + 11);
    }

    message = message
        .replaceFirst(RegExp(r'^(Failed to|Payment|Network error): '), '')
        .trim();

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection')) {
      return 'Koneksi internet bermasalah';
    } else if (lowerMessage.contains('timeout')) {
      return 'Koneksi timeout, coba lagi';
    } else if (lowerMessage.contains('payment failed') ||
               lowerMessage.contains('transaction failed')) {
      return 'Pembayaran gagal, silakan coba lagi';
    } else if (lowerMessage.contains('expired')) {
      return 'Waktu pembayaran telah habis';
    } else if (lowerMessage.contains('cancelled')) {
      return 'Pembayaran dibatalkan';
    } else if (lowerMessage.contains('server error') ||
               lowerMessage.contains('500')) {
      return 'Server bermasalah, coba lagi nanti';
    } else if (message.isEmpty) {
      return 'Terjadi kesalahan, coba lagi';
    }

    return message;
  }
}