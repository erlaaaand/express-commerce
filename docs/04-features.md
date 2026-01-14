# ⚡ Fitur-Fitur Aplikasi

## 1. Authentication (Autentikasi)

### A. Splash Screen
**File**: `presentation/pages/splash/splash_page.dart`

**Fungsi**:
- Screen pertama saat app dibuka
- Animasi fade dan scale
- Auto navigate ke Onboarding setelah 3 detik

**Flow**:
```
App Launch
  │
  ├─→ Show SplashPage
  │     • Logo dengan animasi
  │     • Loading indicator
  │     • Gradient background
  │
  └─→ 3 seconds delay
        │
        └─→ Navigate to OnboardingPage
```

---

### B. Onboarding
**File**: `presentation/pages/onboarding/onboarding_page.dart`

**Fungsi**:
- Intro aplikasi (5 pages)
- Swipe untuk next page
- Skip button untuk langsung ke home

**Pages**:
1. Gadget & Elektronik
2. Fashion Pria
3. Sepatu & Aksesoris
4. Sepatu Wanita
5. Fashion Wanita

**Features**:
- Page indicators
- Back button (jika bukan page pertama)
- Next/Mulai Belanja button
- Skip button

---

### C. Register
**File**: `presentation/pages/auth/register_page.dart`

**Input Fields**:
```dart
- Username      // Min 3 chars, alphanumeric + underscore
- Email         // Valid email format
- Password      // Min 6 chars
- Confirm Pass  // Must match password
```

**Validasi**:
- Username: 3-20 karakter, hanya huruf/angka/underscore
- Email: Format email valid
- Password: Minimal 6 karakter
- Confirm Password: Harus sama dengan password

**Flow**:
```
User fill form
  │
  ├─→ Tap "Daftar"
  │
  ├─→ Validate all fields
  │     │
  │     ├─→ Invalid → Show error
  │     │
  │     └─→ Valid → Continue
  │
  ├─→ AuthProvider.register()
  │     │
  │     └─→ POST /api/auth/register
  │           │
  │           ├─→ Success:
  │           │     • Show success toast
  │           │     • Navigate back to LoginPage
  │           │
  │           └─→ Error:
  │                 • Show error toast
  │                 • Stay on page
  │
  └─→ "Sudah punya akun?" → Navigate to LoginPage
```

---

### D. Login
**File**: `presentation/pages/auth/login_page.dart`

**Input Fields**:
```dart
- Email       // Valid email format
- Password    // Min 6 chars, with visibility toggle
```

**Fitur**:
- Password visibility toggle
- Loading indicator saat login
- Error message display
- Link ke register page

**Flow**:
```
User input credentials
  │
  ├─→ Tap "Masuk"
  │
  ├─→ Validate form
  │
  ├─→ AuthProvider.login()
  │     │
  │     └─→ POST /api/auth/login
  │           │
  │           ├─→ Success:
  │           │     1. Save token
  │           │     2. Save user data
  │           │     3. Sync local cart
  │           │     4. Show success toast
  │           │     5. Navigate to HomePage
  │           │
  │           └─→ Error:
  │                 • Show error toast
  │                 • Display error message
  │
  └─→ "Belum punya akun?" → Navigate to RegisterPage
```

**Error Handling**:
- Network error: "Koneksi internet bermasalah"
- 401: "Email atau password salah"
- 500: "Server sedang bermasalah"

---

## 2. Home & Product Discovery

### A. Home Page
**File**: `presentation/pages/home/home_page.dart`

**Struktur**:
```
┌─────────────────────────────────┐
│ AppBar                          │
│ • Logo & Greeting               │
│ • Cart icon (with badge)        │
├─────────────────────────────────┤
│ Banner Slider                   │
│ • 3 promo banners               │
│ • Auto-scroll                   │
├─────────────────────────────────┤
│ Categories                      │
│ • Horizontal scroll             │
│ • 5 kategori                    │
├─────────────────────────────────┤
│ Product Grid                    │
│ • 2 kolom                       │
│ • Infinite scroll               │
└─────────────────────────────────┘
```

**Fitur**:
1. **Banner Slider**:
   - 3 banner promo
   - Auto-scroll setiap 4 detik
   - Page indicators
   - Gradient overlay

2. **Categories**:
   - Smartphone (Elektronik)
   - Pakaian Pria
   - Pakaian Wanita
   - Sepatu Pria
   - Sepatu Wanita
   - Tap kategori → ProductListPage

3. **Product Grid**:
   - GridView 2 kolom
   - ProductCard untuk setiap item
   - Tap card → ProductDetailPage
   - Badge diskon jika ada promo
   - Out of stock handling

**Bottom Navigation**:
- Home (active)
- Profile

---

### B. Product List by Category
**File**: `presentation/pages/products/product_list_page.dart`

**Fitur**:
1. **Search Bar**:
   - Real-time search
   - Filter products by name

2. **Sort Options** (Bottom sheet):
   - Nama Produk (A-Z)
   - Harga Terendah
   - Harga Tertinggi

3. **Product Grid**:
   - Same as home
   - Filtered by category

**Flow**:
```
Tap category di HomePage
  │
  ├─→ Navigate to ProductListPage(category)
  │
  ├─→ Fetch products by category
  │     GET /api/products?category={category}
  │
  ├─→ Display in grid
  │
  ├─→ User can:
  │     • Search products
  │     • Sort products
  │     • Tap product → ProductDetailPage
  │
  └─→ Empty state jika tidak ada produk
```

---

### C. Product Detail
**File**: `presentation/pages/products/product_detail_page.dart`

**Struktur**:
```
┌─────────────────────────────────┐
│ [←]                             │
│                                 │
│    Product Image (Full width)   │
│    SliverAppBar expandable      │
│                                 │
├─────────────────────────────────┤
│ Product Name (24px, bold)       │
│                                 │
│ [50% OFF] badge (if promo)      │
│ Rp 100.000 (strikethrough)      │
│ Rp 50.000 (large, green)        │
│                                 │
│ Stok: 15 unit available         │
│                                 │
│ Jumlah: [-] 1 [+]              │
├─────────────────────────────────┤
│ Deskripsi Produk                │
│ Lorem ipsum dolor sit amet...   │
├─────────────────────────────────┤
│ Informasi Tambahan              │
│ ✓ 100% Original                 │
│ ✓ Gratis Ongkir (Min 100k)      │
│ ✓ Pembayaran Aman               │
│ ✓ CS 24/7                       │
└─────────────────────────────────┘
│ [Tambah ke Keranjang]          │ ← Bottom bar
└─────────────────────────────────┘
```

**Fitur**:
1. **Image Slider**: 
   - Expandable header dengan parallax
   - Hero animation dari ProductCard

2. **Price Display**:
   - Original price (strikethrough jika promo)
   - Discount badge
   - Final price (bold, green)

3. **Stock Info**:
   - Available stock
   - Low stock warning (< 10)
   - Out of stock handling

4. **Quantity Selector**:
   - Increment/decrement buttons
   - Min: 1, Max: stock available

5. **Add to Cart**:
   - Check login status
   - Validate quantity
   - Add to cart via API
   - Success toast

**Flow**:
```
User on ProductDetailPage
  │
  ├─→ Select quantity
  │
  ├─→ Tap "Tambah ke Keranjang"
  │
  ├─→ Check if logged in
  │     │
  │     ├─→ NO → Show login dialog
  │     │          Navigate to LoginPage
  │     │
  │     └─→ YES → Continue
  │
  ├─→ CartProvider.addToCart(productId, quantity)
  │     │
  │     └─→ POST /api/cart
  │           {productId, quantity}
  │
  ├─→ Success:
  │     • Show success toast
  │     • Stay on page (bisa tambah lagi)
  │
  └─→ Error:
        • Show error toast
        • Display error message
```

---

## 3. Shopping Cart

### A. Cart Page
**File**: `presentation/pages/cart/cart_page.dart`

**Struktur**:
```
┌─────────────────────────────────┐
│ Keranjang Belanja      [🗑️]     │ ← AppBar
├─────────────────────────────────┤
│ [IMG] Product Name              │
│       Rp 50.000                 │
│       Qty: 2                    │
│       Subtotal: Rp 100.000 [❌] │
├─────────────────────────────────┤
│ [IMG] Product Name 2            │
│       ...                       │
├─────────────────────────────────┤
│                                 │
│        (More cart items)        │
│                                 │
└─────────────────────────────────┘
│ Subtotal: Rp 200.000            │ ← Bottom bar
│ Ongkir: GRATIS / Rp 15.000      │
│ ───────────────────────────     │
│ Total: Rp 215.000               │
│ [Checkout]                      │
└─────────────────────────────────┘
```

**Fitur**:
1. **Cart Items List**:
   - Gambar produk
   - Nama, harga, quantity
   - Subtotal per item
   - Delete button per item

2. **Summary**:
   - Subtotal semua item
   - Ongkir (Rp 15.000 atau GRATIS jika > Rp 100.000)
   - Total akhir

3. **Actions**:
   - Remove single item
   - Clear all items (🗑️ icon di AppBar)
   - Checkout button

**Free Shipping Logic**:
```dart
final shippingCost = totalAmount >= 100000 ? 0 : 15000;
final finalTotal = totalAmount + shippingCost;

// Show message jika belum free shipping
if (totalAmount < 100000) {
  "Belanja Rp {remaining} lagi untuk gratis ongkir"
}
```

**Flow**:
```
CartPage loaded
  │
  ├─→ Fetch cart dari backend
  │     GET /api/cart (authenticated)
  │
  ├─→ Display cart items
  │
  ├─→ User actions:
  │     │
  │     ├─→ Delete item:
  │     │     • Show confirm dialog
  │     │     • DELETE /api/cart/{productId}
  │     │     • Update UI
  │     │
  │     ├─→ Clear cart:
  │     │     • Show confirm dialog
  │     │     • DELETE /api/cart
  │     │     • Update UI → Show empty state
  │     │
  │     └─→ Checkout:
  │           • Navigate to CheckoutPage
  │
  └─→ Empty state jika cart kosong
```

---

## 4. Checkout & Payment

### A. Checkout Page
**File**: `presentation/pages/checkout/checkout_page.dart`

**Struktur**:
```
┌─────────────────────────────────┐
│ Checkout                    [←] │
├─────────────────────────────────┤
│ Ringkasan Pesanan               │
│ • Product 1 x2 ... Rp 100.000  │
│ • Product 2 x1 ... Rp 50.000   │
│ ────────────────────────────    │
│ Subtotal: Rp 150.000            │
│ Ongkir: GRATIS                  │
│ ────────────────────────────    │
│ Total: Rp 150.000               │
├─────────────────────────────────┤
│ Informasi Pengiriman            │
│ Email: [user@example.com]       │ ← Disabled
│ No. Telepon: [___________]      │
│ Alamat Lengkap: [________]      │ ← Min 10 chars
│ Catatan (Opsional): [____]      │
└─────────────────────────────────┘
│ Total Pembayaran: Rp 150.000    │ ← Bottom bar
│ [Lanjut ke Pembayaran]          │
└─────────────────────────────────┘
```

**Input Validation**:
- Phone: 10-13 digit
- Address: Min 10 karakter
- Notes: Optional

**Flow**:
```
CheckoutPage
  │
  ├─→ Display order summary dari cart
  │
  ├─→ User fill shipping info
  │
  ├─→ Tap "Lanjut ke Pembayaran"
  │
  ├─→ Validate form
  │     │
  │     └─→ Invalid → Show error
  │
  ├─→ CartProvider.checkoutCart()
  │     │
  │     └─→ POST /api/orders/checkout
  │           {shippingAddress, notes}
  │           │
  │           └─→ Backend:
  │                 1. Create order
  │                 2. Clear cart
  │                 3. Integrate Midtrans
  │                 4. Return payment URL
  │
  ├─→ Response: {orderId, paymentUrl, totalAmount}
  │
  ├─→ Show Payment WebView in BottomSheet
  │
  └─→ WebView menampilkan halaman Midtrans
```

---

### B. Payment WebView
**File**: Integrated di `checkout_page.dart`

**Fungsi**:
- Display Midtrans payment page
- Monitor URL changes untuk detect success/failure

**Flow**:
```
WebView opened dengan paymentUrl
  │
  ├─→ User pilih metode pembayaran
  │     • Bank transfer
  │     • E-wallet
  │     • Credit card
  │     • dll
  │
  ├─→ User complete payment
  │
  ├─→ WebView detect URL change:
  │     │
  │     ├─→ Contains "success" atau "settlement":
  │     │     • Close WebView
  │     │     • Show success dialog
  │     │     • Navigate to OrderHistoryPage
  │     │
  │     ├─→ Contains "failed" atau "cancel":
  │     │     • Close WebView
  │     │     • Show failure toast
  │     │     • Stay on CheckoutPage
  │     │
  │     └─→ Contains "pending":
  │           • Close WebView
  │           • Show pending message
  │           • User bisa cek status di Orders
  │
  └─→ User tap close button:
        • Show confirm dialog
        • Return to CheckoutPage
```

**URL Detection**:
```dart
onNavigationRequest: (NavigationRequest request) {
  final url = request.url;
  
  if (url.contains('status=success') || 
      url.contains('settlement')) {
    handlePaymentSuccess();
    return NavigationDecision.prevent;
  }
  
  if (url.contains('status=failed')) {
    handlePaymentFailed();
    return NavigationDecision.prevent;
  }
  
  return NavigationDecision.navigate;
}
```

---

## 5. Order Management

### A. Order History
**File**: `presentation/pages/orders/order_history_page.dart`

**Struktur**:
```
┌─────────────────────────────────┐
│ Riwayat Pesanan             [←] │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 15 Jan 2026, 14:30  [Selesai]│ │
│ │ ───────────────────────────  │ │
│ │ [IMG] Product Name           │ │
│ │       +2 barang lainnya      │ │
│ │                              │ │
│ │ Total: Rp 150.000            │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 14 Jan 2026, 10:15  [Pending]│ │
│ │ ...                          │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**Order Status**:
- `Pending`: Menunggu pembayaran (orange)
- `Paid`: Sudah dibayar (blue)
- `Shipped`: Sedang dikirim (info)
- `Completed`: Selesai (green)
- `Cancelled`: Dibatalkan (red)

**Features**:
- List semua pesanan (sorted by date, newest first)
- Order status badge dengan warna
- Thumbnail produk pertama
- "+X barang lainnya" jika lebih dari 1 item
- Total amount per order

**Flow**:
```
OrderHistoryPage loaded
  │
  ├─→ OrderProvider.fetchOrders()
  │     │
  │     └─→ GET /api/orders (authenticated)
  │           │
  │           └─→ Return list of orders
  │
  ├─→ Sort by createdAt (DESC)
  │
  ├─→ Display list
  │
  └─→ Empty state jika belum ada order
```

---

## 6. Profile Management

### A. Profile Page
**File**: `presentation/pages/profile/profile_page.dart`

**Struktur (Logged In)**:
```
┌─────────────────────────────────┐
│                                 │
│         [Avatar Icon]           │ ← Expandable header
│         Username                │    with gradient
│         user@example.com        │
│                                 │
├─────────────────────────────────┤
│ Informasi Akun                  │
│ ┌─────────────────────────────┐ │
│ │ 👤 Username                  │ │
│ │    Nama User                 │ │
│ │ ───────────────────────────  │ │
│ │ ✉️  Email                    │ │
│ │    user@example.com          │ │
│ │ ───────────────────────────  │ │
│ │ ✓  Status                    │ │
│ │    Aktif                     │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 🛍️  Pesanan Saya     >      │ │ ← Navigate to Orders
│ │    Lihat riwayat pesanan    │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ [Logout]                        │ ← Red button
└─────────────────────────────────┘
```

**Struktur (Not Logged In)**:
```
┌─────────────────────────────────┐
│                                 │
│     [Person Icon (outlined)]    │
│                                 │
│        Belum Login              │
│                                 │
│ Silakan login untuk melihat     │
│ profil Anda                     │
│                                 │
│    [Login Sekarang]             │
│                                 │
└─────────────────────────────────┘
```

**Features**:
- Display user info (jika login)
- Navigate ke Order History
- Logout dengan confirmation
- Auto navigate to LoginPage jika belum login

**Logout Flow**:
```
Tap Logout button
  │
  ├─→ Show confirm dialog
  │     "Apakah Anda yakin ingin keluar?"
  │
  ├─→ User confirm
  │
  ├─→ AuthProvider.logout()
  │     │
  │     └─→ StorageService.clearAll()
  │           • Remove token
  │           • Remove user data
  │           • Clear local cart
  │
  ├─→ Set _user = null
  │
  ├─→ notifyListeners()
  │
  └─→ Navigate to HomePage
        (Bottom nav akan show "Profile" untuk login)
```

---

## 📌 Poin Penting untuk Ujian

**Q: Jelaskan flow lengkap dari login sampai checkout!**  
A: Login → Save token → HomePage → Browse products → Add to cart → CartPage → CheckoutPage → Fill shipping info → Payment WebView → Success → Order created

**Q: Bagaimana handling guest user?**  
A: Guest bisa browse produk, tapi tidak bisa add to cart atau checkout. Saat tap "Tambah ke Keranjang", muncul dialog untuk login.

**Q: Apa yang terjadi saat checkout?**  
A: 
1. Validate shipping info
2. POST checkout ke backend
3. Backend create order, clear cart, generate payment URL
4. Frontend show WebView dengan payment URL
5. User bayar via Midtrans
6. WebView detect success → Show dialog → Navigate to Orders

**Q: Bagaimana sync cart antara guest dan logged user?**  
A: 
- Guest: Cart disimpan di local storage
- Setelah login: syncLocalCart() akan add semua item dari local storage ke backend cart
- Local storage di-clear setelah sync

**Q: Bagaimana handle out of stock?**  
A: 
- ProductCard: Show "Stok Habis" overlay
- ProductDetail: Disable "Add to Cart" button
- Cart: Jika item out of stock saat checkout, backend akan reject

---

[← Komponen](03-components.md) | [README](../README.md) | [Models & Repo →](05-models-repositories.md)