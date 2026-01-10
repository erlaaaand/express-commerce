import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kadaierland/models/product_model.dart';
import 'package:kadaierland/pages/products/product_grid_page.dart';
import 'package:kadaierland/pages/products/product_detail_page.dart';
import 'package:kadaierland/pages/cart/cart_page.dart';
import 'package:kadaierland/pages/auth/login_page.dart';
import 'package:kadaierland/utils/api_constants.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String username = "Guest";
  bool isLogin = false;

  final TextEditingController searchProduct = TextEditingController();
  final PageController bannerController = PageController();
  
  List<ProductModel> listProduct = [];
  bool isLoading = true;
  Timer? bannerTimer;
  int indexBanner = 0;

  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<String> bannerImage = [
    'lib/images/gadget-banner.webp',
    'lib/images/clothes-banner.webp',
    'lib/images/shoes-banner.webp',
  ];

  @override
  void initState() {
    super.initState();
    checkUserStatus();
    getAllProductItems();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      bannerOnBoarding();
    });
  }

  @override
  void dispose() {
    bannerTimer?.cancel();
    bannerController.dispose();
    searchProduct.dispose();
    super.dispose();
  }

  void checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      if (token != null) {
        isLogin = true;
        username = prefs.getString('username') ?? "User";
      } else {
        isLogin = false;
        username = "Guest";
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      if (isLogin) {
        _showProfileDialog();
      } else {
        Fluttertoast.showToast(msg: "Silakan Login Terlebih Dahulu");
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showProfileDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(Icons.account_circle, size: 70, color: Colors.blue),
              const SizedBox(height: 15),
              Text(
                "Halo, $username", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 5),
              Text(
                "Selamat berbelanja!", 
                style: TextStyle(fontSize: 13, color: Colors.grey[600])
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!mounted) return;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const Homepage())
                    );
                  },
                  child: const Text(
                    "Logout", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void bannerOnBoarding() {
    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          indexBanner = (indexBanner < bannerImage.length - 1) ? indexBanner + 1 : 0;
        });
        if (bannerController.hasClients) {
          bannerController.animateToPage(
            indexBanner, 
            duration: const Duration(milliseconds: 500), 
            curve: Curves.easeInOut
          );
        }
      }
    });
  }

  Future<void> getAllProductItems() async {
    try {
      var response = await http.get(Uri.parse("${ApiConstants.baseUrl}/products"));
      if (response.statusCode == 200) {
        List<dynamic> decoded = jsonDecode(response.body);
        setState(() {
          listProduct = decoded.map((e) => ProductModel.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildCategoryCard({
    required String imagePath, 
    required String label, 
    required String categoryCode
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ProductGridPage(
                category: categoryCode, 
                pageTitle: label
              )
            )
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15), 
                    blurRadius: 8,
                    offset: const Offset(0, 2)
                  )
                ],
              ),
              child: Image.asset(
                imagePath, 
                width: 35, 
                height: 35, 
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.image_not_supported, 
                  size: 35, 
                  color: Colors.grey
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: const TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w600
              ), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: searchProduct,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                    hintText: 'Cari produk impianmu...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), 
                      borderSide: BorderSide.none
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const CartPage())
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.shopping_cart_outlined, 
                  color: Colors.white, 
                  size: 26
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            
            // Banner Slider
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: bannerController,
                itemCount: bannerImage.length,
                onPageChanged: (index) => setState(() => indexBanner = index),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3)
                        )
                      ],
                      image: DecorationImage(
                        image: AssetImage(bannerImage[index]), 
                        fit: BoxFit.cover
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImage.length, 
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: indexBanner == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: indexBanner == index ? Colors.blue : Colors.grey[300],
                  ),
                )
              ),
            ),

            const SizedBox(height: 25),

            // Kategori
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kategori Produk", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 17
                    )
                  ),
                  Text(
                    "Lihat Semua", 
                    style: TextStyle(
                      color: Colors.blue[700], 
                      fontSize: 13,
                      fontWeight: FontWeight.w600
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard(
                    imagePath: "lib/images/gadgets-vector.png", 
                    label: "Gadget", 
                    categoryCode: "Electronic"
                  ),
                  _buildCategoryCard(
                    imagePath: "lib/images/male-clothes-vector.png", 
                    label: "Baju Pria", 
                    categoryCode: "MenClothes"
                  ),
                  _buildCategoryCard(
                    imagePath: "lib/images/female-clothes-vector.png", 
                    label: "Baju Wanita", 
                    categoryCode: "WomenClothes"
                  ),
                  _buildCategoryCard(
                    imagePath: "lib/images/male-shoes-vector.png", 
                    label: "Sepatu Pria", 
                    categoryCode: "ManShoes"
                  ),
                  _buildCategoryCard(
                    imagePath: "lib/images/female-shoes-vector.png", 
                    label: "Sepatu Wanita", 
                    categoryCode: "WomenShoes"
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rekomendasi Untukmu", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 17
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3))
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          "HOT", 
                          style: TextStyle(
                            color: Colors.orange[700], 
                            fontSize: 11,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(),
                      )
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: listProduct.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(listProduct[index]);
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3)
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), 
              activeIcon: Icon(Icons.home),
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person),
              label: "Profile"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2))
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product)
            )
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl, 
                      width: double.infinity, 
                      fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image, 
                            color: Colors.grey, 
                            size: 50
                          )
                        ),
                      )
                    ),
                  ),
                  if (product.stock < 10)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Stok Terbatas",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w600,
                      height: 1.2
                    )
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatter.format(product.price), 
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.blue, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined, 
                        size: 12, 
                        color: Colors.grey[600]
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Stok: ${product.stock}", 
                        style: TextStyle(
                          fontSize: 11, 
                          color: Colors.grey[600]
                        )
                      ),
                    ],
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