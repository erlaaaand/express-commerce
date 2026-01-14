import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_product_grid.dart';
import 'widgets/home_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    Future.microtask(() {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  void _onBannerPageChanged(int index) {
    setState(() => _currentBannerIndex = index);
  }

  void _onItemTapped(int index) {
    final authProvider = context.read<AuthProvider>();

    if (index == 1 && !authProvider.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      ).then((_) {
        setState(() {});
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        const HomeAppBar(),
        SliverToBoxAdapter(
          child: HomeBanner(
            controller: _bannerController,
            currentIndex: _currentBannerIndex,
            onPageChanged: _onBannerPageChanged,
          ),
        ),
        const SliverToBoxAdapter(child: HomeCategories()),
        HomeProductGrid(onRefresh: _loadProducts),
      ],
    );
  }
}