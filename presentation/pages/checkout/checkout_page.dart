import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../orders/order_history_page.dart';

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
      builder: (context) => _PaymentWebViewSheet(
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Checkout Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Order ID: $orderId', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text(
              'Terima kasih telah berbelanja.\nPesanan Anda sedang diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Lihat Riwayat Pesanan',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
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
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(cart.totalAmount),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ongkir',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
            CustomTextField(
              labelText: 'Email',
              hintText: authProvider.user?.email ?? '',
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
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

class _PaymentWebViewSheet extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onSuccess;
  final VoidCallback onFailed;

  const _PaymentWebViewSheet({
    required this.paymentUrl,
    required this.onSuccess,
    required this.onFailed,
  });

  @override
  State<_PaymentWebViewSheet> createState() => _PaymentWebViewSheetState();
}

class _PaymentWebViewSheetState extends State<_PaymentWebViewSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.contains('status=success') || 
                url.contains('transaction_status=settlement') || 
                url.contains('payment/success') ||
                url.contains('capture')) {
              widget.onSuccess();
              return NavigationDecision.prevent;
            } else if (url.contains('status=failed') || 
                       url.contains('payment/failed') || 
                       url.contains('deny') || 
                       url.contains('cancel')) {
              widget.onFailed();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}