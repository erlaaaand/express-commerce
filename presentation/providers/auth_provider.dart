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

  Future<void> initialize() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getStoredUserData();
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          notifyListeners();
          
          try {
            await getProfile();
          } catch (e) {
            debugPrint('Failed to fetch profile: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Initialize error: $e');
      _errorMessage = e.toString();
    }
  }

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
      debugPrint('Register error in provider: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

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

      debugPrint('Login result: $result');

      _user = UserModel(
        id: result['userId'] as String? ?? '',
        username: result['username'] as String,
        email: email,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Login error in provider: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> getProfile() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _user = await _authRepository.getProfile();
      _setLoading(false);
    } catch (e) {
      debugPrint('Get profile error: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      _setLoading(false);
      
      if (_errorMessage?.contains('token') == true ||
          _errorMessage?.contains('Unauthorized') == true) {
        await logout();
      }
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _extractErrorMessage(String error) {
    String message = error;
    
    while (message.contains('Exception: ')) {
      message = message.substring(message.indexOf('Exception: ') + 11);
    }
    
    message = message
        .replaceFirst(RegExp(r'^(Login|Registration|Network error): '), '')
        .trim();

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

    return message;
  }
}