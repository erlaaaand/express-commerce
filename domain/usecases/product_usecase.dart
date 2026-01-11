import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductUseCase {
  final ProductRepository _productRepository;

  ProductUseCase(this._productRepository);

  /// Get all products
  Future<List<ProductModel>> getProducts() async {
    final products = await _productRepository.getProducts();
    
    // Business logic: Sort by stock availability
    products.sort((a, b) {
      // Out of stock items go last
      if (a.isOutOfStock && !b.isOutOfStock) return 1;
      if (!a.isOutOfStock && b.isOutOfStock) return -1;
      return 0;
    });

    return products;
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    if (category.isEmpty) {
      throw Exception('Kategori tidak valid');
    }

    return await _productRepository.getProductsByCategory(category);
  }

  /// Get product by ID
  Future<ProductModel> getProductById(String productId) async {
    if (productId.isEmpty) {
      throw Exception('Product ID tidak valid');
    }

    return await _productRepository.getProductById(productId);
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      throw Exception('Query pencarian tidak boleh kosong');
    }

    if (query.length < 2) {
      throw Exception('Query pencarian minimal 2 karakter');
    }

    return await _productRepository.searchProducts(query);
  }

  /// Filter products by price range
  List<ProductModel> filterByPriceRange(
    List<ProductModel> products,
    int minPrice,
    int maxPrice,
  ) {
    if (minPrice < 0 || maxPrice < 0) {
      throw Exception('Harga tidak boleh negatif');
    }

    if (minPrice > maxPrice) {
      throw Exception('Harga minimum tidak boleh lebih besar dari harga maksimum');
    }

    return products.where((product) {
      final price = product.effectivePrice;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  /// Sort products
  List<ProductModel> sortProducts(
    List<ProductModel> products,
    ProductSortType sortType,
  ) {
    final sortedProducts = List<ProductModel>.from(products);

    switch (sortType) {
      case ProductSortType.nameAsc:
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortType.nameDesc:
        sortedProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortType.priceLowToHigh:
        sortedProducts.sort((a, b) => 
          a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case ProductSortType.priceHighToLow:
        sortedProducts.sort((a, b) => 
          b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case ProductSortType.stockLowToHigh:
        sortedProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case ProductSortType.stockHighToLow:
        sortedProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }

    return sortedProducts;
  }

  /// Filter products with promo
  List<ProductModel> getProductsWithPromo(List<ProductModel> products) {
    return products.where((product) => product.hasPromo).toList();
  }

  /// Filter products with low stock
  List<ProductModel> getProductsWithLowStock(List<ProductModel> products) {
    return products.where((product) => product.isLowStock).toList();
  }

  /// Filter products by availability
  List<ProductModel> getAvailableProducts(List<ProductModel> products) {
    return products.where((product) => !product.isOutOfStock).toList();
  }

  /// Calculate discount percentage
  int calculateDiscountPercentage(ProductModel product) {
    if (!product.hasPromo) return 0;
    
    final discount = product.price - product.promoPrice;
    return ((discount / product.price) * 100).round();
  }

  /// Calculate savings amount
  int calculateSavings(ProductModel product, int quantity) {
    if (!product.hasPromo) return 0;
    
    final savingsPerUnit = product.price - product.promoPrice;
    return savingsPerUnit * quantity;
  }

  /// Check if product is available for purchase
  bool isProductAvailable(ProductModel product, int requestedQuantity) {
    if (product.isOutOfStock) return false;
    if (requestedQuantity <= 0) return false;
    if (requestedQuantity > product.stock) return false;
    
    return true;
  }

  /// Get product recommendations (simple algorithm)
  List<ProductModel> getRecommendations(
    List<ProductModel> allProducts,
    ProductModel currentProduct, {
    int limit = 4,
  }) {
    // Filter by same category and exclude current product
    final recommendations = allProducts
        .where((p) => 
          p.category == currentProduct.category && 
          p.id != currentProduct.id &&
          !p.isOutOfStock)
        .toList();

    // Sort by price similarity
    recommendations.sort((a, b) {
      final aDiff = (a.effectivePrice - currentProduct.effectivePrice).abs();
      final bDiff = (b.effectivePrice - currentProduct.effectivePrice).abs();
      return aDiff.compareTo(bDiff);
    });

    return recommendations.take(limit).toList();
  }

  /// Search products locally (client-side filtering)
  List<ProductModel> searchProductsLocally(
    List<ProductModel> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    
    return products.where((product) {
      final name = product.name.toLowerCase();
      final description = product.description.toLowerCase();
      final category = product.category.toLowerCase();
      
      return name.contains(lowerQuery) ||
             description.contains(lowerQuery) ||
             category.contains(lowerQuery);
    }).toList();
  }

  /// Get featured products
  List<ProductModel> getFeaturedProducts(
    List<ProductModel> products, {
    int limit = 10,
  }) {
    // Prioritize products with promo and good stock
    final featured = List<ProductModel>.from(products);
    
    featured.sort((a, b) {
      // Products with promo first
      if (a.hasPromo && !b.hasPromo) return -1;
      if (!a.hasPromo && b.hasPromo) return 1;
      
      // Then by stock availability
      if (a.isOutOfStock && !b.isOutOfStock) return 1;
      if (!a.isOutOfStock && b.isOutOfStock) return -1;
      
      return 0;
    });

    return featured.take(limit).toList();
  }
}

enum ProductSortType {
  nameAsc,
  nameDesc,
  priceLowToHigh,
  priceHighToLow,
  stockLowToHigh,
  stockHighToLow,
}