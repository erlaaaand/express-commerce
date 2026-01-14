import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Buat akun untuk mulai berbelanja',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}