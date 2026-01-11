const JWTUtil = require('../utils/jwt.util');
const ResponseUtil = require('../utils/response.util');

class AuthMiddleware {
  static authenticate(req, res, next) {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return ResponseUtil.unauthorized(res, 'No token provided');
      }

      const token = authHeader.split(' ')[1];
      const decoded = JWTUtil.verifyToken(token);

      req.user = decoded;
      next();
    } catch (error) {
      return ResponseUtil.unauthorized(res, 'Invalid or expired token');
    }
  }
}

module.exports = AuthMiddleware;