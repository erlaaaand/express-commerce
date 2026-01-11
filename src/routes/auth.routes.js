const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/auth.controller');
const AuthMiddleware = require('../middleware/auth.middleware');
const ValidationMiddleware = require('../middleware/validation.middleware');
const { authLimiter } = require('../middleware/rateLimiter.middleware');

router.post(
  '/register',
  authLimiter,
  ValidationMiddleware.validateRegistration,
  AuthController.register
);

router.post(
  '/login',
  authLimiter,
  ValidationMiddleware.validateLogin,
  AuthController.login
);

router.get(
  '/profile',
  AuthMiddleware.authenticate,
  AuthController.getProfile
);

module.exports = router;