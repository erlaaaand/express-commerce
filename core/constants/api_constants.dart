class ApiConstants {
  static const String baseUrl = 'https://express-commerce-production.up.railway.app';
  
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String profile = '$baseUrl/api/auth/profile';
  
  static const String products = '$baseUrl/api/products';
  static String productById(String id) => '$products/$id';
  static String productsByCategory(String category) => '$products?category=$category';
  
  static const String cart = '$baseUrl/api/cart';
  static String removeFromCart(String productId) => '$cart/$productId';
  static String updateCart(String productId) => '$cart/$productId';
  
  static const String orders = '$baseUrl/api/orders';
  static const String checkout = '$orders/checkout';
  static String orderById(String orderId) => '$orders/$orderId';
  static String cancelOrder(String orderId) => '$orders/$orderId/cancel';
  
  static const String payment = '$baseUrl/api/payment';
  static const String paymentNotification = '$payment/notification';
  static String paymentStatus(String orderId) => '$payment/status/$orderId';
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}