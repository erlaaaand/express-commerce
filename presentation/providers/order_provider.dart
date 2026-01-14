import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _orders = await _orderRepository.getOrders();
      
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}