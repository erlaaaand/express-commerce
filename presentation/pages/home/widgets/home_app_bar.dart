import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../cart/cart_page.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.user?.username ?? 'Guest';

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.shopping_bag, color: AppColors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kadai Erland',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Halo, $username',
                  style: const TextStyle(fontSize: 12, color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartPage()));
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}