import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../payment/payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final cartProvider = context.read<CartProvider>();
      
      // Call checkout API endpoint which will handle both order creation and payment
      final response = await context.read<CartProvider>().checkoutCart(
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (response != null) {
        // Navigate to payment page with payment URL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              paymentUrl: response['paymentUrl'] as String,
              orderId: response['orderId'] as String,
              totalAmount: response['totalAmount'] as int,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Checkout gagal, silakan coba lagi',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cart == null || cartProvider.isEmpty) {
            return const Center(
              child: Text('Keranjang kosong'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderSummary(cartProvider.cart!),
                _buildShippingForm(),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOrderSummary(CartModel cart) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.productName} x${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.format(cart.totalAmount),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ongkir',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                cart.totalAmount >= 100000 ? 'GRATIS' : CurrencyFormatter.format(15000),
                style: TextStyle(
                  fontSize: 14,
                  color: cart.totalAmount >= 100000 ? AppColors.success : AppColors.textSecondary,
                  fontWeight: cart.totalAmount >= 100000 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                CurrencyFormatter.format(
                  cart.totalAmount + (cart.totalAmount >= 100000 ? 0 : 15000),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    final authProvider = context.watch<AuthProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Email (read-only)
            CustomTextField(
              labelText: 'Email',
              hintText: authProvider.user?.email ?? '',
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            // Phone
            CustomTextField(
              controller: _phoneController,
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),

            // Address
            CustomTextField(
              controller: _addressController,
              labelText: 'Alamat Lengkap',
              hintText: 'Jalan, RT/RW, Kelurahan, Kecamatan, Kota',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (value) => Validators.validateMinLength(
                value,
                10,
                fieldName: 'Alamat',
              ),
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            CustomTextField(
              controller: _notesController,
              labelText: 'Catatan (Opsional)',
              hintText: 'Contoh: Warna, ukuran, dll',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final shippingCost = cartProvider.totalAmount >= 100000 ? 0 : 15000;
        final total = cartProvider.totalAmount + shippingCost;

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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(total),
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
                  text: 'Lanjut ke Pembayaran',
                  onPressed: _processCheckout,
                  isLoading: _isProcessing,
                  icon: Icons.payment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}