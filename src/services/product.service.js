const Product = require('../models/Product.model');
const ValidatorUtil = require('../utils/validator.util');

class ProductService {
  async getAllProducts(filters = {}) {
    const query = { isActive: true };

    if (filters.category) {
      query.category = filters.category;
    }

    if (filters.search) {
      query.$text = { $search: filters.search };
    }

    const products = await Product.find(query)
      .sort({ createdAt: -1 })
      .lean();

    return products;
  }

  async getProductById(productId) {
    if (!ValidatorUtil.isValidObjectId(productId)) {
      throw new Error('Invalid product ID');
    }

    const product = await Product.findOne({ 
      _id: productId, 
      isActive: true 
    }).lean();

    if (!product) {
      throw new Error('Product not found');
    }

    return product;
  }

  async createProduct(productData) {
    const product = await Product.create({
      name: ValidatorUtil.sanitizeString(productData.name),
      price: productData.price,
      promoPrice: productData.promoPrice || 0,
      description: ValidatorUtil.sanitizeString(productData.description),
      imageUrl: productData.imageUrl,
      stock: productData.stock,
      vendor: ValidatorUtil.sanitizeString(productData.vendor),
      category: ValidatorUtil.sanitizeString(productData.category)
    });

    return product;
  }

  async updateProduct(productId, updateData) {
    if (!ValidatorUtil.isValidObjectId(productId)) {
      throw new Error('Invalid product ID');
    }

    const allowedUpdates = ['name', 'price', 'promoPrice', 'description', 'imageUrl', 'stock', 'vendor', 'category'];
    const updates = {};

    for (const key of allowedUpdates) {
      if (updateData[key] !== undefined) {
        updates[key] = typeof updateData[key] === 'string' 
          ? ValidatorUtil.sanitizeString(updateData[key])
          : updateData[key];
      }
    }

    const product = await Product.findByIdAndUpdate(
      productId,
      { $set: updates },
      { new: true, runValidators: true }
    ).lean();

    if (!product) {
      throw new Error('Product not found');
    }

    return product;
  }

  async deleteProduct(productId) {
    if (!ValidatorUtil.isValidObjectId(productId)) {
      throw new Error('Invalid product ID');
    }

    const product = await Product.findByIdAndUpdate(
      productId,
      { isActive: false },
      { new: true }
    ).lean();

    if (!product) {
      throw new Error('Product not found');
    }

    return product;
  }

  async checkStock(productId, quantity) {
    const product = await this.getProductById(productId);
    return product.stock >= quantity;
  }

  async decreaseStock(productId, quantity) {
    const product = await Product.findById(productId);
    
    if (!product) {
      throw new Error('Product not found');
    }

    if (product.stock < quantity) {
      throw new Error('Insufficient stock');
    }

    product.stock -= quantity;
    await product.save();

    return product;
  }
}

module.exports = new ProductService();