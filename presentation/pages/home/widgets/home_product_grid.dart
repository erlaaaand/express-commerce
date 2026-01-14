import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../providers/product_provider.dart';
import '../../products/product_detail_page.dart';

class HomeProductGrid extends StatelessWidget {
  final VoidCallback onRefresh;

  const HomeProductGrid({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (provider.products.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum Ada Produk',
              message: 'Produk akan segera tersedia',
              actionText: 'Refresh',
              onActionPressed: onRefresh,
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = provider.products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                );
              },
              childCount: provider.products.length,
            ),
          ),
        );
      },
    );
  }
}