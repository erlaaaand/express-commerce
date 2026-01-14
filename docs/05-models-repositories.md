# 📦 Models & Repositories

## 1. Data Models

### A. UserModel
**File**: `data/models/user_model.dart`

**Purpose**: Merepresentasikan data user

**Properties**:
```dart
class UserModel {
  final String id;          // User ID dari backend
  final String username;    // Username
  final String email;       // Email address
  final bool isActive;      // Status akun
}
```

**Methods**:
```dart
// Parse dari JSON response
factory UserModel.fromJson(Map<String, dynamic> json)

// Convert ke JSON untuk request
Map<String, dynamic> toJson()

// Create copy dengan beberapa field diubah
UserModel copyWith({...})
```

**Contoh Usage**:
```dart
// Parse response
final user = UserModel.fromJson(responseData);

// Access properties
print(user.username);
print(user.email);
```

---

### B. ProductModel
**File**: `data/models/product_model.dart`

**Purpose**: Merepresentasikan data produk

**Properties**:
```dart
class ProductModel {
  final String id;           // Product ID
  final String name;         // Nama produk
  final String description;  // Deskripsi
  final int price;           // Harga normal
  final int promoPrice;      // Harga promo (0 jika tidak ada)
  final String imageUrl;     // URL gambar
  final String category;     // Kategori
  final int stock;           // Stok tersedia
  final String vendor;       // Nama vendor/toko
}
```

**Computed Properties** (Getters):
```dart
bool get hasPromo => promoPrice > 0 && promoPrice < price;
int get effectivePrice => hasPromo ? promoPrice : price;
bool get isOutOfStock => stock <= 0;
bool get isLowStock => stock > 0 && stock <= 10;
```

**Contoh Usage**:
```dart
final product = ProductModel.fromJson(json);

// Check jika ada promo
if (product.hasPromo) {
  print('Diskon: ${product.price - product.promoPrice}');
}

// Get harga final
print('Harga: ${product.effectivePrice}');

// Check stok
if (product.isOutOfStock) {
  print('Stok habis!');
} else if (product.isLowStock) {
  print('Stok terbatas!');
}
```

---

### C. CartModel & CartItemModel
**File**: `data/models/cart_model.dart`

**Purpose**: Merepresentasikan keranjang belanja

**CartItemModel** (Single item dalam cart):
```dart
class CartItemModel {
  final String productId;      // ID produk
  final String productName;    // Nama produk
  final int price;             // Harga satuan
  final int quantity;          // Jumlah
  final String imageUrl;       // URL gambar
  
  // Computed property
  int get subtotal => price * quantity;
}
```

**CartModel** (Keseluruhan cart):
```dart
class CartModel {
  final String id;                    // Cart ID
  final String userId;                // User ID
  final List<CartItemModel> items;   // List items
  final DateTime updatedAt;          // Last update
  
  // Computed properties
  int get itemCount => items.length;
  int get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => items.isEmpty;
}
```

**Contoh Usage**:
```dart
final cart = CartModel.fromJson(json);

// Get total items
print('Jumlah item: ${cart.itemCount}');

// Get total harga
print('Total: ${CurrencyFormatter.format(cart.totalAmount)}');

// Loop items
for (var item in cart.items) {
  print('${item.productName}: ${item.quantity} x ${item.price}');
}
```

---

### D. OrderModel & OrderItemModel
**File**: `data/models/order_model.dart`

**Purpose**: Merepresentasikan pesanan

**OrderItemModel**:
```dart
class OrderItemModel {
  final String productId;
  final String productName;
  final int priceAtPurchase;   // Harga saat dibeli
  final int quantity;
  final String imageUrl;
  
  int get subtotal => priceAtPurchase * quantity;
}
```

**OrderModel**:
```dart
class OrderModel {
  final String id;                    // Order ID (MongoDB _id)
  final String orderId;               // Order ID (readable)
  final String userId;                // User ID
  final List<OrderItemModel> items;  // Items yang dibeli
  final int totalAmount;             // Total pembayaran
  final String status;               // Status pesanan
  final String shippingAddress;      // Alamat pengiriman
  final String? paymentToken;        // Token Midtrans
  final String? paymentUrl;          // URL Midtrans
  final DateTime createdAt;          // Tanggal order
  
  // Status checks
  bool get isPending => status == 'Pending';
  bool get isPaid => status == 'Paid';
  bool get isShipped => status == 'Shipped';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';
  bool get canBeCancelled => isPending;
}
```

**Order Status Flow**:
```
Pending → Paid → Shipped → Completed
    ↓
Cancelled (hanya dari Pending)
```

---

### E. PaymentModel
**File**: `data/models/payment_model.dart`

**Purpose**: Merepresentasikan data pembayaran

**Properties**:
```dart
class PaymentModel {
  final String orderId;          // Order ID
  final String paymentToken;     // Token Midtrans
  final String paymentUrl;       // URL pembayaran
  final int amount;              // Jumlah yang dibayar
  final String status;           // Status payment
  final DateTime createdAt;      // Tanggal dibuat
  final DateTime? paidAt;        // Tanggal dibayar
  final String? transactionId;   // ID transaksi Midtrans
  final String? paymentType;     // Tipe pembayaran
  
  // Status checks
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isSuccess => ['success', 'settlement', 'capture']
                        .contains(status.toLowerCase());
  bool get isFailed => ['failed', 'deny', 'cancel', 'expire']
                       .contains(status.toLowerCase());
}
```

---

## 2. Repositories

### A. AuthRepository
**File**: `data/repositories/auth_repository.dart`

**Purpose**: Handle authentication operations

**Methods**:

1. **register()**
```dart
Future<UserModel> register({
  required String username,
  required String email,
  required String password,
})

// POST /api/auth/register
// Returns: UserModel
```

2. **login()**
```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
})

// POST /api/auth/login
// Returns: {token, username, userId}
// Side effect: Save token & user data to storage
```

3. **getProfile()**
```dart
Future<UserModel> getProfile()

// GET /api/auth/profile (authenticated)
// Returns: UserModel
```

4. **logout()**
```dart
Future<void> logout()

// Clear all data from storage
// No API call needed
```

5. **isLoggedIn()**
```dart
Future<bool> isLoggedIn()

// Check if token exists in storage
// Returns: bool
```

---

### B. ProductRepository
**File**: `data/repositories/product_repository.dart`

**Purpose**: Handle product operations

**Methods**:

1. **getProducts()**
```dart
Future<List<ProductModel>> getProducts()

// GET /api/products
// Returns: List of all products
```

2. **getProductsByCategory()**
```dart
Future<List<ProductModel>> getProductsByCategory(String category)

// GET /api/products?category={category}
// Returns: List of products in category
```

3. **getProductById()**
```dart
Future<ProductModel> getProductById(String productId)

// GET /api/products/{id}
// Returns: Single product
```

4. **searchProducts()**
```dart
Future<List<ProductModel>> searchProducts(String query)

// GET /api/products?search={query}
// Returns: List of matching products
```

---

### C. CartRepository
**File**: `data/repositories/cart_repository.dart`

**Purpose**: Handle cart operations

**Methods**:

1. **getCart()**
```dart
Future<CartModel> getCart()

// GET /api/cart (authenticated)
// Returns: User's cart
```

2. **addToCart()**
```dart
Future<CartModel> addToCart({
  required String productId,
  int quantity = 1,
})

// POST /api/cart
// Body: {productId, quantity}
// Returns: Updated cart
```

3. **updateQuantity()**
```dart
Future<CartModel> updateQuantity({
  required String productId,
  required int quantity,
})

// PATCH /api/cart/{productId}
// Body: {quantity}
// Returns: Updated cart
```

4. **removeFromCart()**
```dart
Future<CartModel> removeFromCart(String productId)

// DELETE /api/cart/{productId}
// Returns: Updated cart
```

5. **clearCart()**
```dart
Future<CartModel> clearCart()

// DELETE /api/cart
// Returns: Empty cart
```

6. **syncLocalCart()** (Special)
```dart
Future<void> syncLocalCart()

// Get items from local storage
// Add each item to backend cart
// Clear local storage
// Use case: After login, sync guest cart
```

---

### D. OrderRepository
**File**: `data/repositories/order_repository.dart`

**Purpose**: Handle order operations

**Methods**:

1. **checkout()**
```dart
Future<Map<String, dynamic>> checkout({
  required String shippingAddress,
})

// POST /api/orders/checkout
// Body: {shippingAddress}
// Returns: {orderId, paymentUrl, paymentToken, totalAmount}
// Backend creates order, clears cart, creates payment
```

2. **getOrders()**
```dart
Future<List<OrderModel>> getOrders()

// GET /api/orders (authenticated)
// Returns: List of user's orders
```

3. **getOrderById()**
```dart
Future<OrderModel> getOrderById(String orderId)

// GET /api/orders/{orderId}
// Returns: Single order detail
```

4. **cancelOrder()**
```dart
Future<OrderModel> cancelOrder(String orderId)

// POST /api/orders/{orderId}/cancel
// Returns: Updated order with status 'Cancelled'
// Only works if order status is 'Pending'
```

5. **checkPaymentStatus()**
```dart
Future<Map<String, dynamic>> checkPaymentStatus(String orderId)

// GET /api/payment/status/{orderId}
// Returns: Payment status info
```

---

### E. PaymentRepository
**File**: `data/repositories/payment_repository.dart`

**Purpose**: Handle payment operations

**Methods**:

1. **processPayment()**
```dart
Future<PaymentModel> processPayment({
  required String orderId,
})

// POST /api/payment
// Body: {orderId}
// Returns: Payment info with URL
```

2. **checkPaymentStatus()**
```dart
Future<PaymentModel> checkPaymentStatus(String orderId)

// GET /api/payment/status/{orderId}
// Returns: Current payment status
```

3. **cancelPayment()**
```dart
Future<void> cancelPayment(String orderId)

// POST /api/payment/{orderId}/cancel
// Cancel pending payment
```

---

## 3. Services

### A. ApiService
**File**: `data/services/api_service.dart`

**Purpose**: HTTP client untuk semua API calls

**Methods**:
```dart
// GET request
Future<Map<String, dynamic>> get(
  String endpoint,
  {bool requiresAuth = false}
)

// POST request
Future<Map<String, dynamic>> post(
  String endpoint,
  Map<String, dynamic> body,
  {bool requiresAuth = false}
)

// PUT request
Future<Map<String, dynamic>> put(
  String endpoint,
  Map<String, dynamic> body,
  {bool requiresAuth = false}
)

// PATCH request
Future<Map<String, dynamic>> patch(
  String endpoint,
  Map<String, dynamic> body,
  {bool requiresAuth = false}
)

// DELETE request
Future<Map<String, dynamic>> delete(
  String endpoint,
  {bool requiresAuth = false}
)
```

**Features**:
- Auto add headers (Content-Type, Authorization)
- Response handling (parse JSON)
- Error handling (status codes)
- Auto logout on 401

**Error Handling**:
```dart
// Status code handling
200-299: Success → return JSON
400: Bad request → throw error
401: Unauthorized → clear token & throw
404: Not found → throw error
500: Server error → throw error
```

---

### B. StorageService
**File**: `data/services/storage_service.dart`

**Purpose**: Local storage menggunakan SharedPreferences

**Methods**:

**Token Management**:
```dart
Future<void> saveToken(String token)
Future<String?> getToken()
Future<void> removeToken()
Future<bool> hasToken()
```

**User Data Management**:
```dart
Future<void> saveUserData(Map<String, dynamic> userData)
Future<Map<String, dynamic>?> getUserData()
Future<void> removeUserData()
```

**Local Cart** (untuk guest):
```dart
Future<void> saveLocalCart(List<String> cartItems)
Future<List<String>> getLocalCart()
Future<void> clearLocalCart()
Future<void> addToLocalCart(String productId)
```

**Clear All**:
```dart
Future<void> clearAll()  // Clear semua data
```

---

## 4. Use Cases (Business Logic)

### A. AuthUseCase
**File**: `domain/usecases/auth_usecase.dart`

**Purpose**: Business logic untuk authentication

**Validations**:
- Username: min 3 chars, alphanumeric + underscore
- Email: valid format
- Password: min 6 chars

**Methods**:
```dart
Future<UserModel> register(...)      // With validation
Future<Map<String, dynamic>> login(...)
Future<UserModel> getProfile()
Future<void> logout()
bool isValidUsername(String username)
bool isStrongPassword(String password)
PasswordStrength getPasswordStrength(String password)
```

---

### B. CartUseCase
**File**: `domain/usecases/cart_usecase.dart`

**Purpose**: Business logic untuk cart

**Validations**:
- Product ID tidak boleh kosong
- Quantity: 1-99
- Total amount min Rp 10.000 untuk checkout

**Methods**:
```dart
Future<CartModel> addToCart(...)
Future<CartModel> updateQuantity(...)
Future<CartModel> removeFromCart(...)
bool validateCartForCheckout(CartModel cart)
int calculateTotalPrice(List<CartItemModel> items)
bool isEligibleForFreeShipping(CartModel cart)
```

---

### C. ProductUseCase
**File**: `domain/usecases/product_usecase.dart`

**Purpose**: Business logic untuk products

**Features**:
- Sort products (by name, price, stock)
- Filter by price range
- Get products with promo
- Get available products (not out of stock)
- Calculate discount percentage
- Get recommendations

**Methods**:
```dart
Future<List<ProductModel>> getProducts()
List<ProductModel> sortProducts(...)
List<ProductModel> filterByPriceRange(...)
List<ProductModel> getProductsWithPromo(...)
int calculateDiscountPercentage(ProductModel product)
List<ProductModel> getRecommendations(...)
```

---

## 5. Repository Pattern Explained

### Kenapa Pakai Repository?

**Separation of Concerns**:
```
Provider ─────┐
UseCase  ─────┼─→ Repository ─→ ApiService/Storage
Other Layer ──┘
```

Repository adalah **abstraction layer** antara business logic dan data source.

**Keuntungan**:
1. **Decoupling**: Business logic tidak tahu detail API
2. **Testability**: Mudah mock repository untuk testing
3. **Flexibility**: Ganti data source tanpa ubah business logic
4. **Centralized**: Satu tempat untuk semua data operations

**Contoh**:
```dart
// ❌ Tanpa Repository (BAD)
class ProductProvider {
  Future<void> fetchProducts() async {
    // Direct API call di Provider
    final response = await http.get('$baseUrl/products');
    final json = jsonDecode(response.body);
    _products = json.map((e) => ProductModel.fromJson(e)).toList();
  }
}

// ✅ Dengan Repository (GOOD)
class ProductProvider {
  final ProductRepository _repository;
  
  Future<void> fetchProducts() async {
    // Provider tidak tahu detail API
    _products = await _repository.getProducts();
  }
}

class ProductRepository {
  final ApiService _apiService;
  
  Future<List<ProductModel>> getProducts() async {
    // Semua detail API di sini
    final response = await _apiService.get('/products');
    return (response['data'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }
}
```

---

## 📌 Poin Penting untuk Ujian

**Q: Apa fungsi Model?**  
A: Merepresentasikan struktur data, dengan method fromJson (parse API response) dan toJson (prepare API request).

**Q: Kenapa pakai Repository Pattern?**  
A: Untuk separation of concerns, testability, dan flexibility. Business logic tidak perlu tahu detail API.

**Q: Apa perbedaan Repository dan UseCase?**  
A:
- Repository: Komunikasi dengan data source (API/Storage)
- UseCase: Business logic dan validasi

**Q: Bagaimana flow dari Provider ke Backend?**  
A: Provider → UseCase → Repository → ApiService → HTTP Request → Backend

**Q: Apa yang disimpan di local storage?**  
A: 
- Token (untuk authentication)
- User data (untuk offline access)
- Local cart (untuk guest user)

**Q: Bagaimana handle multiple data sources?**  
A: Repository bisa combine data dari API dan local storage. Contoh: syncLocalCart() merge local cart dengan backend cart.

---

[← Fitur](04-features.md) | [README](../README.md) | [Use Cases →](06-use-cases.md)