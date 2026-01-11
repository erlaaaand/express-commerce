class ValidatorUtil {
  static isEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static isStrongPassword(password) {
    return password.length >= 6;
  }

  static isValidObjectId(id) {
    const objectIdRegex = /^[0-9a-fA-F]{24}$/;
    return objectIdRegex.test(id);
  }

  static isPositiveNumber(value) {
    return typeof value === 'number' && value > 0;
  }

  static sanitizeString(str) {
    return str.trim().replace(/\s+/g, ' ');
  }

  static validateRequired(fields, data) {
    const errors = [];
    
    for (const field of fields) {
      if (!data[field] || (typeof data[field] === 'string' && !data[field].trim())) {
        errors.push(`${field} is required`);
      }
    }

    return errors;
  }
}

module.exports = ValidatorUtil;