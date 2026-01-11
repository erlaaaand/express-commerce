const express = require('express');
const router = express.Router();
const ProductController = require('../controllers/product.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const ValidationMiddleware = require('../middleware/validation.middleware');

router.get('/', ProductController.getAllProducts);

router.get('/:id', ProductController.getProductById);

router.post(
  '/',
  AuthMiddleware.authenticate,
  ValidationMiddleware.validateProduct,
  ProductController.createProduct
);

router.put(
  '/:id',
  AuthMiddleware.authenticate,
  ValidationMiddleware.validateProduct,
  ProductController.updateProduct
);

router.delete(
  '/:id',
  AuthMiddleware.authenticate,
  ProductController.deleteProduct
);

module.exports = router;