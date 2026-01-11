const express = require('express');
const router = express.Router();
const CartController = require('../controllers/cart.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const ValidationMiddleware = require('../middleware/validation.middleware');

router.use(AuthMiddleware.authenticate);

router.get('/', CartController.getCart);

router.post(
  '/',
  ValidationMiddleware.validateCart,
  CartController.addToCart
);

router.patch(
  '/:productId',
  ValidationMiddleware.validateCart,
  CartController.updateQuantity
);

router.delete('/:productId', CartController.removeFromCart);

router.delete('/', CartController.clearCart);

module.exports = router;