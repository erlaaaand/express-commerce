import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String category;
  final String categoryName;

  const ProductListPage({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // name, price_low, price_high
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    Future.microtask(() {
      context.read<ProductProvider>().fetchProductsByCategory(widget.category);
    });
  }

  void _filterAndSortProducts(List<ProductModel> products) {
    List<ProductModel> filtered = products;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                icon: Icons.sort_by_alpha,
                title: 'Nama Produk',
                isSelected: _sortBy == 'name',
                onTap: () {
                  setState(() => _sortBy = 'name');
                  Navigator.pop(context);
                  _filterAndSortProducts(
                    context.read<ProductProvider>().products,
                  );
                },
              ),
              _SortOption(
                icon: Icons.arrow_upward,
                title: 'Harga Terendah',
                isSelected: _sortBy == 'price_low',
                onTap: () {
                  setState(() => _sortBy = 'price_low');
                  Navigator.pop(context);
                  _filterAndSortProducts(
                    context.read<ProductProvider>().products,
                  );
                },
              ),
              _SortOption(
                icon: Icons.arrow_downward,
                title: 'Harga Tertinggi',
                isSelected: _sortBy == 'price_high',
                onTap: () {
                  setState(() => _sortBy = 'price_high');
                  Navigator.pop(context);
                  _filterAndSortProducts(
                    context.read<ProductProvider>().products,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSortOptions,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _filterAndSortProducts(
                context.read<ProductProvider>().products,
              );
            },
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textHint),
                      onPressed: () {
                        _searchController.clear();
                        _filterAndSortProducts(
                          context.read<ProductProvider>().products,
                        );
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final products = _filteredProducts.isEmpty && 
                  _searchController.text.isEmpty
                  ? provider.products
                  : _filteredProducts;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${products.length} produk ditemukan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sort,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sortBy == 'name'
                              ? 'Nama'
                              : _sortBy == 'price_low'
                                  ? 'Termurah'
                                  : 'Termahal',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final products = _filteredProducts.isEmpty && 
            _searchController.text.isEmpty
            ? provider.products
            : _filteredProducts;

        if (products.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'Produk Tidak Ditemukan',
            message: _searchController.text.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Belum ada produk di kategori ini',
            actionText: 'Refresh',
            onActionPressed: _loadProducts,
          );
        }

        // GRID LAYOUT DENGAN 2 KOLOM
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 kolom
            childAspectRatio: 0.7, // Rasio tinggi/lebar
            crossAxisSpacing: 12, // Jarak horizontal antar item
            mainAxisSpacing: 12, // Jarak vertikal antar item
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductGridCard(product: product);
          },
        );
      },
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dengan AspectRatio 1:1 untuk konsistensi
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: ImageHelper.networkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Badge Promo
                if (product.hasPromo)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PROMO',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Badge Stock
                if (product.isLowStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sisa ${product.stock}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Harga Coret jika ada promo
                    if (product.hasPromo)
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    // Harga Aktual
                    Text(
                      CurrencyFormatter.format(product.effectivePrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}