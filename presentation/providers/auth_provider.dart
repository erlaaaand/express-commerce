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
        }
      }
    } catch (e) {
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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

      _user = UserModel(
        id: '',
        username: result['username'] as String,
        email: email,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
}