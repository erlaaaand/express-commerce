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

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _products = await _productRepository.getProducts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

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

  List<ProductModel> filterByPriceRange(int minPrice, int maxPrice) {
    return _products.where((product) {
      final price = product.effectivePrice;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

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

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
