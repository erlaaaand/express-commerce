const midtransConfig = require('../config/midtrans');
const OrderService = require('./order.service');
const { ORDER_STATUS } = require('../config/constants');

class PaymentService {
  async createPaymentTransaction(order, user) {
    const snap = midtransConfig.getSnapInstance();

    const itemDetails = order.items.map(item => {
      const rawName = item.productName || 'Item';
      
      const safeName = rawName.length > 40 
        ? rawName.substring(0, 37) + '...' 
        : rawName;

      const price = parseInt(item.priceAtPurchase);
      const quantity = parseInt(item.quantity);
    
      return {
        id: item.productId.toString(),
        price: price,
        quantity: quantity,
        name: safeName
      };
    });

    const currentItemsTotal = itemDetails.reduce((acc, item) => {
      return acc + (item.price * item.quantity);
    }, 0);

    const targetTotalAmount = parseInt(order.totalAmount);
    const difference = targetTotalAmount - currentItemsTotal;

    if (difference > 0) {
      itemDetails.push({
        id: 'SHIPPING-FEE',
        price: difference,
        quantity: 1,
        name: 'Biaya Pengiriman'
      });
    }

    const finalGrossAmount = itemDetails.reduce((acc, item) => {
      return acc + (item.price * item.quantity);
    }, 0);

    const parameter = {
      transaction_details: {
        order_id: order.orderId,
        gross_amount: finalGrossAmount
      },
      credit_card: {
        secure: true
      },
      customer_details: {
        first_name: user.username,
        email: user.email
      },
      item_details: itemDetails
    };

    try {
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
      
    } catch(error) {
      console.error('Midtrans Error Detail:', JSON.stringify(error.ApiResponse || error));
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