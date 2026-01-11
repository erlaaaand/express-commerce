const midtransConfig = require('../config/midtrans');
const OrderService = require('./order.service');
const { ORDER_STATUS } = require('../config/constants');

class PaymentService {
  async createPaymentTransaction(order, user) {
    const snap = midtransConfig.getSnapInstance();

    const itemDetails = order.items.map(item => {
      const safeName = item.productName.length > 50 
        ? item.productName.substring(0, 47) + '...' 
        : item.productName;

      return {
        id: item.productId.toString(),
        price: item.priceAtPurchase,
        quantity: item.quantity,
        name: safeName
      };
    });

    if (order.shippingFee && order.shippingFee > 0) {
      itemDetails.push({
        id: 'SHIPPING-FEE',
        price: order.shippingFee,
        quantity: 1,
        name: 'Shipping Fee'
      });
    }

    const parameter = {
      transaction_details: {
        order_id: order.orderId,
        gross_amount: order.totalAmount
      },
      credit_card: {
        secure: true
      },
      customer_details: {
        first_name: user.username,
        email: user.email
      },
      item_details: order.items.map(item => ({
        id: item.productId.toString(),
        name: item.productName,
        price: item.priceAtPurchase,
        quantity: item.quantity
      }))
    };

    try{
      const transaction = await snap.createTransaction(parameter);
  
      await OrderService.updateOrderPayment(
        order.orderId,
        transaction.token,
        transaction.redirect_url
      );

      return {
        token: transaction.token,
        redirect_url: transaction.redirect_url
      };
      
    } catch(error){
      console.error('Midtrans Error:', JSON.stringify(error.ApiResponse));
      throw new Error(`Midtrans API Error: ${error.message}`);
    }
  }

  async handlePaymentNotification(notification) {
    const snap = midtransConfig.getSnapInstance();
    
    const statusResponse = await snap.transaction.notification(notification);
    
    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    let orderStatus = ORDER_STATUS.PENDING;

    if (transactionStatus === 'capture') {
      orderStatus = fraudStatus === 'accept' 
        ? ORDER_STATUS.PAID 
        : ORDER_STATUS.PENDING;
    } else if (transactionStatus === 'settlement') {
      orderStatus = ORDER_STATUS.PAID;
    } else if (['cancel', 'deny', 'expire'].includes(transactionStatus)) {
      orderStatus = ORDER_STATUS.CANCELLED;
    }

    await OrderService.updateOrderStatus(orderId, orderStatus);

    return {
      orderId,
      status: orderStatus,
      transactionStatus
    };
  }

  async checkPaymentStatus(orderId) {
    const core = midtransConfig.getCoreInstance();
    
    const statusResponse = await core.transaction.status(orderId);
    
    return {
      orderId: statusResponse.order_id,
      transactionStatus: statusResponse.transaction_status,
      fraudStatus: statusResponse.fraud_status,
      grossAmount: statusResponse.gross_amount
    };
  }
}

module.exports = new PaymentService();