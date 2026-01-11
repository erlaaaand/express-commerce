const Cart = require('../models/Cart.model');
const ProductService = require('./product.service');

class CartService {
  async getCart(userId) {
    let cart = await Cart.findOne({ userId }).lean();

    if (!cart) {
      cart = { items: [], totalTemporaryAmount: 0 };
    }

    return cart;
  }

  async addToCart(userId, productId, quantity = 1) {
    const product = await ProductService.getProductById(productId);

    if (product.stock < quantity) {
      throw new Error('Insufficient stock');
    }

    let cart = await Cart.findOne({ userId });

    if (!cart) {
      cart = new Cart({ userId, items: [] });
    }

    const existingItemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId
    );

    if (existingItemIndex > -1) {
      const newQuantity = cart.items[existingItemIndex].quantity + quantity;
      
      if (newQuantity > product.stock) {
        throw new Error('Quantity exceeds available stock');
      }

      cart.items[existingItemIndex].quantity = newQuantity;
    } else {
      cart.items.push({
        productId: product._id,
        productName: product.name,
        price: product.promoPrice > 0 ? product.promoPrice : product.price,
        imageUrl: product.imageUrl,
        quantity
      });
    }

    cart.calculateTotal();
    await cart.save();

    return cart;
  }

  async updateQuantity(userId, productId, quantity) {
    if (quantity < 1) {
      throw new Error('Quantity must be at least 1');
    }

    const cart = await Cart.findOne({ userId });
    if (!cart) {
      throw new Error('Cart not found');
    }

    const itemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId
    );

    if (itemIndex === -1) {
      throw new Error('Item not found in cart');
    }

    const product = await ProductService.getProductById(productId);
    if (quantity > product.stock) {
      throw new Error('Quantity exceeds available stock');
    }

    cart.items[itemIndex].quantity = quantity;
    cart.calculateTotal();
    await cart.save();

    return cart;
  }

  async removeFromCart(userId, productId) {
    const cart = await Cart.findOne({ userId });
    if (!cart) {
      throw new Error('Cart not found');
    }

    const initialLength = cart.items.length;
    cart.items = cart.items.filter(
      item => item.productId.toString() !== productId
    );

    if (cart.items.length === initialLength) {
      throw new Error('Item not found in cart');
    }

    cart.calculateTotal();
    await cart.save();

    return cart;
  }

  async clearCart(userId) {
    const cart = await Cart.findOne({ userId });
    if (!cart) {
      throw new Error('Cart not found');
    }

    cart.items = [];
    cart.totalTemporaryAmount = 0;
    await cart.save();

    return cart;
  }

  async validateCartStock(userId) {
    const cart = await Cart.findOne({ userId });
    if (!cart || cart.items.length === 0) {
      throw new Error('Cart is empty');
    }

    for (const item of cart.items) {
      const hasStock = await ProductService.checkStock(
        item.productId, 
        item.quantity
      );

      if (!hasStock) {
        throw new Error(`Insufficient stock for ${item.productName}`);
      }
    }

    return true;
  }
}

module.exports = new CartService();