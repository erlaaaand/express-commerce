import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _localCartKey = 'local_cart';

  // Token Management
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Local Cart Management (untuk offline)
  Future<void> saveLocalCart(List<String> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_localCartKey, cartItems);
  }

  Future<List<String>> getLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_localCartKey) ?? [];
  }

  Future<void> clearLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localCartKey);
  }

  Future<void> addToLocalCart(String productId) async {
    final cart = await getLocalCart();
    if (!cart.contains(productId)) {
      cart.add(productId);
      await saveLocalCart(cart);
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}