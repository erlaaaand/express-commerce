import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentStatusIcon extends StatelessWidget {
  final bool isSuccess;
  final bool isPending;

  const PaymentStatusIcon({
    super.key,
    required this.isSuccess,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
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
}