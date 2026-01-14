import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/payment_provider.dart';
import '../home/home_page.dart';
import 'payment_status_page.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String orderId;
  final int totalAmount;

  const PaymentPage({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Gagal memuat halaman pembayaran';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleUrlChange(String url) {
    // Check if payment is completed based on URL
    if (url.contains('status=success') || 
        url.contains('transaction_status=settlement') ||
        url.contains('payment/success')) {
      _handlePaymentSuccess();
    } else if (url.contains('status=failed') || 
               url.contains('status=cancel') ||
               url.contains('payment/failed')) {
      _handlePaymentFailed();
    } else if (url.contains('status=pending')) {
      _handlePaymentPending();
    }
  }

  Future<void> _handlePaymentSuccess() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    // Check payment status from server
    final paymentProvider = context.read<PaymentProvider>();
    final success = await paymentProvider.checkPaymentStatus(widget.orderId);

    if (!mounted) return;

    if (success && paymentProvider.currentPayment?.isSuccess == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentStatusPage(
            orderId: widget.orderId,
            isSuccess: true,
            message: 'Pembayaran berhasil! Pesanan Anda sedang diproses.',
          ),
        ),
      );
    }
  }

  Future<void> _handlePaymentFailed() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusPage(
          orderId: widget.orderId,
          isSuccess: false,
          message: 'Pembayaran gagal. Silakan coba lagi.',
        ),
      ),
    );
  }

  Future<void> _handlePaymentPending() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusPage(
          orderId: widget.orderId,
          isSuccess: false,
          isPending: true,
          message: 'Pembayaran menunggu konfirmasi.',
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pembayaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (!mounted) return true;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _onWillPop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Menunggu Pembayaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _initializeWebView();
                          });
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              WebViewWidget(controller: _controller),
            
            if (_isLoading)
              Container(
                color: AppColors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat halaman pembayaran...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}