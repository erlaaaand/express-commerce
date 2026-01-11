import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kadaierland/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:kadaierland/utils/api_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  final formatter = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp ', 
    decimalDigits: 0
  );

  @override
  void initState() {
    super.initState();
    getCart();
  }

  Future<void> getCart() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/cart"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      Fluttertoast.showToast(
        msg: "Silakan Login untuk Checkout",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT
      );
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage())
      );
      return;
    }

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/orders/checkout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"shippingAddress": "Alamat default"}),
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Checkout Berhasil!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT
        );
        getCart();
      } else {
        Fluttertoast.showToast(
          msg: "Gagal Checkout",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT
      );
    }
  }

  int getTotalPrice() {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Keranjang Belanja"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined, 
                        size: 100, 
                        color: Colors.grey[400]
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Keranjang Masih Kosong",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600]
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Yuk, mulai belanja!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500]
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2)
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Gambar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imageUrl'] ?? '', 
                                      width: 70, 
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image, 
                                          color: Colors.grey
                                        ),
                                      )
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Info Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['productName'] ?? 'Produk',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          formatter.format(item['price'] ?? 0),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Jumlah: ${item['quantity']}x",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Tombol Delete
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline, 
                                      color: Colors.red,
                                      size: 24
                                    ),
                                    onPressed: () {
                                      // TODO: Implementasi delete item
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Hapus Item"),
                                          content: const Text(
                                            "Fitur hapus item sedang dalam pengembangan"
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Bottom Section - Total & Checkout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -3)
                          )
                        ]
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Total Harga
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Belanja:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                Text(
                                  formatter.format(getTotalPrice()),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Tombol Checkout
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: cartItems.isEmpty ? null : checkout,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.payment, 
                                      color: Colors.white,
                                      size: 20
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Checkout Sekarang",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}