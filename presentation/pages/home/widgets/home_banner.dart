import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BannerData {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color color;

  BannerData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class HomeBanner extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const HomeBanner({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  static final List<BannerData> banners = [
    BannerData(
      imagePath: 'lib/images/gadget-banner.webp',
      title: 'Gadget Terbaru',
      subtitle: 'Diskon hingga 50%',
      color: AppColors.primary,
    ),
    BannerData(
      imagePath: 'lib/images/clothes-banner.webp',
      title: 'Fashion Update',
      subtitle: 'Koleksi terkini untuk Anda',
      color: AppColors.secondary,
    ),
    BannerData(
      imagePath: 'lib/images/shoes-banner.webp',
      title: 'Sepatu Pilihan',
      subtitle: 'Gratis ongkir min. Rp 100.000',
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return _BannerItem(banner: banners[index]);
            },
          ),
        ),
        _BannerIndicator(
          count: banners.length,
          currentIndex: currentIndex,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final BannerData banner;

  const _BannerItem({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              banner.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        banner.color,
                        banner.color.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                      child: Icon(Icons.image, color: Colors.white, size: 50)),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PROMO',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      banner.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      banner.subtitle,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _BannerIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? AppColors.primary
                : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}