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
        textColor: Colors.white
      );
      setState(() => isAdding = false);
      
    }else {
      try {
        final response = await http.post(
          Uri.parse("${ApiConstants.baseUrl}/cart"),
          headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
          body: jsonEncode({"productId": widget.product.id, "quantity": 1}),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Berhasil masuk keranjang!", backgroundColor: Colors.green, textColor: Colors.white);
        } else {
          Fluttertoast.showToast(msg: "Gagal tambah barang", backgroundColor: Colors.red, textColor: Colors.white);
        }
      } catch (e) {
        print(e);
      } finally {
        setState(() => isAdding = false);
      }
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/cart"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"productId": widget.product.id, "quantity": 1}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masuk Keranjang!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal tambah")));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Column(
        children: [
          Image.network(widget.product.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.error, size: 100)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(formatter.format(widget.product.price), style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.product.description),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAdding ? null : addToCart,
                child: isAdding ? const CircularProgressIndicator() : const Text("Tambah ke Keranjang"),
              ),
            ),
          )
        ],
      ),
    );
  }
}