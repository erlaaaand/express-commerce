import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../orders/order_history_page.dart';

class CheckoutSuccessDialog extends StatelessWidget {
  final String orderId;

  const CheckoutSuccessDialog({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          Text(
            'Order ID: $orderId',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
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
    );
  }
}