const AuthService = require('../services/auth.service');
const ResponseUtil = require('../utils/response.util');

class AuthController {
  async register(req, res, next) {
    try {
      const { username, email, password } = req.body;

      const user = await AuthService.register(username, email, password);

      return ResponseUtil.created(res, user, 'Registration successful');
    } catch (error) {
      if (error.message === 'Email already registered') {
        return ResponseUtil.conflict(res, error.message);
      }
      next(error);
    }
  }

  async login(req, res, next) {
    try {
      const { email, password } = req.body;

      const result = await AuthService.login(email, password);

      return ResponseUtil.success(res, {
        token: result.token,
        username: result.user.username
      }, 'Login successful');
    } catch (error) {
      if (error.message === 'Invalid credentials' || error.message === 'Account is deactivated') {
        return ResponseUtil.unauthorized(res, error.message);
      }
      next(error);
    }
  }

  async getProfile(req, res, next) {
    try {
      const user = await AuthService.getUserById(req.user.id);

      return ResponseUtil.success(res, user);
    } catch (error) {
      if (error.message === 'User not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }
}

module.exports = new AuthController();