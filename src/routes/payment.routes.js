const express = require('express');
const router = express.Router();
const PaymentController = require('../controllers/payment.controller');
const AuthMiddleware = require('../middleware/auth.middleware');

router.post('/notification', PaymentController.handleNotification);

router.get(
  '/status/:orderId',
  AuthMiddleware.authenticate,
  PaymentController.checkStatus
);

module.exports = router;