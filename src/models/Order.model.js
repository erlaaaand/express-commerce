const mongoose = require('mongoose');
const { ORDER_STATUS } = require('../config/constants');

const OrderItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  productName: {
    type: String,
    required: true
  },
  priceAtPurchase: {
    type: Number,
    required: true,
    min: 0
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  imageUrl: {
    type: String
  }
}, { _id: false });

const OrderSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    orderId: {
      type: String,
      required: true,
      unique: true
    },
    items: [OrderItemSchema],
    subtotal: { 
      type: Number, 
      required: true, 
      default: 0 
    },
    shippingFee: { 
      type: Number, 
      required: true, 
      default: 0 
    },
    totalAmount: {
      type: Number,
      required: true,
      min: 0
    },
    status: {
      type: String,
      enum: Object.values(ORDER_STATUS),
      default: ORDER_STATUS.PENDING
    },
    shippingAddress: {
      type: String,
      required: true
    },
    paymentToken: {
      type: String
    },
    paymentUrl: {
      type: String
    }
  },
  { 
    timestamps: true,
    collection: 'orders'
  }
);

OrderSchema.index({ userId: 1, createdAt: -1 });
OrderSchema.index({ status: 1 });

module.exports = mongoose.model('Order', OrderSchema);