import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize - check if user is logged in
  Future<void> initialize() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getStoredUserData();
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          notifyListeners();
          
          // Try to fetch fresh profile data
          try {
            await getProfile();
          } catch (e) {
            print('Failed to fetch profile: $e');
            // Keep using stored data if profile fetch fails
          }
        }
      }
    } catch (e) {
      print('Initialize error: $e');
      _errorMessage = e.toString();
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );

      _user = user;
      _setLoading(false);
      return true;
    } catch (e) {
      print('Register error in provider: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Login
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

      print('Login result: $result');

      // Create user model from login result
      _user = UserModel(
        id: result['userId'] as String? ?? '',
        username: result['username'] as String,
        email: email,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      print('Login error in provider: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get Profile
  Future<void> getProfile() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _user = await _authRepository.getProfile();
      _setLoading(false);
    } catch (e) {
      print('Get profile error: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      
      // If profile fetch fails due to invalid token, logout
      if (_errorMessage?.contains('token') == true ||
          _errorMessage?.contains('Unauthorized') == true) {
        await logout();
      }
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Extract clean error message
  String _extractErrorMessage(String error) {
    // Extract the actual error message from nested exceptions
    String message = error;
    
    // Remove all 'Exception: ' prefixes
    while (message.contains('Exception: ')) {
      message = message.substring(message.indexOf('Exception: ') + 11);
    }
    
    // Remove 'Login failed: ', 'Registration failed: ', etc.
    message = message
        .replaceFirst(RegExp(r'^(Login|Registration|Network error): '), '')
        .trim();

    // Make error messages user-friendly
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid credentials') ||
        lowerMessage.contains('incorrect password') ||
        lowerMessage.contains('wrong password')) {
      return 'Email atau password salah';
    } else if (lowerMessage.contains('unauthorized') ||
               lowerMessage.contains('401')) {
      return 'Email atau password salah';
    } else if (lowerMessage.contains('user not found') ||
               lowerMessage.contains('account not found')) {
      return 'Akun tidak ditemukan';
    } else if (lowerMessage.contains('email already exists') ||
               lowerMessage.contains('user already exists')) {
      return 'Email sudah terdaftar';
    } else if (lowerMessage.contains('network') ||
               lowerMessage.contains('connection') ||
               lowerMessage.contains('failed host lookup')) {
      return 'Koneksi internet bermasalah';
    } else if (lowerMessage.contains('timeout')) {
      return 'Koneksi timeout, coba lagi';
    } else if (lowerMessage.contains('token') && 
               !lowerMessage.contains('tidak ditemukan')) {
      return 'Sesi login bermasalah, silakan login ulang';
    } else if (lowerMessage.contains('server error') ||
               lowerMessage.contains('500') ||
               lowerMessage.contains('502') ||
               lowerMessage.contains('503')) {
      return 'Server sedang bermasalah, coba lagi nanti';
    } else if (message.isEmpty) {
      return 'Terjadi kesalahan, coba lagi';
    }

    // Return the cleaned message as-is if no pattern matches
    return message;
  }
}