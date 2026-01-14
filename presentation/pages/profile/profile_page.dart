import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/profile_unauthenticated.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_menu.dart';
import 'widgets/profile_logout_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const ProfileUnauthenticated();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          ProfileHeader(authProvider: authProvider),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ProfileInfoCard(authProvider: authProvider),
                const SizedBox(height: 16),
                const ProfileMenu(),
                const SizedBox(height: 16),
                ProfileLogoutButton(authProvider: authProvider),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}