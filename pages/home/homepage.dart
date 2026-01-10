import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import Toast
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
  // --- STATE VARIABLES ---
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

  // --- CEK STATUS USER (Login/Guest) ---
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

  // --- LOGIC BOTTOM NAVBAR ---
  void _onItemTapped(int index) {
    if (index == 1) {
      // Jika klik Profile
      if (isLogin) {
        // Tampilkan Dialog Logout atau Halaman Profil Sederhana
        _showProfileDialog();
      } else {
        // Jika Guest, lempar ke Login
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
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            children: [
              const Icon(Icons.account_circle, size: 60, color: Colors.blue),
              const SizedBox(height: 10),
              Text("Halo, $username", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); // Hapus Token
                    Navigator.pop(context); // Tutup Dialog
                    // Refresh Halaman jadi Guest
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
                  },
                  child: const Text("Logout", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- BANNER SLIDER ---
  void bannerOnBoarding() {
    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          indexBanner = (indexBanner < bannerImage.length - 1) ? indexBanner + 1 : 0;
        });
        if (bannerController.hasClients) {
          bannerController.animateToPage(indexBanner, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  // --- API PRODUCT ---
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

  // --- WIDGET CATEGORY CARD (FIXED WIDTH) ---
  Widget _buildCategoryCard({required String imagePath, required String label, required String categoryCode}) {
    // Menggunakan Expanded agar membagi rata lebar layar (Tidak dempet/nabrak)
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductGridPage(category: categoryCode, pageTitle: label)));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
              ),
              child: Image.asset(imagePath, width: 30, height: 30, fit: BoxFit.contain),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background sedikit abu biar konten nonjol
      
      // --- APP BAR ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: searchProduct,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Cari barang...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            InkWell(
              onTap: () {
                // Cart bisa diakses Guest, tapi checkout nanti dicek
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
              },
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            
            // 1. BANNER SLIDER
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: bannerController,
                itemCount: bannerImage.length,
                onPageChanged: (index) => setState(() => indexBanner = index),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(image: AssetImage(bannerImage[index]), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            // Indikator Titik
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerImage.length, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indexBanner == index ? Colors.blue : Colors.grey[300],
                ),
              )),
            ),

            const SizedBox(height: 20),

            // 2. KATEGORI (FIXED ROW - TIDAK BISA DISLIDE)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            
            // Menggunakan Padding dan Row + Expanded agar rapi dan fixed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Bagi jarak rata
                children: [
                  _buildCategoryCard(imagePath: "lib/images/gadgets-vector.png", label: "Gadget", categoryCode: "Electronic"),
                  _buildCategoryCard(imagePath: "lib/images/male-clothes-vector.png", label: "Baju Pria", categoryCode: "MenClothes"),
                  _buildCategoryCard(imagePath: "lib/images/female-clothes-vector.png", label: "Baju Wanita", categoryCode: "WomenClothes"),
                  _buildCategoryCard(imagePath: "lib/images/male-shoes-vector.png", label: "Sepatu Pria", categoryCode: "ManShoes"),
                  _buildCategoryCard(imagePath: "lib/images/female-shoes-vector.png", label: "Sepatu Wanita", categoryCode: "WomenShoes")
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("Rekomendasi Untukmu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            
            Padding(
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
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

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // --- WIDGET CARD PRODUK ---
  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(formatter.format(product.price), style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Stok: ${product.stock}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}