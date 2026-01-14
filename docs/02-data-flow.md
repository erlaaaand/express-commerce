# 🔄 Alur Data & State Management

## 1. Overview Alur Data

### Diagram Alur Data Umum
```
┌──────────────┐
│   UI/Page    │ ← User interaction
└──────┬───────┘
       │ 1. User action (tap button, input text)
       ↓
┌──────────────┐
│   Provider   │ ← State management
└──────┬───────┘
       │ 2. Call business logic
       ↓
┌──────────────┐
│   UseCase    │ ← Validation & business rules
└──────┬───────┘
       │ 3. Call data layer
       ↓
┌──────────────┐
│  Repository  │ ← Data orchestration
└──────┬───────┘
       │ 4. Make API call
       ↓
┌──────────────┐
│  ApiService  │ ← HTTP communication
└──────┬───────┘
       │ 5. HTTP Request
       ↓
┌──────────────┐
│   Backend    │ ← Express.js API
└──────┬───────┘
       │ 6. Response
       ↓
    (alur balik ke UI)
```

## 2. Provider Pattern (State Management)

### Apa itu Provider?
Provider adalah state management solution yang menggunakan `InheritedWidget` untuk propagate changes ke widget tree.

### Cara Kerja Provider

```dart
// 1. Buat Provider class dengan ChangeNotifier
class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  
  // Getter untuk UI
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  
  // Method untuk update state
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners(); // ← Trigger rebuild UI
    
    // Fetch data
    _products = await _repository.getProducts();
    
    _isLoading = false;
    notifyListeners(); // ← Trigger rebuild UI lagi
  }
}
```

```dart
// 2. Register Provider di main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // ... providers lainnya
      ],
      child: MyApp(),
    ),
  );
}
```

```dart
// 3. Consume Provider di UI
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: provider.products.length,
          itemBuilder: (ctx, index) {
            return ProductCard(product: provider.products[index]);
          },
        );
      },
    );
  }
}
```

### Kapan `notifyListeners()` Dipanggil?
- Setelah mengubah state internal (`_products`, `_isLoading`, dll)
- Agar UI yang listen provider bisa rebuild
- **JANGAN** panggil di dalam getter!

---

## 3. Alur Data Detail per Fitur

### A. Alur Login

```
┌─────────────────────────────────────────────────────┐
│ 1. USER INPUT                                       │
│    LoginPage: User input email & password           │
│    → Tap "Masuk" button                             │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 2. PROVIDER                                         │
│    AuthProvider.login(email, password)              │
│    → Set _isLoading = true                          │
│    → notifyListeners() → UI show loading            │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 3. USE CASE (Optional - ada di beberapa flow)      │
│    AuthUseCase.login()                              │
│    → Validasi email format                          │
│    → Validasi password length                       │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 4. REPOSITORY                                       │
│    AuthRepository.login(email, password)            │
│    → Prepare request body                           │
│    → Call ApiService                                │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 5. API SERVICE                                      │
│    ApiService.post('/api/auth/login', {email, pwd}) │
│    → Add headers (Content-Type: application/json)   │
│    → Send HTTP POST request                         │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 6. BACKEND API                                      │
│    Express.js: POST /api/auth/login                 │
│    → Validate credentials                           │
│    → Generate JWT token                             │
│    → Return response                                │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 7. RESPONSE HANDLING (ApiService)                  │
│    → Check status code (200 = success)              │
│    → Parse JSON response                            │
│    → Extract token & user data                      │
│    → Return to Repository                           │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 8. REPOSITORY                                       │
│    → Save token to StorageService                   │
│    → Save user data to StorageService               │
│    → Return user data to Provider                   │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 9. PROVIDER                                         │
│    → Set _user = UserModel.fromJson(response)       │
│    → Set _isLoading = false                         │
│    → notifyListeners() → UI updated                 │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│ 10. UI UPDATE                                       │
│     LoginPage: Listen to Provider                   │
│     → Success: Navigate to HomePage                 │
│     → Error: Show error message                     │
└─────────────────────────────────────────────────────┘
```

### Kode Implementasi Login Flow

```dart
// 1. UI Layer (LoginPage)
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.login(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
  
  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  } else {
    // Show error
    showToast(authProvider.errorMessage);
  }
}

// 2. Provider Layer
Future<bool> login({
  required String email,
  required String password,
}) async {
  try {
    _setLoading(true);
    _errorMessage = null;
    
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    
    _user = UserModel(
      id: result['userId'],
      username: result['username'],
      email: email,
    );
    
    _setLoading(false);
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _setLoading(false);
    return false;
  }
}

// 3. Repository Layer
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final response = await _apiService.post(
    ApiConstants.login,
    {'email': email, 'password': password},
  );
  
  String token = response['data']['token'];
  await _storageService.saveToken(token);
  
  return response['data'];
}

// 4. Service Layer
Future<Map<String, dynamic>> post(
  String endpoint,
  Map<String, dynamic> body,
) async {
  final response = await http.post(
    Uri.parse(endpoint),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  
  return _handleResponse(response);
}
```

---

### B. Alur Fetch Products

```
HomePage (initState)
  │
  ├─→ context.read<ProductProvider>().fetchProducts()
  │     │
  │     ├─→ ProductRepository.getProducts()
  │     │     │
  │     │     └─→ ApiService.get('/api/products')
  │     │           │
  │     │           └─→ HTTP GET → Backend
  │     │                 │
  │     │                 └─→ Response: [{product1}, {product2}, ...]
  │     │
  │     └─→ Convert JSON to List<ProductModel>
  │
  └─→ UI rebuilds dengan Consumer<ProductProvider>
        │
        └─→ Show GridView of products
```

---

### C. Alur Add to Cart

```
ProductDetailPage
  │ User tap "Tambah ke Keranjang"
  │
  ├─→ Check if user logged in (AuthProvider.isAuthenticated)
  │   │
  │   ├─→ NO → Show dialog "Login diperlukan"
  │   │          Navigate to LoginPage
  │   │
  │   └─→ YES → Continue
  │
  ├─→ CartProvider.addToCart(productId, quantity)
  │     │
  │     ├─→ CartUseCase.addToCart() ← Validation
  │     │     │ - Check quantity > 0
  │     │     │ - Check quantity <= 99
  │     │     │ - Check product ID valid
  │     │
  │     ├─→ CartRepository.addToCart(productId, quantity)
  │     │     │
  │     │     └─→ ApiService.post('/api/cart', {productId, quantity})
  │     │           │ Headers: Authorization: Bearer {token}
  │     │           │
  │     │           └─→ Backend: Add product to cart
  │     │                 │
  │     │                 └─→ Response: Updated cart data
  │     │
  │     └─→ Update _cart dengan data baru
  │           notifyListeners() → UI update
  │
  └─→ Show success toast
      "Berhasil ditambahkan ke keranjang!"
```

---

### D. Alur Checkout & Payment

```
CheckoutPage
  │ User fill shipping address
  │ User tap "Lanjut ke Pembayaran"
  │
  ├─→ Validate form (address min 10 chars)
  │
  ├─→ CartProvider.checkoutCart(shippingAddress)
  │     │
  │     ├─→ OrderRepository.checkout(shippingAddress)
  │     │     │
  │     │     └─→ ApiService.post('/api/orders/checkout', {address})
  │     │           │ Headers: Authorization: Bearer {token}
  │     │           │
  │     │           └─→ Backend:
  │     │                 1. Create order
  │     │                 2. Clear cart
  │     │                 3. Create payment (Midtrans)
  │     │                 4. Return payment URL
  │     │                 │
  │     │                 └─→ Response: {
  │     │                       orderId, 
  │     │                       paymentUrl,
  │     │                       totalAmount
  │     │                     }
  │     │
  │     └─→ Clear cart in provider
  │
  ├─→ Open WebView with paymentUrl
  │     │
  │     ├─→ User complete payment in Midtrans
  │     │
  │     └─→ WebView detect success URL
  │           → Close WebView
  │           → Show success dialog
  │
  └─→ Navigate to OrderHistoryPage
```

---

## 4. Error Handling Flow

### Alur Error Handling

```
API Call
  │
  ├─→ Try-Catch di Service Layer
  │     │
  │     ├─→ Network Error
  │     │     → throw Exception('Network error')
  │     │
  │     ├─→ HTTP Error (4xx, 5xx)
  │     │     → Parse error message from response
  │     │     → throw Exception(errorMessage)
  │     │
  │     └─→ Parse Error
  │           → throw Exception('Invalid response')
  │
  ├─→ Catch di Repository
  │     → Log error
  │     → Re-throw atau wrap dengan custom exception
  │
  ├─→ Catch di Provider
  │     → Set _errorMessage = error.toString()
  │     → Set _isLoading = false
  │     → notifyListeners()
  │
  └─→ UI menampilkan error
        ├─→ Toast message
        ├─→ Error dialog
        └─→ Error state widget
```

### Implementasi Error Handling

```dart
// ApiService - Handle HTTP errors
Map<String, dynamic> _handleResponse(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body);
  }
  
  // Error cases
  switch (response.statusCode) {
    case 400:
      throw Exception('Bad request');
    case 401:
      throw Exception('Email atau password salah');
    case 404:
      throw Exception('Resource not found');
    case 500:
      throw Exception('Server error');
    default:
      throw Exception('An error occurred');
  }
}

// Provider - Catch dan set error
Future<bool> addToCart({required String productId}) async {
  try {
    _setLoading(true);
    _errorMessage = null;
    
    _cart = await _repository.addToCart(productId);
    
    _setLoading(false);
    return true;
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    _setLoading(false);
    return false;
  }
}

// UI - Display error
if (provider.errorMessage != null) {
  Fluttertoast.showToast(
    msg: provider.errorMessage!,
    backgroundColor: AppColors.error,
  );
}
```

---

## 5. Loading States

### 3 State Utama di UI

```dart
// 1. Loading State
if (provider.isLoading) {
  return CircularProgressIndicator();
}

// 2. Empty State
if (provider.products.isEmpty) {
  return EmptyState(
    icon: Icons.inventory,
    title: 'Belum ada produk',
  );
}

// 3. Success State (Data Available)
return GridView.builder(
  itemCount: provider.products.length,
  itemBuilder: (ctx, i) => ProductCard(provider.products[i]),
);
```

---

## 6. Authentication Flow dengan Token

### Alur Token Management

```
Login
  │
  ├─→ Backend generate JWT token
  │
  ├─→ Frontend save token
  │     StorageService.saveToken(token)
  │     → SharedPreferences.setString('auth_token', token)
  │
  └─→ Future API calls include token
        ApiService dengan header:
        'Authorization': 'Bearer {token}'
```

### Implementasi

```dart
// 1. Save token after login
await _storageService.saveToken(token);

// 2. Get token untuk authenticated requests
Future<Map<String, String>> _getAuthHeaders() async {
  final token = await _storageService.getToken();
  
  if (token == null) {
    throw Exception('No authentication token');
  }
  
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

// 3. Use in API calls
Future<Map<String, dynamic>> get(
  String endpoint,
  {bool requiresAuth = false}
) async {
  final headers = requiresAuth 
    ? await _getAuthHeaders()
    : ApiConstants.defaultHeaders;
  
  final response = await http.get(
    Uri.parse(endpoint),
    headers: headers,
  );
  
  return _handleResponse(response);
}
```

---

## 📌 Poin Penting untuk Ujian

### Q: Jelaskan alur data dari UI sampai Backend!
A: 
1. UI trigger action (button click)
2. Provider method dipanggil
3. Provider call Use Case (validation)
4. Use Case call Repository
5. Repository call API Service
6. API Service send HTTP request ke Backend
7. Response kembali melalui chain yang sama
8. Provider update state dan notifyListeners()
9. UI rebuild otomatis

### Q: Kapan notifyListeners() dipanggil?
A: Setelah mengubah state internal (seperti `_products`, `_isLoading`) agar UI yang listen provider bisa rebuild.

### Q: Bagaimana error handling?
A: Try-catch di setiap layer:
- Service: Handle HTTP errors
- Repository: Log & re-throw
- Provider: Catch, set errorMessage, notify UI
- UI: Display error (toast/dialog)

### Q: Bagaimana authentication dengan token?
A: 
- Token disimpan di SharedPreferences setelah login
- Setiap authenticated request include header: `Authorization: Bearer {token}`
- Jika token invalid (401), user di-logout otomatis

---

[← Arsitektur](01-architecture.md) | [README](../README.md) | [Komponen →](03-components.md)