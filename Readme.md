# 📱 Kadai Erland - E-Commerce Mobile Application

> Aplikasi e-commerce mobile yang dibangun menggunakan Flutter dengan arsitektur Clean Architecture dan State Management menggunakan Provider.

## 📚 Dokumentasi

Dokumentasi lengkap proyek ini tersedia di folder `docs/`:

### 1. [Arsitektur & Struktur Proyek](docs/01-architecture.md)
- Penjelasan Clean Architecture
- Struktur folder dan organisasi kode
- Layer-layer dalam aplikasi (Presentation, Domain, Data, Core)

### 2. [Alur Data & State Management](docs/02-data-flow.md)
- Alur data dari UI ke Backend
- Penjelasan Provider Pattern
- Request-Response Flow
- Error Handling

### 3. [Komponen & Widget](docs/03-components.md)
- Custom Widgets yang digunakan
- Reusable Components
- UI/UX Patterns

### 4. [Fitur-Fitur Aplikasi](docs/04-features.md)
- Authentication (Login & Register)
- Product Management
- Shopping Cart
- Checkout & Payment
- Order History

### 5. [Model & Repository](docs/05-models-repositories.md)
- Data Models
- Repository Pattern
- API Services
- Local Storage

### 6. [Skenario Penggunaan](docs/06-use-cases.md)
- User Journey
- Business Logic
- Validation Rules

### 7. [Integrasi API](docs/07-api-integration.md)
- Endpoints yang digunakan
- Request/Response Format
- Authentication Flow

### 8. [UI/UX Design](docs/08-ui-design.md)
- Color Scheme
- Typography
- Navigation Flow
- Screen Layouts

## 🚀 Quick Start

### Instalasi
```bash
flutter pub get
```

### Menjalankan Aplikasi
```bash
flutter run
```

## 📋 Ringkasan Singkat

### Teknologi yang Digunakan
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Image Caching**: cached_network_image
- **Payment**: WebView (Midtrans Integration)

### Arsitektur
Aplikasi ini menggunakan **Clean Architecture** dengan 3 layer utama:
1. **Presentation Layer** - UI, Pages, Providers
2. **Domain Layer** - Use Cases, Business Logic
3. **Data Layer** - Models, Repositories, Services

### Fitur Utama
✅ Autentikasi (Login & Register)  
✅ Katalog Produk dengan Kategori  
✅ Detail Produk  
✅ Keranjang Belanja  
✅ Checkout & Pembayaran  
✅ Riwayat Pesanan  
✅ Profil Pengguna  

## 📖 Cara Membaca Dokumentasi

Untuk persiapan ujian, disarankan membaca dokumentasi dalam urutan berikut:

1. **Mulai dari Arsitektur** (`01-architecture.md`) - Pahami struktur dasar
2. **Alur Data** (`02-data-flow.md`) - Pahami bagaimana data mengalir
3. **Fitur-Fitur** (`04-features.md`) - Pahami fungsionalitas aplikasi
4. **Model & Repository** (`05-models-repositories.md`) - Pahami struktur data
5. **Skenario Penggunaan** (`06-use-cases.md`) - Pahami business logic
6. **Integrasi API** (`07-api-integration.md`) - Pahami komunikasi dengan backend

## 🎯 Poin Penting untuk Ujian

### 1. Arsitektur
- Jelaskan mengapa menggunakan Clean Architecture
- Sebutkan keuntungan separation of concerns
- Jelaskan peran setiap layer

### 2. State Management
- Jelaskan kenapa memilih Provider
- Bagaimana Provider bekerja dengan ChangeNotifier
- Kapan notifyListeners() dipanggil

### 3. Alur Aplikasi
- User flow dari splash → login → home → checkout
- Bagaimana data produk ditampilkan
- Proses pembayaran end-to-end

### 4. Penanganan Error
- Try-catch di setiap async operation
- Error message yang user-friendly
- Fallback UI untuk error states

### 5. Best Practices
- Reusable widgets untuk maintainability
- Separation of concerns
- Proper error handling
- Clean code principles

## 👨‍💻 Developer

**Erland**  
Email: -  
Project: Kadai Erland E-Commerce App

## 📝 Catatan

Dokumentasi ini dibuat untuk membantu pemahaman teoritis dan praktis dari implementasi aplikasi e-commerce menggunakan Flutter. Setiap bagian dokumentasi mencakup:
- Penjelasan konsep
- Diagram alur
- Contoh kode
- Best practices
- Common pitfalls

---
