const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Product name is required'],
      trim: true,
    },

    price: {
      type: Number,
      required: [true, 'Product price is required'],
    },

    promoPrice: {
      type: Number,
      default: 0,
    },

    description: {
      type: String,
      required: [true, 'Product description is required'],
    },

    imageUrl: {
      type: String,
      required: [true, 'Product image is required'],
    },

    stock: {
      type: Number,
      required: [true, 'Product stock is required'],
      min: 0,
    },

    vendor: {
      type: String,
      required: [true, 'Product vendor is required'],
    },

    category: {
      type: String,
      required: [true, 'Product category is required'],
    },
  },
  {
    timestamps: true,
    collection: 'products',
  }
);

module.exports = mongoose.model('Product', ProductSchema);
