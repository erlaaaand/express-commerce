import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/product_model.dart';
import '../../../providers/cart_provider.dart';

class ProductDetailBottomBar extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductDetailBottomBar({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return CustomButton(
              text: 'Tambah ke Keranjang',
              onPressed: product.isOutOfStock ? null : onAddToCart,
              isLoading: cartProvider.isLoading,
              icon: Icons.add_shopping_cart,
            );
          },
        ),
      ),
    );
  }
}