import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProductDetailAdditionalInfo extends StatelessWidget {
  const ProductDetailAdditionalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const _InfoItem(
            icon: Icons.verified_user_outlined,
            text: '100% Produk Original',
          ),
          const SizedBox(height: 12),
          const _InfoItem(
            icon: Icons.local_shipping_outlined,
            text: 'Gratis Ongkir (Min. Rp 100.000)',
          ),
          const SizedBox(height: 12),
          const _InfoItem(
            icon: Icons.payment,
            text: 'Pembayaran Aman & Terpercaya',
          ),
          const SizedBox(height: 12),
          const _InfoItem(
            icon: Icons.support_agent,
            text: 'Customer Service 24/7',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}