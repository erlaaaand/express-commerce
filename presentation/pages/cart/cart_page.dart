import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<CartProvider>().fetchCart();
      }
    });
  }

  Future<void> _checkout() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text('Anda harus login untuk melakukan checkout'),
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

    // TODO: Navigate to checkout page
    Fluttertoast.showToast(
      msg: 'Fitur checkout sedang dalam pengembangan',
      backgroundColor: AppColors.info,
      textColor: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearCartDialog(cartProvider),
                tooltip: 'Kosongkan Keranjang',
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (cartProvider.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang Masih Kosong',
              message: 'Yuk, mulai belanja dan temukan produk favorit Anda!',
              actionText: 'Mulai Belanja',
              onActionPressed: () => Navigator.pop(context),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.cart!.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart!.items[index];
                    return _CartItemCard(
                      item: item,
                      onRemove: () => _removeItem(cartProvider, item.productId),
                      onUpdateQuantity: (quantity) =>
                          _updateQuantity(cartProvider, item.productId, quantity),
                    );
                  },
                ),
              ),
              _buildBottomSection(cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(CartProvider cartProvider) {
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Belanja:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(cartProvider.totalAmount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Checkout',
              onPressed: _checkout,
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeItem(CartProvider cartProvider, String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await cartProvider.removeFromCart(productId);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(
            msg: 'Item berhasil dihapus',
            backgroundColor: AppColors.success,
            textColor: AppColors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: cartProvider.errorMessage ?? 'Gagal menghapus item',
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        }
      }
    }
  }

  Future<void> _updateQuantity(
    CartProvider cartProvider,
    String productId,
    int quantity,
  ) async {
    final success = await cartProvider.updateQuantity(
      productId: productId,
      quantity: quantity,
    );

    if (!success && mounted) {
      Fluttertoast.showToast(
        msg: cartProvider.errorMessage ?? 'Gagal update jumlah',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  Future<void> _showClearCartDialog(CartProvider cartProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text(
          'Apakah Anda yakin ingin mengosongkan semua item di keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await cartProvider.clearCart();

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(
            msg: 'Keranjang berhasil dikosongkan',
            backgroundColor: AppColors.success,
            textColor: AppColors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: cartProvider.errorMessage ?? 'Gagal mengosongkan keranjang',
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        }
      }
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageHelper.networkImage(
                url: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(item.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: item.quantity > 1
                                  ? () => onUpdateQuantity(item.quantity - 1)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: item.quantity > 1
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => onUpdateQuantity(item.quantity + 1),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.format(item.subtotal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Delete button
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}