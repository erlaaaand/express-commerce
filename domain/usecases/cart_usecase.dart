import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartUseCase {
  final CartRepository _cartRepository;

  CartUseCase(this._cartRepository);

  /// Get user's cart
  Future<CartModel> getCart() async {
    return await _cartRepository.getCart();
  }

  /// Add product to cart
  Future<CartModel> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    // Business logic validation
    if (productId.isEmpty) {
      throw Exception('Product ID tidak valid');
    }

    if (quantity <= 0) {
      throw Exception('Jumlah produk harus lebih dari 0');
    }

    if (quantity > 99) {
      throw Exception('Jumlah produk maksimal 99');
    }

    return await _cartRepository.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }

  /// Update cart item quantity
  Future<CartModel> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    // Business logic validation
    if (productId.isEmpty) {
      throw Exception('Product ID tidak valid');
    }

    if (quantity <= 0) {
      throw Exception('Jumlah produk harus lebih dari 0');
    }

    if (quantity > 99) {
      throw Exception('Jumlah produk maksimal 99');
    }

    return await _cartRepository.updateQuantity(
      productId: productId,
      quantity: quantity,
    );
  }

  /// Remove product from cart
  Future<CartModel> removeFromCart(String productId) async {
    if (productId.isEmpty) {
      throw Exception('Product ID tidak valid');
    }

    return await _cartRepository.removeFromCart(productId);
  }

  /// Clear all items in cart
  Future<CartModel> clearCart() async {
    return await _cartRepository.clearCart();
  }

  /// Add to local cart (offline mode)
  Future<void> addToLocalCart(String productId) async {
    if (productId.isEmpty) {
      throw Exception('Product ID tidak valid');
    }

    await _cartRepository.addToLocalCart(productId);
  }

  /// Get local cart items
  Future<List<String>> getLocalCart() async {
    return await _cartRepository.getLocalCart();
  }

  /// Sync local cart to server
  Future<void> syncLocalCart() async {
    await _cartRepository.syncLocalCart();
  }

  /// Calculate total price
  int calculateTotalPrice(List<CartItemModel> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total items
  int calculateTotalItems(List<CartItemModel> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart is empty
  bool isCartEmpty(CartModel cart) {
    return cart.items.isEmpty;
  }

  /// Check if cart has specific product
  bool hasProduct(CartModel cart, String productId) {
    return cart.items.any((item) => item.productId == productId);
  }

  /// Get cart item by product ID
  CartItemModel? getCartItem(CartModel cart, String productId) {
    try {
      return cart.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Validate cart before checkout
  bool validateCartForCheckout(CartModel cart) {
    if (cart.items.isEmpty) {
      throw Exception('Keranjang masih kosong');
    }

    // Check minimum order
    if (cart.totalAmount < 10000) {
      throw Exception('Minimum pembelian Rp 10.000');
    }

    return true;
  }

  /// Calculate discount amount
  int calculateDiscount(CartModel cart, {double discountPercentage = 0}) {
    if (discountPercentage <= 0) return 0;
    if (discountPercentage > 100) discountPercentage = 100;

    return (cart.totalAmount * discountPercentage / 100).round();
  }

  /// Calculate final amount after discount
  int calculateFinalAmount(CartModel cart, {double discountPercentage = 0}) {
    final discount = calculateDiscount(cart, discountPercentage: discountPercentage);
    return cart.totalAmount - discount;
  }

  /// Check if eligible for free shipping
  bool isEligibleForFreeShipping(CartModel cart, {int minAmount = 100000}) {
    return cart.totalAmount >= minAmount;
  }
}