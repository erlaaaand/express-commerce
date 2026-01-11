const { HTTP_STATUS, NODE_ENV } = require('../config/constants');

const errorMiddleware = (err, req, res, next) => {
  const statusCode = err.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR;
  const message = err.message || 'Internal server error';

  const response = {
    status: 'error',
    message
  };

  if (NODE_ENV === 'development') {
    response.stack = err.stack;
    response.error = err;
  }

  console.error(`[ERROR] ${message}`, err);

  res.status(statusCode).json(response);
};

module.exports = errorMiddleware;