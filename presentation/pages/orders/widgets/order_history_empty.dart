import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderHistoryEmpty extends StatelessWidget {
  const OrderHistoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            "Belum ada pesanan",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}