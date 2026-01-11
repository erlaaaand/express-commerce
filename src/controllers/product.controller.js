const ProductService = require('../services/product.service');
const ResponseUtil = require('../utils/response.util');

class ProductController {
  async getAllProducts(req, res, next) {
    try {
      const filters = {
        category: req.query.category,
        search: req.query.search
      };

      const products = await ProductService.getAllProducts(filters);

      return ResponseUtil.success(res, products);
    } catch (error) {
      next(error);
    }
  }

  async getProductById(req, res, next) {
    try {
      const product = await ProductService.getProductById(req.params.id);

      return ResponseUtil.success(res, product);
    } catch (error) {
      if (error.message === 'Invalid product ID' || error.message === 'Product not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }

  async createProduct(req, res, next) {
    try {
      const product = await ProductService.createProduct(req.body);

      return ResponseUtil.created(res, product, 'Product created successfully');
    } catch (error) {
      next(error);
    }
  }

  async updateProduct(req, res, next) {
    try {
      const product = await ProductService.updateProduct(req.params.id, req.body);

      return ResponseUtil.success(res, product, 'Product updated successfully');
    } catch (error) {
      if (error.message === 'Invalid product ID' || error.message === 'Product not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }

  async deleteProduct(req, res, next) {
    try {
      await ProductService.deleteProduct(req.params.id);

      return ResponseUtil.success(res, null, 'Product deleted successfully');
    } catch (error) {
      if (error.message === 'Invalid product ID' || error.message === 'Product not found') {
        return ResponseUtil.notFound(res, error.message);
      }
      next(error);
    }
  }
}

module.exports = new ProductController();