const Order = require('../models/Order.model');
const CartService = require('./cart.service');
const ProductService = require('./product.service');
const { ORDER_STATUS } = require('../config/constants');
const crypto = require('crypto');

class OrderService {
  calculateShippingFee(subtotal) {
    if (subtotal >= 100000) {
      return 0;
    }
    return 15000;
  }

  async createOrder(userId, shippingAddress) {
    const cart = await CartService.getCart(userId);

    if (!cart || cart.items.length === 0) {
      throw new Error('Cart is empty');
    }

    await CartService.validateCartStock(userId);

    const orderId = `ORD-${Date.now()}-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;

    const orderItems = cart.items.map(item => ({
      productId: item.productId,
      productName: item.productName,
      priceAtPurchase: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl
    }));

    const subtotal = cart.totalTemporaryAmount;
    
    const shippingFee = this.calculateShippingFee(subtotal);

    const totalAmount = subtotal + shippingFee;

    const order = await Order.create({
      userId,
      orderId,
      items: orderItems,
      subtotal,
      shippingFee,
      totalAmount,
      shippingAddress,
      status: ORDER_STATUS.PENDING
    });

    for (const item of orderItems) {
      await ProductService.decreaseStock(item.productId, item.quantity);
    }

    await CartService.clearCart(userId);

    return order;
  }

  async getOrdersByUser(userId) {
    return await Order.find({ userId }).sort({ createdAt: -1 });
  }

  async getOrderById(orderId, userId) {
    const order = await Order.findOne({ orderId, userId });
    
    if (!order) {
      throw new Error('Order not found');
    }

    return order;
  }

  async cancelOrder(orderId, userId) {
    const order = await Order.findOne({ orderId, userId });

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.status !== ORDER_STATUS.PENDING) {
      throw new Error('Order cannot be cancelled');
    }

    order.status = ORDER_STATUS.CANCELLED;
    await order.save();

    return order;
  }

  async updateOrderPayment(orderId, token, redirectUrl) {
    const order = await Order.findOne({ orderId });
    
    if (!order) {
      throw new Error('Order not found');
    }

    order.paymentToken = token;
    order.paymentUrl = redirectUrl;
    await order.save();

    return order;
  }

  async updateOrderStatus(orderId, status) {
    const order = await Order.findOne({ orderId });
    
    if (!order) {
      throw new Error('Order not found');
    }

    order.status = status;
    await order.save();

    return order;
  }
}

module.exports = new OrderService();