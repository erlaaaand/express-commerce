const OrderService = require('../services/order.service');
const PaymentService = require('../services/payment.service');
const AuthService = require('../services/auth.service');
const ResponseUtil = require('../utils/response.util');

class OrderController {
  async checkout(req, res, next) {
    try {
      const { shippingAddress } = req.body;

      const order = await OrderService.createOrder(req.user.id, shippingAddress);
      const user = await AuthService.getUserById(req.user.id);
      const payment = await PaymentService.createPaymentTransaction(order, user);

      return ResponseUtil.created(res, {
        orderId: order.orderId,
        paymentUrl: payment.redirect_url,
        totalAmount: order.totalAmount,
        status: order.status,
        details: {
          order,
          payment
        }
      }, 'Order created successfully');
    } catch (error) {
      if (error.message === 'Cart is empty' || error.message.includes('stock')) {
        return ResponseUtil.badRequest(res, error.message);
      }
      next(error);
    }
  }

  async getOrders(req, res, next) {
    try {
      const orders = await OrderService.getOrdersByUser(req.user.id);

      return ResponseUtil.success(res, orders);
    } catch (error) {
      next(error);
    }
  }

  async getOrderById(req, res, next) {
    try {
      const { orderId } = req.params;

      const order = await OrderService.getOrderById(orderId, req.user.id);

      return ResponseUtil.success(res, order);
    } catch (error) {
      if (error.message === 'Order not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }

  async cancelOrder(req, res, next) {
    try {
      const { orderId } = req.params;

      const order = await OrderService.cancelOrder(orderId, req.user.id);

      return ResponseUtil.success(res, order, 'Order cancelled successfully');
    } catch (error) {
      if (error.message === 'Order not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      if (error.message.includes('cancelled')) {
        return ResponseUtil.badRequest(res, error.message);
      }
      next(error);
    }
  }
}

module.exports = new OrderController();