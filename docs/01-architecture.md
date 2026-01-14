# 📐 Arsitektur & Struktur Proyek

## 1. Clean Architecture

### Apa itu Clean Architecture?
Clean Architecture adalah pendekatan arsitektur software yang memisahkan kode menjadi layer-layer independen. Tujuannya:
- **Separation of Concerns**: Setiap layer punya tanggung jawab spesifik
- **Testability**: Mudah untuk testing karena loosely coupled
- **Maintainability**: Mudah dimodifikasi tanpa mempengaruhi layer lain
- **Scalability**: Mudah dikembangkan seiring bertambahnya fitur

### Layer-Layer dalam Proyek

```
┌─────────────────────────────────────────┐
│       PRESENTATION LAYER                │
│   (UI, Pages, Widgets, Providers)       │
├─────────────────────────────────────────┤
│         DOMAIN LAYER                    │
│      (Use Cases, Business Logic)        │
├─────────────────────────────────────────┤
│          DATA LAYER                     │
│   (Models, Repositories, Services)      │
├─────────────────────────────────────────┤
│          CORE LAYER                     │
│  (Constants, Utils, Base Widgets)       │
└─────────────────────────────────────────┘
```

## 2. Struktur Folder Proyek

```
lib/
├── core/                          # Layer Core
│   ├── constants/                 # Konstanta aplikasi
│   │   ├── api_constants.dart    # URL endpoints
│   │   ├── app_colors.dart       # Warna tema
│   │   └── app_theme.dart        # Tema aplikasi
│   ├── utils/                     # Utility functions
│   │   ├── currency_formatter.dart
│   │   ├── image_helper.dart
│   │   └── validators.dart
│   └── widgets/                   # Reusable widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── empty_state.dart
│       ├── loading_widget.dart
│       └── product_card.dart
│
├── data/                          # Layer Data
│   ├── models/                    # Data models
│   │   ├── cart_model.dart
│   │   ├── order_model.dart
│   │   ├── payment_model.dart
│   │   ├── product_model.dart
│   │   └── user_model.dart
│   ├── repositories/              # Repository implementations
│   │   ├── auth_repository.dart
│   │   ├── cart_repository.dart
│   │   ├── order_repository.dart
│   │   ├── payment_repository.dart
│   │   └── product_repository.dart
│   └── services/                  # External services
│       ├── api_service.dart       # HTTP client
│       └── storage_service.dart   # Local storage
│
├── domain/                        # Layer Domain
│   └── usecases/                  # Business logic
│       ├── auth_usecase.dart
│       ├── cart_usecase.dart
│       ├── order_usecase.dart
│       ├── payment_usecase.dart
│       └── product_usecase.dart
│
├── presentation/                  # Layer Presentation
│   ├── pages/                     # Halaman aplikasi
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── cart/
│   │   │   └── cart_page.dart
│   │   ├── checkout/
│   │   │   └── checkout_page.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   ├── orders/
│   │   │   └── order_history_page.dart
│   │   ├── payment/
│   │   │   ├── payment_page.dart
│   │   │   └── payment_status_page.dart
│   │   ├── products/
│   │   │   ├── product_detail_page.dart
│   │   │   └── product_list_page.dart
│   │   ├── profile/
│   │   │   └── profile_page.dart
│   │   ├── splash/
│   │   │   └── splash_page.dart
│   │   └── onboarding/
│   │       └── onboarding_page.dart
│   └── providers/                 # State management
│       ├── auth_provider.dart
│       ├── cart_provider.dart
│       ├── order_provider.dart
│       ├── payment_provider.dart
│       └── product_provider.dart
│
└── main.dart                      # Entry point aplikasi
```

## 3. Penjelasan Detail Setiap Layer

### A. Core Layer (Foundation)
**Tanggung Jawab**: Menyediakan komponen dasar yang digunakan di seluruh aplikasi

#### 1. Constants
- **api_constants.dart**: Menyimpan semua URL endpoint API
- **app_colors.dart**: Definisi warna tema aplikasi
- **app_theme.dart**: Konfigurasi tema Material Design

```dart
// Contoh: API Constants
class ApiConstants {
  static const String baseUrl = 'https://...';
  static const String login = '$baseUrl/api/auth/login';
  // ... endpoints lainnya
}
```

#### 2. Utils
- **currency_formatter.dart**: Format mata uang Rupiah
- **image_helper.dart**: Helper untuk load gambar (network/local)
- **validators.dart**: Validasi form (email, password, dll)

#### 3. Widgets
Custom widget yang reusable:
- **CustomButton**: Button dengan loading state
- **CustomTextField**: TextField dengan styling konsisten
- **EmptyState**: UI untuk state kosong
- **LoadingWidget**: Indikator loading
- **ProductCard**: Card untuk menampilkan produk

---

### B. Data Layer (Data Management)
**Tanggung Jawab**: Menghandle semua operasi data (API calls, local storage)

#### 1. Models
Class yang merepresentasikan struktur data:
```dart
class ProductModel {
  final String id;
  final String name;
  final int price;
  // ... properties lainnya
  
  // Dari JSON (API response)
  factory ProductModel.fromJson(Map<String, dynamic> json) { ... }
  
  // Ke JSON (API request)
  Map<String, dynamic> toJson() { ... }
}
```

**Models yang ada**:
- `UserModel`: Data user (id, username, email)
- `ProductModel`: Data produk
- `CartModel` & `CartItemModel`: Data keranjang belanja
- `OrderModel` & `OrderItemModel`: Data pesanan
- `PaymentModel`: Data pembayaran

#### 2. Repositories
Menghandle logika komunikasi dengan data source (API/Storage):

```dart
class ProductRepository {
  final ApiService _apiService;
  
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiService.get('/products');
    // Convert response to models
  }
}
```

**Repositories yang ada**:
- `AuthRepository`: Login, register, logout
- `ProductRepository`: CRUD produk
- `CartRepository`: Kelola keranjang
- `OrderRepository`: Checkout, riwayat pesanan
- `PaymentRepository`: Proses pembayaran

#### 3. Services
Service untuk komunikasi eksternal:

**ApiService**: HTTP client untuk semua API calls
```dart
class ApiService {
  Future<Map<String, dynamic>> get(String endpoint) { ... }
  Future<Map<String, dynamic>> post(String endpoint, Map data) { ... }
  // PUT, PATCH, DELETE
}
```

**StorageService**: Local storage menggunakan SharedPreferences
```dart
class StorageService {
  Future<void> saveToken(String token) { ... }
  Future<String?> getToken() { ... }
  // Save/get user data, cart, dll
}
```

---

### C. Domain Layer (Business Logic)
**Tanggung Jawab**: Menghandle business rules dan validasi

#### Use Cases
Berisi logika bisnis aplikasi. Contoh:

```dart
class CartUseCase {
  final CartRepository _repository;
  
  Future<CartModel> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    // Validasi
    if (quantity <= 0) {
      throw Exception('Jumlah harus > 0');
    }
    if (quantity > 99) {
      throw Exception('Maksimal 99');
    }
    
    // Call repository
    return await _repository.addToCart(...);
  }
  
  bool validateCartForCheckout(CartModel cart) {
    if (cart.totalAmount < 10000) {
      throw Exception('Minimum Rp 10.000');
    }
    return true;
  }
}
```

**Use Cases yang ada**:
- `AuthUseCase`: Validasi login/register
- `ProductUseCase`: Filter, sort produk
- `CartUseCase`: Validasi keranjang
- `OrderUseCase`: Logika checkout
- `PaymentUseCase`: Validasi pembayaran

---

### D. Presentation Layer (UI & State)
**Tanggung Jawab**: Menampilkan UI dan menghandle state

#### 1. Pages
Halaman-halaman aplikasi:
- **Splash & Onboarding**: Intro aplikasi
- **Auth Pages**: Login, register
- **Home**: Dashboard dengan list produk
- **Product Pages**: Detail, list per kategori
- **Cart**: Keranjang belanja
- **Checkout**: Proses checkout
- **Payment**: Pembayaran via webview
- **Orders**: Riwayat pesanan
- **Profile**: Info user

#### 2. Providers (State Management)
Menggunakan **Provider** pattern dengan `ChangeNotifier`:

```dart
class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners(); // Update UI
    
    _products = await _repository.getProducts();
    
    _isLoading = false;
    notifyListeners(); // Update UI
  }
}
```

**Providers yang ada**:
- `AuthProvider`: State autentikasi
- `ProductProvider`: State produk
- `CartProvider`: State keranjang
- `OrderProvider`: State pesanan
- `PaymentProvider`: State pembayaran

---

## 4. Dependency Flow

```
UI/Pages
   ↓ (menggunakan)
Providers
   ↓ (menggunakan)
Use Cases
   ↓ (menggunakan)
Repositories
   ↓ (menggunakan)
Services (API/Storage)
```

**Contoh Flow Lengkap**:
```
LoginPage 
  → AuthProvider.login()
    → AuthUseCase.login() (validasi)
      → AuthRepository.login()
        → ApiService.post('/login')
          → HTTP Request ke Backend
```

## 5. Keuntungan Arsitektur Ini

### ✅ Separation of Concerns
Setiap layer punya tanggung jawab jelas:
- UI tidak perlu tahu detail API
- Repository tidak perlu tahu detail UI
- Business logic terisolasi di Use Cases

### ✅ Testability
Mudah untuk unit testing karena:
- Mock repositories untuk test use cases
- Mock use cases untuk test providers
- Isolated testing per layer

### ✅ Maintainability
Mudah maintenance karena:
- Perubahan UI tidak affect business logic
- Perubahan API hanya di repository
- Reusable components

### ✅ Scalability
Mudah scale aplikasi:
- Tambah fitur baru tanpa refactor besar
- Tambah data source baru (API lain, local DB)
- Team bisa kerja parallel per layer

## 6. Best Practices yang Diterapkan

1. **Single Responsibility**: Setiap class punya 1 tanggung jawab
2. **DRY (Don't Repeat Yourself)**: Reusable widgets & functions
3. **Consistent Naming**: Penamaan yang konsisten
4. **Error Handling**: Try-catch di setiap async operation
5. **Loading States**: Feedback visual untuk user
6. **Null Safety**: Dart null safety enabled

---

## 📌 Poin Penting untuk Ujian

**Q: Kenapa menggunakan Clean Architecture?**  
A: Untuk separation of concerns, testability, maintainability, dan scalability

**Q: Apa perbedaan Repository dan Use Case?**  
A: 
- Repository: Komunikasi dengan data source (API/DB)
- Use Case: Business logic dan validasi

**Q: Kenapa pakai Provider untuk state management?**  
A: Simple, powerful, recommended oleh Flutter team, dan cocok untuk aplikasi medium-scale

**Q: Bagaimana alur dari UI ke Backend?**  
A: Page → Provider → Use Case → Repository → Service → Backend

---

[← Kembali ke README](../README.md) | [Selanjutnya: Alur Data →](02-data-flow.md)