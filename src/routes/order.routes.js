const express = require('express');
const router = express.Router();
const OrderController = require('../controllers/order.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const ValidationMiddleware = require('../middleware/validation.middleware');

router.use(AuthMiddleware.authenticate);

router.post(
  '/checkout',
  ValidationMiddleware.validateCheckout,
  OrderController.checkout
);

router.get('/', OrderController.getOrders);

router.get('/:orderId', OrderController.getOrderById);

router.post('/:orderId/cancel', OrderController.cancelOrder);

module.exports = router;