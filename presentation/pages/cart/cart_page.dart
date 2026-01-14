import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../checkout/checkout_page.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_bottom_section.dart';

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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
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
                    return CartItemCard(
                      item: item,
                      onRemove: () => _removeItem(cartProvider, item.productId),
                    );
                  },
                ),
              ),
              CartBottomSection(
                cartProvider: cartProvider,
                onCheckout: _checkout,
              ),
            ],
          );
        },
      ),
    );
  }
}