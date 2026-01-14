import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

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

      debugPrint('Register response: $response');

      final userData = response['data'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Registration failed: $e');
    }
  }

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

      debugPrint('Login response: $response');

      Map<String, dynamic> data;
      
      if (response.containsKey('data')) {
        data = response['data'] as Map<String, dynamic>;
      } else {
        data = response;
      }

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

      await _storageService.saveToken(token);
      debugPrint('Token saved: ${token.substring(0, 20)}...');

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
      debugPrint('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.profile,
        requiresAuth: true,
      );

      debugPrint('Profile response: $response');

      Map<String, dynamic> userData;
      
      if (response.containsKey('data')) {
        userData = response['data'] as Map<String, dynamic>;
      } else {
        userData = response;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('Get profile error: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.hasToken();
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    return await _storageService.getUserData();
  }
}