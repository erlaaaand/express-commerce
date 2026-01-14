import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/product_model.dart';

class ProductDetailInfo extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductDetailInfo({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (product.hasPromo) _buildPromoRow(),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(product.effectivePrice),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStockInfo(),
          const SizedBox(height: 20),
          _buildQuantitySelector(),
        ],
      ),
    );
  }

  Widget _buildPromoRow() {
    return Row(
      children: [
        Text(
          CurrencyFormatter.format(product.price),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textHint,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${((product.price - product.promoPrice) / product.price * 100).round()}% OFF',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: product.isLowStock
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: product.isLowStock
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: product.isLowStock
                ? AppColors.warning
                : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Stok tersedia: ${product.stock} unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: product.isLowStock
                  ? AppColors.warning
                  : AppColors.success,
            ),
          ),
          if (product.isLowStock) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Segera Habis!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Jumlah:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrement,
                color: quantity > 1
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrement,
                color: quantity < product.stock
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}