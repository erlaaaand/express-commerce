import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../products/product_list_page.dart';

class CategoryData {
  final String code;
  final String name;
  final String imagePath;

  CategoryData(this.code, this.name, this.imagePath);
}

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  static final List<CategoryData> categories = [
    CategoryData('Smartphone', 'Elektronik', 'lib/images/icon-elektronik.png'),
    CategoryData('Pakaian Pria', 'Pria', 'lib/images/icon-baju-pria.png'),
    CategoryData('Pakaian Wanita', 'Wanita', 'lib/images/icon-baju-wanita.png'),
    CategoryData('Sepatu Pria', 'Sepatu', 'lib/images/icon-sepatu-pria.png'),
    CategoryData('Sepatu Wanita', 'Wanita', 'lib/images/icon-sepatu-wanita.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              return _CategoryItem(category: categories[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryData category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListPage(
              category: category.code,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                category.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.category,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            flex: 1,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}