const PaymentService = require('../services/payment.service');
const ResponseUtil = require('../utils/response.util');

class PaymentController {
  async handleNotification(req, res, next) {
    try {
      const result = await PaymentService.handlePaymentNotification(req.body);

      return ResponseUtil.success(res, result, 'Notification processed');
    } catch (error) {
      next(error);
    }
  }

  async checkStatus(req, res, next) {
    try {
      const { orderId } = req.params;

      const status = await PaymentService.checkPaymentStatus(orderId);

      return ResponseUtil.success(res, status);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new PaymentController();