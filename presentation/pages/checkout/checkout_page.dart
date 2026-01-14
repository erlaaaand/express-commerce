import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'widgets/checkout_order_summary.dart';
import 'widgets/checkout_shipping_form.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/payment_webview_sheet.dart';
import 'widgets/checkout_success_dialog.dart';

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
      final response = await context.read<CartProvider>().checkoutCart(
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (response != null) {
        final paymentUrl = response['paymentUrl'] as String;
        final orderId = response['orderId'] as String;
        
        _showPaymentBottomSheet(paymentUrl, orderId);
      } else {
        Fluttertoast.showToast(
          msg: 'Checkout gagal, silakan coba lagi',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }

  void _showPaymentBottomSheet(String paymentUrl, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentWebViewSheet(
        paymentUrl: paymentUrl,
        onSuccess: () {
          Navigator.pop(context);
          _handleSuccessCheckout(orderId);
        },
        onFailed: () {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Pembayaran Gagal atau Dibatalkan");
        },
      ),
    );
  }

  void _handleSuccessCheckout(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckoutSuccessDialog(orderId: orderId),
    );
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
                CheckoutOrderSummary(cart: cartProvider.cart!),
                CheckoutShippingForm(
                  formKey: _formKey,
                  addressController: _addressController,
                  notesController: _notesController,
                  phoneController: _phoneController,
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CheckoutBottomBar(
        onCheckout: _processCheckout,
        isProcessing: _isProcessing,
      ),
    );
  }
}