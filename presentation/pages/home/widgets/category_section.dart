import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../products/product_list_page.dart';

enum ProductCategory {
  smartphone,
  pakaianPria,
  pakaianWanita,
  sepatuPria,
  sepatuWanita,
}

extension ProductCategoryExt on ProductCategory {
  String get apiValue {
    switch (this) {
      case ProductCategory.smartphone:
        return 'Smartphone';
      case ProductCategory.pakaianPria:
        return 'Pakaian Pria';
      case ProductCategory.pakaianWanita:
        return 'Pakaian Wanita';
      case ProductCategory.sepatuPria:
        return 'Sepatu Pria';
      case ProductCategory.sepatuWanita:
        return 'Sepatu Wanita';
    }
  }

  String get label {
    switch (this) {
      case ProductCategory.smartphone:
        return 'Elektronik';
      case ProductCategory.pakaianPria:
        return 'Pakaian Pria';
      case ProductCategory.pakaianWanita:
        return 'Pakaian Wanita';
      case ProductCategory.sepatuPria:
        return 'Sepatu Pria';
      case ProductCategory.sepatuWanita:
        return 'Sepatu Wanita';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.smartphone:
        return Icons.devices;
      case ProductCategory.pakaianPria:
        return Icons.checkroom;
      case ProductCategory.pakaianWanita:
        return Icons.shopping_bag;
      case ProductCategory.sepatuPria:
        return Icons.sports_basketball;
      case ProductCategory.sepatuWanita:
        return Icons.sports_tennis;
    }
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ProductCategory.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _CategoryCard(category: categories[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ProductCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListPage(
              category: category.apiValue,
              categoryName: category.label, 
            ),
          ),
        );
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                category.icon,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
