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

      // Check response structure
      print('Register response: $response');

      final userData = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      print('Register error: $e');
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

      print('Login response: $response');

      // Handle different response structures
      Map<String, dynamic> data;
      
      if (response.containsKey('data')) {
        data = response['data'] as Map<String, dynamic>;
      } else {
        data = response;
      }

      // Extract token with multiple possible keys
      String? token;
      if (data.containsKey('token')) {
        token = data['token'] as String?;
      } else if (data.containsKey('accessToken')) {
        token = data['accessToken'] as String?;
      } else if (data.containsKey('access_token')) {
        token = data['access_token'] as String?;
      }

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan dalam response');
      }

      // Extract user info
      String? username;
      String? userId;

      if (data.containsKey('user')) {
        final userMap = data['user'] as Map<String, dynamic>;
        username = userMap['username'] as String?;
        userId = userMap['id'] as String? ?? userMap['_id'] as String?;
      } else {
        username = data['username'] as String?;
        userId = data['id'] as String? ?? data['userId'] as String?;
      }

      // Save token
      await _storageService.saveToken(token);
      print('Token saved: ${token.substring(0, 20)}...');

      // Save user data
      await _storageService.saveUserData({
        'id': userId ?? '',
        'username': username ?? 'User',
        'email': email,
      });

      return {
        'token': token,
        'username': username ?? 'User',
        'userId': userId ?? '',
      };
    } catch (e) {
      print('Login error: $e');
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

      print('Profile response: $response');

      Map<String, dynamic> userData;
      
      if (response.containsKey('data')) {
        userData = response['data'] as Map<String, dynamic>;
      } else {
        userData = response;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Get profile error: $e');
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