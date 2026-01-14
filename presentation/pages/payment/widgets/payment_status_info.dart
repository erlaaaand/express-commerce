import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentStatusInfo extends StatelessWidget {
  final String orderId;
  final String message;
  final bool isSuccess;
  final bool isPending;

  const PaymentStatusInfo({
    super.key,
    required this.orderId,
    required this.message,
    required this.isSuccess,
    required this.isPending,
  });

  String _getTitle() {
    if (isSuccess) {
      return 'Pembayaran Berhasil!';
    } else if (isPending) {
      return 'Menunggu Pembayaran';
    } else {
      return 'Pembayaran Gagal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text(
                'ID Pesanan',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}