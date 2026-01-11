import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Register
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final userData = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        {
          'email': email,
          'password': password,
        },
      );

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final username = data['username'] as String;

      // Save token
      await _storageService.saveToken(token);

      // Save user data
      await _storageService.saveUserData({
        'username': username,
        'email': email,
      });

      return {
        'token': token,
        'username': username,
      };
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.profile,
        requiresAuth: true,
      );

      final userData = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.hasToken();
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUserData() async {
    return await _storageService.getUserData();
  }
}