import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();

  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all products
  Future<void> fetchProducts() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _products = await _productRepository.getProducts();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _products = await _productRepository.getProductsByCategory(category);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  // Fetch product by ID
  Future<void> fetchProductById(String productId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _selectedProduct = await _productRepository.getProductById(productId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _products = await _productRepository.searchProducts(query);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  // Filter products by price range
  List<ProductModel> filterByPriceRange(int minPrice, int maxPrice) {
    return _products.where((product) {
      final price = product.effectivePrice;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  // Sort products
  void sortProducts(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        _products.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        _products.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'name':
      default:
        _products.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  // Get products by category (local filter)
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}