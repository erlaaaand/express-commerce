import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/payment_status_icon.dart';
import 'widgets/payment_status_info.dart';
import 'widgets/payment_status_actions.dart';

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
              PaymentStatusIcon(
                isSuccess: isSuccess,
                isPending: isPending,
              ),
              const SizedBox(height: 32),
              PaymentStatusInfo(
                orderId: orderId,
                message: message,
                isSuccess: isSuccess,
                isPending: isPending,
              ),
              const Spacer(),
              PaymentStatusActions(
                isSuccess: isSuccess,
                isPending: isPending,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}