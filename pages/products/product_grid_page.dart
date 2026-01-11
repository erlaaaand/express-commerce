import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:kadaierland/models/product_model.dart';
import 'package:kadaierland/pages/products/product_detail_page.dart';
import 'package:kadaierland/utils/api_constants.dart';

class ProductGridPage extends StatefulWidget {
  final String category;
  final String pageTitle;

  const ProductGridPage({
    super.key, 
    required this.category, 
    required this.pageTitle
  });

  @override
  State<ProductGridPage> createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  
  final formatter = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp ', 
    decimalDigits: 0
  );
  
  String sortBy = 'name'; // name, price_low, price_high
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/products")
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((e) => ProductModel.fromJson(e)).toList();
          filteredProducts = products;
          applySorting();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      applySorting();
    });
  }

  void applySorting() {
    setState(() {
      if (sortBy == 'price_low') {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortBy == 'price_high') {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      } else {
        filteredProducts.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Urutkan Berdasarkan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Nama Produk"),
                trailing: sortBy == 'name' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
                onTap: () {
                  setState(() => sortBy = 'name');
                  applySorting();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text("Harga Terendah"),
                trailing: sortBy == 'price_low' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
                onTap: () {
                  setState(() => sortBy = 'price_low');
                  applySorting();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text("Harga Tertinggi"),
                trailing: sortBy == 'price_high' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
                onTap: () {
                  setState(() => sortBy = 'price_high');
                  applySorting();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.pageTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: showSortOptions,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Product Count
          if (!isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${filteredProducts.length} produk ditemukan",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: showSortOptions,
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          sortBy == 'name' 
                            ? 'Nama' 
                            : sortBy == 'price_low' 
                              ? 'Termurah' 
                              : 'Termahal',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Product Grid
          Expanded(
            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredProducts.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off, 
                          size: 80, 
                          color: Colors.grey[400]
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Produk tidak ditemukan",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.68, 
                      mainAxisSpacing: 16, 
                      crossAxisSpacing: 16
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final item = filteredProducts[index];
                      return _buildProductCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product)
          )
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)
                    ),
                    child: Image.network(
                      product.imageUrl, 
                      fit: BoxFit.cover, 
                      width: double.infinity, 
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image, 
                            size: 50, 
                            color: Colors.grey
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
                          vertical: 4
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Terbatas",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Info
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
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    )
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatter.format(product.price), 
                    style: const TextStyle(
                      color: Colors.blue, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}