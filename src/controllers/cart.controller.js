const CartService = require('../services/cart.service');
const ResponseUtil = require('../utils/response.util');

class CartController {
  async getCart(req, res, next) {
    try {
      const cart = await CartService.getCart(req.user.id);

      return ResponseUtil.success(res, cart);
    } catch (error) {
      next(error);
    }
  }

  async addToCart(req, res, next) {
    try {
      const { productId, quantity = 1 } = req.body;

      const cart = await CartService.addToCart(req.user.id, productId, quantity);

      return ResponseUtil.success(res, cart, 'Product added to cart');
    } catch (error) {
      if (error.message === 'Product not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      if (error.message.includes('stock')) {
        return ResponseUtil.badRequest(res, error.message);
      }
      next(error);
    }
  }

  async updateQuantity(req, res, next) {
    try {
      const { productId } = req.params;
      const { quantity } = req.body;

      const cart = await CartService.updateQuantity(req.user.id, productId, quantity);

      return ResponseUtil.success(res, cart, 'Cart updated');
    } catch (error) {
      if (error.message === 'Cart not found' || error.message === 'Item not found in cart') {
        return ResponseUtil.notFound(res, error.message);
      }
      if (error.message.includes('stock') || error.message.includes('Quantity')) {
        return ResponseUtil.badRequest(res, error.message);
      }
      next(error);
    }
  }

  async removeFromCart(req, res, next) {
    try {
      const { productId } = req.params;

      const cart = await CartService.removeFromCart(req.user.id, productId);

      return ResponseUtil.success(res, cart, 'Product removed from cart');
    } catch (error) {
      if (error.message === 'Cart not found' || error.message === 'Item not found in cart') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }

  async clearCart(req, res, next) {
    try {
      const cart = await CartService.clearCart(req.user.id);

      return ResponseUtil.success(res, cart, 'Cart cleared');
    } catch (error) {
      if (error.message === 'Cart not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }
}

module.exports = new CartController();