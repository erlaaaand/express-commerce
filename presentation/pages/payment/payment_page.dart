import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/payment_provider.dart';
import '../home/home_page.dart';
import 'payment_status_page.dart';
import 'widgets/payment_header.dart';
import 'widgets/payment_loading_view.dart';
import 'widgets/payment_error_view.dart';

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
            child: PaymentHeader(totalAmount: widget.totalAmount),
          ),
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              PaymentErrorView(
                message: _errorMessage!,
                onRetry: () {
                  setState(() {
                    _errorMessage = null;
                    _initializeWebView();
                  });
                },
              )
            else
              WebViewWidget(controller: _controller),
            
            if (_isLoading)
              const PaymentLoadingView(),
          ],
        ),
      ),
    );
  }
}