// routes/payment.js
const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/authMiddleware');
const paymentController = require('../controllers/paymentController');

router.post('/process', verifyToken, paymentController.createTransaction);

module.exports = router;