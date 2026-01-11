import '../../core/constants/api_constants.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CartRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Get cart
  Future<CartModel> getCart() async {
    try {
      final response = await _apiService.get(
        ApiConstants.cart,
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  // Add to cart
  Future<CartModel> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cart,
        {
          'productId': productId,
          'quantity': quantity,
        },
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // Update cart item quantity
  Future<CartModel> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.updateCart(productId),
        {'quantity': quantity},
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  // Remove from cart
  Future<CartModel> removeFromCart(String productId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.removeFromCart(productId),
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  // Clear cart
  Future<CartModel> clearCart() async {
    try {
      final response = await _apiService.delete(
        ApiConstants.cart,
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Add to local cart (offline)
  Future<void> addToLocalCart(String productId) async {
    try {
      await _storageService.addToLocalCart(productId);
    } catch (e) {
      throw Exception('Failed to add to local cart: $e');
    }
  }

  // Get local cart
  Future<List<String>> getLocalCart() async {
    try {
      return await _storageService.getLocalCart();
    } catch (e) {
      throw Exception('Failed to get local cart: $e');
    }
  }

  // Sync local cart to server
  Future<void> syncLocalCart() async {
    try {
      final localCart = await _storageService.getLocalCart();
      
      if (localCart.isEmpty) return;

      for (final productId in localCart) {
        await addToCart(productId: productId, quantity: 1);
      }

      await _storageService.clearLocalCart();
    } catch (e) {
      throw Exception('Failed to sync local cart: $e');
    }
  }
}