import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentWebViewSheet extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onSuccess;
  final VoidCallback onFailed;

  const PaymentWebViewSheet({
    super.key,
    required this.paymentUrl,
    required this.onSuccess,
    required this.onFailed,
  });

  @override
  State<PaymentWebViewSheet> createState() => _PaymentWebViewSheetState();
}

class _PaymentWebViewSheetState extends State<PaymentWebViewSheet> {
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
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading) _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}