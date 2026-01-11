import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  // Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get(ApiConstants.products);
      
      final data = response['data'] as List<dynamic>;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await _apiService.get(
        ApiConstants.productsByCategory(category),
      );
      
      final data = response['data'] as List<dynamic>;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Get product by ID
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.productById(productId),
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.products}?search=$query',
      );
      
      final data = response['data'] as List<dynamic>;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Create product (admin only)
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.post(
        ApiConstants.products,
        productData,
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product (admin only)
  Future<ProductModel> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final response = await _apiService.put(
        ApiConstants.productById(productId),
        productData,
        requiresAuth: true,
      );
      
      final data = response['data'] as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (admin only)
  Future<void> deleteProduct(String productId) async {
    try {
      await _apiService.delete(
        ApiConstants.productById(productId),
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}