import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
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
  final ProductRepository _repository = ProductRepository();

  late Future<List<ProductModel>> _futureProducts;

  String _sortBy = 'name';
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _futureProducts = _repository.getProductsByCategory(widget.category);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAndSort(List<ProductModel> products) {
    List<ProductModel> result = products;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      result = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    switch (_sortBy) {
      case 'price_low':
        result.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        result.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      _filteredProducts = result;
    });
  }

  void _showSortOptions(List<ProductModel> products) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SortOption(
                title: 'Nama Produk',
                selected: _sortBy == 'name',
                onTap: () {
                  setState(() => _sortBy = 'name');
                  Navigator.pop(context);
                  _filterAndSort(products);
                },
              ),
              _SortOption(
                title: 'Harga Terendah',
                selected: _sortBy == 'price_low',
                onTap: () {
                  setState(() => _sortBy = 'price_low');
                  Navigator.pop(context);
                  _filterAndSort(products);
                },
              ),
              _SortOption(
                title: 'Harga Tertinggi',
                selected: _sortBy == 'price_high',
                onTap: () {
                  setState(() => _sortBy = 'price_high');
                  Navigator.pop(context);
                  _filterAndSort(products);
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
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Produk Tidak Ditemukan',
                    message: 'Belum ada produk di kategori ini',
                  );
                }

                final products = _filteredProducts.isEmpty &&
                        _searchController.text.isEmpty
                    ? snapshot.data!
                    : _filteredProducts;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) async {
          final products = await _futureProducts;
          _filterAndSort(products);
        },
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing:
          selected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}
