const ValidatorUtil = require('../utils/validator.util');
const ResponseUtil = require('../utils/response.util');

class ValidationMiddleware {
  static validateRegistration(req, res, next) {
    const { username, email, password } = req.body;
    const errors = [];

    if (!username || username.trim().length < 3) {
      errors.push('Username must be at least 3 characters');
    }

    if (!email || !ValidatorUtil.isEmail(email)) {
      errors.push('Valid email is required');
    }

    if (!password || !ValidatorUtil.isStrongPassword(password)) {
      errors.push('Password must be at least 6 characters');
    }

    if (errors.length > 0) {
      return ResponseUtil.badRequest(res, 'Validation failed', errors);
    }

    next();
  }

  static validateLogin(req, res, next) {
    const { email, password } = req.body;
    const errors = [];

    if (!email || !ValidatorUtil.isEmail(email)) {
      errors.push('Valid email is required');
    }

    if (!password) {
      errors.push('Password is required');
    }

    if (errors.length > 0) {
      return ResponseUtil.badRequest(res, 'Validation failed', errors);
    }

    next();
  }

  static validateProduct(req, res, next) {
    const { name, price, description, stock, vendor, category } = req.body;
    const errors = ValidatorUtil.validateRequired(
      ['name', 'price', 'description', 'stock', 'vendor', 'category'], 
      req.body
    );

    if (price && !ValidatorUtil.isPositiveNumber(price)) {
      errors.push('Price must be a positive number');
    }

    if (stock && (!Number.isInteger(stock) || stock < 0)) {
      errors.push('Stock must be a non-negative integer');
    }

    if (errors.length > 0) {
      return ResponseUtil.badRequest(res, 'Validation failed', errors);
    }

    next();
  }

  static validateCart(req, res, next) {
    const { productId, quantity } = req.body;
    const errors = [];

    if (!productId) {
      errors.push('Product ID is required');
    }

    if (quantity && (!Number.isInteger(quantity) || quantity < 1)) {
      errors.push('Quantity must be a positive integer');
    }

    if (errors.length > 0) {
      return ResponseUtil.badRequest(res, 'Validation failed', errors);
    }

    next();
  }

  static validateCheckout(req, res, next) {
    const { shippingAddress } = req.body;
    const errors = ValidatorUtil.validateRequired(['shippingAddress'], req.body);

    if (shippingAddress && shippingAddress.trim().length < 10) {
      errors.push('Shipping address must be at least 10 characters');
    }

    if (errors.length > 0) {
      return ResponseUtil.badRequest(res, 'Validation failed', errors);
    }

    next();
  }
}

module.exports = ValidationMiddleware;