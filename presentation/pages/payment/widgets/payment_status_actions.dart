import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../home/home_page.dart';

class PaymentStatusActions extends StatelessWidget {
  final bool isSuccess;
  final bool isPending;

  const PaymentStatusActions({
    super.key,
    required this.isSuccess,
    required this.isPending,
  });

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isSuccess) ...[
          CustomButton(
            text: 'Lihat Pesanan',
            onPressed: () => _navigateToHome(context),
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kembali ke Beranda',
            onPressed: () => _navigateToHome(context),
            isOutlined: true,
            icon: Icons.home,
          ),
        ] else if (isPending) ...[
          CustomButton(
            text: 'Lihat Status Pembayaran',
            onPressed: () => _navigateToHome(context),
            icon: Icons.payment,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kembali ke Beranda',
            onPressed: () => _navigateToHome(context),
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
            onPressed: () => _navigateToHome(context),
            isOutlined: true,
            icon: Icons.home,
          ),
        ],
      ],
    );
  }
}