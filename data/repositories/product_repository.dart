import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get(ApiConstants.products);
      
      final data = response['data'] as List<dynamic>;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

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