import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../home/home_page.dart';
import 'models/onboarding_data.dart';
import 'widgets/onboarding_skip_button.dart';
import 'widgets/onboarding_content.dart';
import 'widgets/onboarding_indicator.dart';
import 'widgets/onboarding_navigation.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'lib/images/gadget-onboarding.webp',
      title: 'Gadget & Elektronik',
      description: 'Temukan berbagai gadget dan elektronik terbaru dengan harga terbaik',
      color: AppColors.primary,
    ),
    OnboardingData(
      imagePath: 'lib/images/male-clothes-onboarding.webp',
      title: 'Fashion Pria',
      description: 'Koleksi fashion terlengkap untuk gaya hidup modern Anda',
      color: AppColors.secondary,
    ),
    OnboardingData(
      imagePath: 'lib/images/male-shoes-onboarding.webp',
      title: 'Sepatu & Aksesoris',
      description: 'Berbagai pilihan sepatu berkualitas untuk aktivitas sehari-hari',
      color: AppColors.accent,
    ),
    OnboardingData(
      imagePath: 'lib/images/female-shoes-onboarding.webp',
      title: 'Sepatu & Aksesoris',
      description: 'Berbagai pilihan sepatu berkualitas untuk aktivitas sehari-hari',
      color: AppColors.accent,
    ),
    OnboardingData(
      imagePath: 'lib/images/female-clothes-onboarding.webp',
      title: 'Fashion Wanita',
      description: 'Berbagai pilihan sepatu berkualitas untuk aktivitas sehari-hari',
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingSkipButton(onPressed: _navigateToHome),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(data: _pages[index]);
                },
              ),
            ),
            OnboardingIndicator(
              currentPage: _currentPage,
              pageCount: _pages.length,
            ),
            const SizedBox(height: 40),
            OnboardingNavigation(
              currentPage: _currentPage,
              pageCount: _pages.length,
              onPrevious: _previousPage,
              onNext: _nextPage,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}