const bcrypt = require('bcryptjs');
const User = require('../models/User.model');
const JWTUtil = require('../utils/jwt.util');
const ValidatorUtil = require('../utils/validator.util');
const { BCRYPT_SALT_ROUNDS } = require('../config/constants');

class AuthService {
  async register(username, email, password) {
    const sanitizedUsername = ValidatorUtil.sanitizeString(username);
    const sanitizedEmail = email.toLowerCase().trim();

    const existingUser = await User.findOne({ email: sanitizedEmail });
    if (existingUser) {
      throw new Error('Email already registered');
    }

    const hashedPassword = await bcrypt.hash(password, BCRYPT_SALT_ROUNDS);

    const user = await User.create({
      username: sanitizedUsername,
      email: sanitizedEmail,
      passwordHash: hashedPassword
    });

    return {
      id: user._id,
      username: user.username,
      email: user.email
    };
  }

  async login(email, password) {
    const sanitizedEmail = email.toLowerCase().trim();

    const user = await User.findOne({ email: sanitizedEmail }).select('+passwordHash');
    if (!user) {
      throw new Error('Invalid credentials');
    }

    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    const token = JWTUtil.generateToken({ 
      id: user._id,
      email: user.email
    });

    return {
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email
      }
    };
  }

  async getUserById(userId) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    return {
      id: user._id,
      username: user.username,
      email: user.email
    };
  }
}

module.exports = new AuthService();