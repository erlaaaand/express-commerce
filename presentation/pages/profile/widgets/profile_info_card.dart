import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class ProfileInfoCard extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileInfoCard({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person_outline,
            'Username',
            authProvider.user?.username ?? '-',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            authProvider.user?.email ?? '-',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Status',
            authProvider.user?.isActive == true ? 'Aktif' : 'Tidak Aktif',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}