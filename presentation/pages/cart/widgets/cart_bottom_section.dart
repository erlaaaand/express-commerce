import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../providers/cart_provider.dart';

class CartBottomSection extends StatelessWidget {
  final CartProvider cartProvider;
  final VoidCallback onCheckout;

  const CartBottomSection({
    super.key,
    required this.cartProvider,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final shippingCost = cartProvider.totalAmount >= 100000 ? 0 : 15000;
    final total = cartProvider.totalAmount + shippingCost;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSubtotalRow(),
            const SizedBox(height: 8),
            _buildShippingRow(shippingCost),
            if (cartProvider.totalAmount < 100000) ...[
              const SizedBox(height: 4),
              _buildFreeShippingInfo(),
            ],
            const Divider(height: 24),
            _buildTotalRow(total),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Checkout',
              onPressed: onCheckout,
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Subtotal:',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          CurrencyFormatter.format(cartProvider.totalAmount),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingRow(int shippingCost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ongkir:',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          shippingCost == 0
              ? 'GRATIS'
              : CurrencyFormatter.format(shippingCost),
          style: TextStyle(
            fontSize: 14,
            color: shippingCost == 0
                ? AppColors.success
                : AppColors.textSecondary,
            fontWeight: shippingCost == 0
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeShippingInfo() {
    return Text(
      'Belanja Rp ${CurrencyFormatter.format(100000 - cartProvider.totalAmount)} lagi untuk gratis ongkir',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.warning,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTotalRow(int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Flexible(
          child: Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}