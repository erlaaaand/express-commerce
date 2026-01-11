const mongoose = require('mongoose');

const CartItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  productName: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  imageUrl: {
    type: String
  },
  quantity: {
    type: Number,
    required: true,
    min: 1,
    default: 1
  }
}, { _id: false });

const CartSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true
    },
    items: [CartItemSchema],
    totalTemporaryAmount: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  { 
    timestamps: true,
    collection: 'carts'
  }
);

CartSchema.methods.calculateTotal = function() {
  this.totalTemporaryAmount = this.items.reduce(
    (total, item) => total + (item.price * item.quantity), 
    0
  );
  return this.totalTemporaryAmount;
};

module.exports = mongoose.model('Cart', CartSchema);