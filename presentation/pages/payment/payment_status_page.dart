import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../home/home_page.dart';

class PaymentStatusPage extends StatelessWidget {
  final String orderId;
  final bool isSuccess;
  final bool isPending;
  final String message;

  const PaymentStatusPage({
    super.key,
    required this.orderId,
    required this.isSuccess,
    this.isPending = false,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animation or Icon
              _buildStatusIcon(),
              
              const SizedBox(height: 32),
              
              // Title
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
              
              // Message
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
              
              // Order ID
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
              
              const Spacer(),
              
              // Action Buttons
              _buildActionButtons(context),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isSuccess) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          size: 80,
          color: AppColors.success,
        ),
      );
    } else if (isPending) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.pending,
          size: 80,
          color: AppColors.warning,
        ),
      );
    } else {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          size: 80,
          color: AppColors.error,
        ),
      );
    }
  }

  String _getTitle() {
    if (isSuccess) {
      return 'Pembayaran Berhasil!';
    } else if (isPending) {
      return 'Menunggu Pembayaran';
    } else {
      return 'Pembayaran Gagal';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (isSuccess) ...[
          CustomButton(
            text: 'Lihat Pesanan',
            onPressed: () {
              // TODO: Navigate to order detail
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kembali ke Beranda',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            isOutlined: true,
            icon: Icons.home,
          ),
        ] else if (isPending) ...[
          CustomButton(
            text: 'Lihat Status Pembayaran',
            onPressed: () {
              // TODO: Navigate to payment status tracking
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            icon: Icons.payment,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kembali ke Beranda',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            isOutlined: true,
            icon: Icons.home,
          ),
        ] else ...[
          CustomButton(
            text: 'Coba Lagi',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icons.refresh,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kembali ke Beranda',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            isOutlined: true,
            icon: Icons.home,
          ),
        ],
      ],
    );
  }
}