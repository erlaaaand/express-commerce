import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';

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

    // Check if logged in
    if (!authProvider.isAuthenticated) {
      final shouldLogin = await showDialog<bool>(
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

      if (shouldLogin == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    // Add to cart
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const Divider(thickness: 8, color: AppColors.background),
                _buildDescription(),
                const Divider(thickness: 8, color: AppColors.background),
                _buildAdditionalInfo(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.product.id}',
          child: ImageHelper.networkImage(
            url: widget.product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Price
          Row(
            children: [
              if (widget.product.hasPromo) ...[
                Text(
                  CurrencyFormatter.format(widget.product.price),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textHint,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${((widget.product.price - widget.product.promoPrice) / widget.product.price * 100).round()}% OFF',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          Text(
            CurrencyFormatter.format(widget.product.effectivePrice),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Stock
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.product.isLowStock
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.product.isLowStock
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: widget.product.isLowStock
                      ? AppColors.warning
                      : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stok tersedia: ${widget.product.stock} unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.product.isLowStock
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
                if (widget.product.isLowStock) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Segera Habis!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quantity selector
          Row(
            children: [
              const Text(
                'Jumlah:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementQuantity,
                      color: _quantity > 1
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementQuantity,
                      color: _quantity < widget.product.stock
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoItem(
            icon: Icons.verified_user_outlined,
            text: '100% Produk Original',
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.local_shipping_outlined,
            text: 'Gratis Ongkir (Min. Rp 100.000)',
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.payment,
            text: 'Pembayaran Aman & Terpercaya',
          ),
          const SizedBox(height: 12),
          _InfoItem(
            icon: Icons.support_agent,
            text: 'Customer Service 24/7',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
              onPressed: widget.product.isOutOfStock ? null : _addToCart,
              isLoading: cartProvider.isLoading,
              icon: Icons.add_shopping_cart,
            );
          },
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}