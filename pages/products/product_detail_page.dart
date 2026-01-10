import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:kadaierland/models/product_model.dart';
import 'package:kadaierland/utils/api_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isAdding = false;

  Future<void> addToCart() async {
    setState(() => isAdding = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      List<String> localCart = prefs.getStringList('local_cart') ?? [];
      
      localCart.add("${widget.product.id}|1"); 
      await prefs.setStringList('local_cart', localCart);
      
      Fluttertoast.showToast(
        msg: "Disimpan di Keranjang (Offline)",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT
      );
      setState(() => isAdding = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/cart"),
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "productId": widget.product.id, 
          "quantity": 1
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Berhasil masuk keranjang!", 
          backgroundColor: Colors.green, 
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT
        );
      } else {
        Fluttertoast.showToast(
          msg: "Gagal tambah barang", 
          backgroundColor: Colors.red, 
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan", 
        backgroundColor: Colors.red, 
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT
      );
    } finally {
      setState(() => isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(fontSize: 16)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[100],
                    child: Image.network(
                      widget.product.imageUrl, 
                      fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image, 
                            size: 80, 
                            color: Colors.grey
                          )
                        ),
                      )
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Info Produk
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Produk
                        Text(
                          widget.product.name, 
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            height: 1.3
                          )
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Harga
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: 8
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer, 
                                color: Colors.blue, 
                                size: 18
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(widget.product.price), 
                                style: const TextStyle(
                                  fontSize: 22, 
                                  color: Colors.blue, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stok
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.product.stock > 10 
                              ? Colors.green[50] 
                              : Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.product.stock > 10 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3)
                            )
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined, 
                                size: 20,
                                color: widget.product.stock > 10 
                                  ? Colors.green[700]
                                  : Colors.orange[700]
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Stok tersedia: ${widget.product.stock} unit",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: widget.product.stock > 10 
                                    ? Colors.green[700]
                                    : Colors.orange[700]
                                ),
                              ),
                              if (widget.product.stock < 10) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Segera Habis!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Divider
                        const Divider(thickness: 1),
                        
                        const SizedBox(height: 16),
                        
                        // Deskripsi
                        const Text(
                          "Deskripsi Produk", 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Info Tambahan
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined, 
                                    size: 18, 
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "100% Produk Original",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700]
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined, 
                                    size: 18, 
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Gratis Ongkir (Min. Pembelian)",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700]
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tombol Add to Cart
          Container(
            padding: const EdgeInsets.all(16.0),
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
              child: SizedBox(
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
                  onPressed: isAdding ? null : addToCart,
                  child: isAdding 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_shopping_cart, 
                            color: Colors.white,
                            size: 20
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Tambah ke Keranjang",
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
            ),
          )
        ],
      ),
    );
  }
}