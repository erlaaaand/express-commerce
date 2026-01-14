import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/order_repository.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();
  final OrderRepository _orderRepository = OrderRepository();

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart?.itemCount ?? 0;
  int get totalAmount => _cart?.totalAmount ?? 0;
  bool get isEmpty => _cart?.isEmpty ?? true;

  Future<void> fetchCart() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _cart = await _cartRepository.getCart();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _cart = await _cartRepository.addToCart(
        productId: productId,
        quantity: quantity,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _cart = await _cartRepository.updateQuantity(
        productId: productId,
        quantity: quantity,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _cart = await _cartRepository.removeFromCart(productId);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _cart = await _cartRepository.clearCart();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkoutCart({
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _orderRepository.checkout(
        shippingAddress: shippingAddress,
      );

      _cart = CartModel(
        id: _cart?.id ?? '',
        userId: _cart?.userId ?? '',
        items: [],
        updatedAt: DateTime.now(),
      );

      _setLoading(false);

      return {
        'orderId': response['orderId'],
        'paymentUrl': response['paymentUrl'],
        'paymentToken': response['paymentToken'],
        'totalAmount': response['totalAmount'],
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<void> addToLocalCart(String productId) async {
    try {
      await _cartRepository.addToLocalCart(productId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> syncLocalCart() async {
    try {
      _setLoading(true);
      await _cartRepository.syncLocalCart();
      await fetchCart();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}