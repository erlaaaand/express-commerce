# 🧩 Komponen & Widget

## 1. Custom Widgets (Reusable Components)

### A. CustomButton
**Lokasi**: `core/widgets/custom_button.dart`

**Fungsi**: Button dengan berbagai state dan kustomisasi

**Properties**:
```dart
- text: String                 // Teks button
- onPressed: VoidCallback?     // Action saat di-tap
- isLoading: bool              // Show loading indicator
- icon: IconData?              // Optional icon
- backgroundColor: Color?      // Warna background
- textColor: Color?           // Warna teks
- width: double?              // Lebar button
- height: double              // Tinggi button
- isOutlined: bool            // Style outlined atau filled
```

**Penggunaan**:
```dart
// Filled button dengan loading
CustomButton(
  text: 'Masuk',
  onPressed: _handleLogin,
  isLoading: authProvider.isLoading,
  icon: Icons.login,
)

// Outlined button
CustomButton(
  text: 'Kembali',
  onPressed: () => Navigator.pop(context),
  isOutlined: true,
)
```

**Keuntungan**:
- Konsisten di seluruh aplikasi
- Handle loading state otomatis
- Disable button saat loading
- Support icon
- Support outlined style

---

### B. CustomTextField
**Lokasi**: `core/widgets/custom_text_field.dart`

**Fungsi**: Input field dengan styling konsisten

**Properties**:
```dart
- controller: TextEditingController?
- labelText: String?           // Label di atas field
- hintText: String?            // Placeholder text
- prefixIcon: IconData?        // Icon di kiri
- suffixIcon: Widget?          // Widget di kanan
- obscureText: bool            // Untuk password
- keyboardType: TextInputType  // Tipe keyboard
- validator: String? Function(String?)?  // Validasi
- onChanged: Function(String)?
- maxLines: int                // Jumlah baris
- enabled: bool                // Enable/disable
```

**Penggunaan**:
```dart
CustomTextField(
  controller: _emailController,
  labelText: 'Email',
  hintText: 'Masukkan email Anda',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.validateEmail,
)

// Password field
CustomTextField(
  controller: _passwordController,
  labelText: 'Password',
  obscureText: !_isPasswordVisible,
  suffixIcon: IconButton(
    icon: Icon(_isPasswordVisible 
      ? Icons.visibility 
      : Icons.visibility_off),
    onPressed: () {
      setState(() => _isPasswordVisible = !_isPasswordVisible);
    },
  ),
)
```

---

### C. ProductCard
**Lokasi**: `core/widgets/product_card.dart`

**Fungsi**: Card untuk menampilkan produk dalam grid

**Properties**:
```dart
- product: ProductModel  // Data produk
- onTap: VoidCallback?  // Action saat di-tap
```

**Fitur**:
- Gambar produk (cached)
- Badge diskon (jika ada promo)
- Nama produk (max 2 lines)
- Vendor name
- Harga (dengan strikethrough jika ada promo)
- Icon favorit

**Layout**:
```
┌──────────────────┐
│                  │
│   Gambar (1:1)   │ ← AspectRatio 1.0
│    [Badge 50%]   │ ← Jika ada promo
│                  │
├──────────────────┤
│ Nama Produk...   │ ← Max 2 lines
│ Vendor           │ ← Text hint
│                  │
│ Rp 50.000 (coret)│ ← Jika promo
│ ♥ Rp 25.000      │ ← Harga final
└──────────────────┘
```

**Penggunaan**:
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.7,
  ),
  itemBuilder: (ctx, i) {
    return ProductCard(
      product: products[i],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: products[i]),
          ),
        );
      },
    );
  },
)
```

---

### D. EmptyState
**Lokasi**: `core/widgets/empty_state.dart`

**Fungsi**: Widget untuk menampilkan state kosong

**Properties**:
```dart
- icon: IconData            // Icon besar di tengah
- title: String             // Judul
- message: String           // Pesan
- actionText: String?       // Optional button text
- onActionPressed: VoidCallback?  // Optional action
```

**Layout**:
```
      ┌─────┐
      │  ⭕  │ ← Large icon (120x120)
      └─────┘
   
   Keranjang Kosong  ← Title (bold, 20px)
   
   Belum ada produk  ← Message (14px)
   dalam keranjang
   
   [Mulai Belanja]   ← Optional button
```

**Penggunaan**:
```dart
if (provider.products.isEmpty) {
  return EmptyState(
    icon: Icons.inventory_2_outlined,
    title: 'Belum Ada Produk',
    message: 'Produk akan segera tersedia',
    actionText: 'Refresh',
    onActionPressed: () => provider.fetchProducts(),
  );
}
```

---

### E. LoadingWidget
**Lokasi**: `core/widgets/loading_widget.dart`

**Fungsi**: Loading indicator dengan optional message

**Komponen**:
1. **LoadingWidget**: Simple circular progress
2. **LoadingOverlay**: Overlay with loading (untuk blocking UI)
3. **ProductGridShimmer**: Shimmer effect untuk grid produk

**LoadingWidget**:
```dart
LoadingWidget(
  message: 'Memuat data...',
  size: 40,
)
```

**LoadingOverlay**:
```dart
LoadingOverlay(
  isLoading: provider.isLoading,
  message: 'Memproses pembayaran...',
  child: YourContent(),
)
```

**ProductGridShimmer**:
```dart
// Show shimmer saat loading products
if (isLoading) {
  return ProductGridShimmer(itemCount: 6);
}
```

---

## 2. Utility Functions

### A. CurrencyFormatter
**Lokasi**: `core/utils/currency_formatter.dart`

**Fungsi**: Format angka menjadi Rupiah

```dart
// Format integer ke Rupiah
CurrencyFormatter.format(50000)
// Output: "Rp 50.000"

// Format double dengan desimal
CurrencyFormatter.formatWithDecimal(50000.50)
// Output: "Rp 50.000,50"

// Parse string ke integer
CurrencyFormatter.parse("Rp 50.000")
// Output: 50000
```

**Implementasi**:
```dart
static String format(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',      // Indonesian locale
    symbol: 'Rp ',        // Rupiah symbol
    decimalDigits: 0,     // Tanpa desimal
  );
  return formatter.format(amount);
}
```

---

### B. Validators
**Lokasi**: `core/utils/validators.dart`

**Fungsi**: Validasi input form

**Validasi yang Tersedia**:

1. **validateEmail**
```dart
Validators.validateEmail(value)
// - Check tidak kosong
// - Check format email dengan regex
// Return: String? (error message atau null)
```

2. **validatePassword**
```dart
Validators.validatePassword(value)
// - Check tidak kosong
// - Check minimal 6 karakter
// Return: String? (error message atau null)
```

3. **validateUsername**
```dart
Validators.validateUsername(value)
// - Check tidak kosong
// - Check minimal 3, maksimal 20 karakter
// - Check hanya huruf, angka, underscore
// Return: String? (error message atau null)
```

4. **validateRequired**
```dart
Validators.validateRequired(value, fieldName: 'Nama')
// - Check tidak kosong
// Return: "Nama tidak boleh kosong"
```

5. **validatePhone**
```dart
Validators.validatePhone(value)
// - Check tidak kosong
// - Check format 10-13 digit
// Return: String? (error message atau null)
```

**Penggunaan di Form**:
```dart
TextFormField(
  controller: _emailController,
  validator: Validators.validateEmail,
)

TextFormField(
  controller: _addressController,
  validator: (value) => Validators.validateMinLength(
    value, 
    10, 
    fieldName: 'Alamat'
  ),
)
```

---

### C. ImageHelper
**Lokasi**: `core/utils/image_helper.dart`

**Fungsi**: Helper untuk load dan cache gambar

**Method**:

1. **networkImage**: Load gambar dari URL
```dart
ImageHelper.networkImage(
  url: product.imageUrl,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// Fitur:
// - Auto cache dengan CachedNetworkImage
// - Placeholder saat loading
// - Error widget jika gagal load
```

2. **assetImage**: Load gambar dari assets
```dart
ImageHelper.assetImage(
  path: 'assets/images/logo.png',
  width: 100,
  height: 100,
)
```

**Keuntungan**:
- Image caching otomatis (hemat bandwidth)
- Konsisten error handling
- Loading indicator
- Fallback UI jika error

---

## 3. Constants

### A. AppColors
**Lokasi**: `core/constants/app_colors.dart`

**Warna Tema Aplikasi**:
```dart
// Primary Colors
AppColors.primary           // #4CAF50 (Green)
AppColors.primaryLight      // #81C784
AppColors.primaryDark       // #388E3C

// Secondary Colors
AppColors.secondary         // #66BB6A
AppColors.accent           // #A5D6A7

// Background Colors
AppColors.white            // #FFFFFF
AppColors.background       // #F5F5F5
AppColors.surface          // #FFFFFF

// Text Colors
AppColors.textPrimary      // #212121
AppColors.textSecondary    // #757575
AppColors.textHint         // #9E9E9E

// Status Colors
AppColors.success          // #4CAF50
AppColors.error            // #E53935
AppColors.warning          // #FFA726
AppColors.info             // #42A5F5

// Gradients
AppColors.primaryGradient   // Green gradient
AppColors.softGradient      // Light gradient
AppColors.cardGradient      // Card gradient

// Others
AppColors.border           // #E0E0E0
AppColors.divider          // #EEEEEE
AppColors.shadow           // Black dengan opacity
```

**Penggunaan**:
```dart
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.white),
  ),
)
```

---

### B. AppTheme
**Lokasi**: `core/constants/app_theme.dart`

**Theme Configuration**:
```dart
MaterialApp(
  theme: AppTheme.lightTheme,  // ← Apply theme
  // ...
)
```

**Komponen Theme**:
- **ColorScheme**: Primary, secondary, surface, error colors
- **AppBarTheme**: Background, foreground, elevation
- **CardTheme**: Elevation, shadow, shape
- **ElevatedButtonTheme**: Styling untuk semua elevated buttons
- **TextButtonTheme**: Styling untuk text buttons
- **InputDecorationTheme**: Styling untuk text fields
- **BottomNavigationBarTheme**: Styling bottom nav

**Text Styles**:
```dart
// Headings
AppTheme.heading1  // 28px, bold
AppTheme.heading2  // 24px, bold
AppTheme.heading3  // 20px, semi-bold

// Body
AppTheme.bodyLarge   // 16px
AppTheme.bodyMedium  // 14px
AppTheme.bodySmall   // 12px

// Caption
AppTheme.caption     // 12px, medium weight

// Penggunaan:
Text('Title', style: AppTheme.heading1)
```

---

### C. ApiConstants
**Lokasi**: `core/constants/api_constants.dart`

**Base URL & Endpoints**:
```dart
ApiConstants.baseUrl    // Base URL API
ApiConstants.login      // /api/auth/login
ApiConstants.register   // /api/auth/register
ApiConstants.products   // /api/products
ApiConstants.cart       // /api/cart
ApiConstants.orders     // /api/orders
ApiConstants.payment    // /api/payment

// Dynamic endpoints:
ApiConstants.productById(id)           // /api/products/{id}
ApiConstants.productsByCategory(cat)   // /api/products?category={cat}
ApiConstants.orderById(orderId)        // /api/orders/{orderId}
```

**Headers**:
```dart
// Default headers
ApiConstants.defaultHeaders
// {'Content-Type': 'application/json'}

// Auth headers
ApiConstants.authHeaders(token)
// {
//   'Content-Type': 'application/json',
//   'Authorization': 'Bearer {token}'
// }
```

---

## 4. Page Components (Widget di Pages)

### A. Banner Slider (HomePage)
**Lokasi**: `presentation/pages/home/widgets/banner_slider.dart`

**Fitur**:
- Auto-scroll setiap 3 detik
- Page indicators
- Gradient overlay untuk readability
- Responsive touch scroll

**Data**:
```dart
List<BannerData> {
  title: String,
  subtitle: String,
  color: Color,
  gradient: LinearGradient
}
```

---

### B. Category Section
**Lokasi**: `presentation/pages/home/widgets/category_section.dart`

**Fitur**:
- Horizontal scroll
- Icon untuk setiap kategori
- Navigate ke ProductListPage on tap

**Kategori**:
- Smartphone
- Pakaian Pria
- Pakaian Wanita
- Sepatu Pria
- Sepatu Wanita

---

### C. Cart Item Card
**Lokasi**: `presentation/pages/cart/cart_page.dart` (private class)

**Fitur**:
- Gambar produk (80x80)
- Nama produk
- Harga per unit
- Quantity
- Subtotal
- Delete button

**Layout**:
```
┌────────────────────────────────────┐
│ [IMG] Nama Produk...              │
│  80    Rp 50.000                  │
│  x     Qty: 2                     │
│  80    Subtotal: Rp 100.000  [🗑] │
└────────────────────────────────────┘
```

---

## 5. Best Practices

### Kapan Membuat Custom Widget?

✅ **Buat custom widget jika**:
- Widget dipakai di 2+ tempat
- Widget complex dan punya state sendiri
- Widget bisa reusable dengan props berbeda

❌ **Jangan buat custom widget jika**:
- Widget hanya dipakai sekali
- Widget sangat simple (1-2 lines)
- Over-engineering

### Prinsip Design Reusable Widget

1. **Single Responsibility**: Widget punya 1 tujuan jelas
2. **Configurable**: Terima props untuk kustomisasi
3. **Self-contained**: Tidak depend pada external state
4. **Well-documented**: Ada dokumentasi/comments
5. **Consistent**: Follow app-wide design patterns

---

## 📌 Poin Penting untuk Ujian

**Q: Apa keuntungan custom widgets?**  
A: Konsistensi UI, reusability, maintainability, dan DRY principle

**Q: Kenapa pakai CurrencyFormatter?**  
A: Untuk format Rupiah yang konsisten di seluruh app sesuai locale Indonesia

**Q: Bagaimana ImageHelper membantu?**  
A: Auto caching, consistent error handling, dan loading indicators

**Q: Apa fungsi Validators?**  
A: Centralized validation logic, consistent error messages, reusable

**Q: Kenapa constants penting?**  
A: Single source of truth, mudah update, avoid magic strings/numbers

---

[← Alur Data](02-data-flow.md) | [README](../README.md) | [Fitur →](04-features.md)