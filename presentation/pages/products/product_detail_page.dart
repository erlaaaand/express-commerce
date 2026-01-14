import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import 'widgets/product_detail_app_bar.dart';
import 'widgets/product_detail_info.dart';
import 'widgets/product_detail_description.dart';
import 'widgets/product_detail_additional_info.dart';
import 'widgets/product_detail_bottom_bar.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart() async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    if (!authProvider.isAuthenticated) {
      final shouldLogin = await _showLoginDialog();
      if (shouldLogin == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    final success = await cartProvider.addToCart(
      productId: widget.product.id,
      quantity: _quantity,
    );

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Berhasil ditambahkan ke keranjang!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: cartProvider.errorMessage ?? 'Gagal menambahkan ke keranjang',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  Future<bool?> _showLoginDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Anda harus login untuk menambahkan produk ke keranjang',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          ProductDetailAppBar(product: widget.product),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductDetailInfo(
                  product: widget.product,
                  quantity: _quantity,
                  onIncrement: _incrementQuantity,
                  onDecrement: _decrementQuantity,
                ),
                const Divider(thickness: 8, color: AppColors.background),
                ProductDetailDescription(product: widget.product),
                const Divider(thickness: 8, color: AppColors.background),
                const ProductDetailAdditionalInfo(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductDetailBottomBar(
        product: widget.product,
        onAddToCart: _addToCart,
      ),
    );
  }
}